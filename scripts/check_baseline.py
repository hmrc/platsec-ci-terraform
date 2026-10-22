#!/usr/bin/env python3
"""Allow reviewed legacy findings while rejecting newly introduced findings."""

import argparse
from collections import Counter
import csv
from dataclasses import astuple, dataclass
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
from typing import Any


ROOT = Path(__file__).resolve().parent.parent
BASELINE = ROOT / ".checks-baseline.txt"
TOOLS = ("tflint", "trivy", "checkov")
BASELINE_COLUMNS = ["tool", "count", "file", "rule", "subject", "severity", "context"]


@dataclass(frozen=True, order=True)
class Identity:
    file: str
    rule: str
    subject: str
    severity: str
    context: str = ""


@dataclass(frozen=True)
class Finding:
    identity: Identity
    line: int
    message: str


def relative_path(value: str) -> str:
    # Checkov prefixes repository-relative paths with "/".
    for prefix in (str(ROOT) + "/", "/src/"):
        if value.startswith(prefix):
            value = value[len(prefix):]
            break
    path = PurePosixPath(value.lstrip("/"))
    if ".." in path.parts or not path.parts:
        raise ValueError(f"Invalid finding path: {value!r}")
    return str(path)


def report_from_output(tool: str, output: str, status: int) -> dict[str, Any]:
    decoder = json.JSONDecoder()
    reports = []
    for match in re.finditer(r"(?m)^\{", output):
        try:
            report, _ = decoder.raw_decode(output, match.start())
        except json.JSONDecodeError:
            continue
        if not isinstance(report, dict):
            continue
        if (
            (tool == "tflint" and "issues" in report and "errors" in report)
            or (tool == "trivy" and "SchemaVersion" in report)
            or (tool == "checkov" and report.get("check_type") == "terraform")
        ):
            reports.append(report)
    if (tool == "tflint" and not reports and status == 0
            and "Command 'tflint --init' successfully done:" in output):
        # The upstream TFLint hook prints its JSON report only on nonzero exit.
        return {"issues": [], "errors": []}
    if len(reports) != 1:
        raise ValueError(f"Expected one {tool} JSON report, received {len(reports)}")
    return reports[0]


def findings_from_report(tool: str, report: dict[str, Any]) -> list[Finding]:
    findings = []
    if tool == "tflint":
        if report["errors"]:
            raise ValueError(f"TFLint execution errors: {report['errors']}")
        for issue in report["issues"]:
            location = issue["range"]
            file = relative_path(location["filename"])
            start, end = location["start"], location["end"]
            lines = (ROOT / file).read_text().splitlines()
            if not 1 <= start["line"] <= end["line"] <= len(lines):
                raise ValueError(f"Invalid TFLint range in {file}")
            snippet = lines[start["line"] - 1:end["line"]]
            snippet[-1] = snippet[-1][:end["column"] - 1]
            snippet[0] = snippet[0][start["column"] - 1:]
            context = hashlib.sha256(" ".join(" ".join(snippet).split()).encode()).hexdigest()
            findings.append(Finding(
                Identity(file, issue["rule"]["name"], issue["message"],
                         issue["rule"]["severity"], context),
                start["line"], issue["message"],
            ))
    elif tool == "trivy":
        if report["SchemaVersion"] != 2 or report.get("ArtifactType") != "filesystem":
            raise ValueError("Unsupported Trivy report schema")
        for result in report["Results"]:
            for issue in result.get("Misconfigurations", []):
                metadata = issue["CauseMetadata"]
                findings.append(Finding(
                    Identity(relative_path(result["Target"]), issue["ID"],
                             metadata["Resource"], issue["Severity"]),
                    metadata["StartLine"], issue["Title"],
                ))
    else:
        summary = report["summary"]
        if summary["parsing_errors"]:
            raise ValueError(f"Checkov could not parse {summary['parsing_errors']} files")
        issues = report["results"].get("failed_checks", [])
        if summary["failed"] != len(issues):
            raise ValueError("Incomplete Checkov report")
        for issue in issues:
            # A local module can be evaluated from more than one caller.
            caller = issue.get("caller_file_path")
            subject = issue["resource"]
            if caller:
                subject += " (caller: " + relative_path(caller) + ")"
            findings.append(Finding(
                Identity(relative_path(issue["file_path"]), issue["check_id"],
                         subject, issue.get("severity") or ""),
                issue["file_line_range"][0], issue["check_name"],
            ))
    return findings


def scan(tool: str) -> list[Finding]:
    command = [
        "bash", "scripts/pre-commit.sh", "run", "--color", "never",
        "--config", "scripts/scan-hooks.yaml", f"terraform_{tool}",
        "--all-files", "--verbose",
    ]
    # Recursive TFLint uses PWD when making report paths relative.
    environment = {**os.environ, "PWD": str(ROOT)}
    result = subprocess.run(command, cwd=ROOT, env=environment, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, check=False)
    try:
        if result.returncode not in (0, 1):
            raise ValueError(f"Scanner runner exited {result.returncode}")
        report = report_from_output(tool, result.stdout, result.returncode)
        findings = findings_from_report(tool, report)
        if result.returncode and (not findings or tool == "trivy"):
            raise ValueError(f"{tool} failed to execute")
        return findings
    except (ValueError, KeyError, TypeError, OSError):
        print(result.stdout, file=sys.stderr)
        raise


def load_baseline() -> dict[str, Counter[Identity]]:
    baseline: dict[str, Counter[Identity]] = {tool: Counter() for tool in TOOLS}
    with BASELINE.open(newline="", encoding="utf-8") as source:
        rows = csv.reader(source, delimiter="\t", strict=True)
        if next(rows, None) != BASELINE_COLUMNS:
            raise ValueError("Invalid checks baseline header")
        for row in rows:
            if len(row) != len(BASELINE_COLUMNS):
                raise ValueError(f"Invalid baseline row at line {rows.line_num}")
            tool, raw_count, *fields = row
            identity = Identity(*fields)
            count = int(raw_count)
            if (tool not in baseline or count < 1 or identity in baseline[tool]
                    or not all((identity.file, identity.rule, identity.subject))):
                raise ValueError(f"Invalid baseline entry at line {rows.line_num}")
            baseline[tool][identity] = count
    return baseline


def write_baseline(path: Path, baseline: dict[str, Counter[Identity]]) -> None:
    with path.open("w", newline="", encoding="utf-8") as destination:
        rows = csv.writer(destination, delimiter="\t", lineterminator="\n")
        rows.writerow(BASELINE_COLUMNS)
        for tool in TOOLS:
            for identity, count in sorted(baseline[tool].items()):
                rows.writerow((tool, count, *astuple(identity)))


def new_findings(findings: list[Finding], accepted: Counter[Identity]) -> list[Finding]:
    remaining = accepted.copy()
    new = []
    for finding in findings:
        if remaining[finding.identity]:
            remaining[finding.identity] -= 1
        else:
            new.append(finding)
    return new


def update_baseline() -> None:
    baseline = {}
    for tool in TOOLS:
        counts = Counter(finding.identity for finding in scan(tool))
        baseline[tool] = counts
        print(f"{tool}: baselining {sum(counts.values())} existing findings")
    # Do not replace the baseline unless all three scans completed successfully.
    temporary = BASELINE.with_suffix(".txt.tmp")
    try:
        write_baseline(temporary, baseline)
        temporary.replace(BASELINE)
    finally:
        temporary.unlink(missing_ok=True)
    print("Baseline updated. Review its diff before committing; do not accept new issues automatically.")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=(*TOOLS, "update"))
    args = parser.parse_args()
    try:
        if args.tool == "update":
            update_baseline()
            return 0
        accepted = load_baseline()[args.tool]
        findings = scan(args.tool)
        new = new_findings(findings, accepted)
        print(f"{args.tool}: {len(findings) - len(new)} accepted legacy findings; "
              f"{len(new)} new findings")
        for finding in new:
            identity = finding.identity
            print(f"NEW {identity.rule}: {identity.file}:{finding.line} "
                  f"[{identity.subject}] {finding.message}")
        return 1 if new else 0
    except (OSError, ValueError, KeyError, TypeError, csv.Error) as error:
        print(f"Checks baseline error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
