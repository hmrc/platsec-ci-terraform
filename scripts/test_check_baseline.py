import copy
from collections import Counter
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import check_baseline as checks


class BaselineTests(unittest.TestCase):
    def setUp(self):
        self.work = tempfile.TemporaryDirectory()
        self.addCleanup(self.work.cleanup)
        self.root = Path(self.work.name)
        self.root_patch = patch.object(checks, "ROOT", self.root)
        self.root_patch.start()
        self.addCleanup(self.root_patch.stop)
        self.source = self.root / "main.tf"
        self.source.write_text('locals {\n  unused = "old"\n}\n')

    def tflint_report(self, line=2):
        return {"errors": [], "issues": [{
            "rule": {"name": "terraform_unused_declarations", "severity": "warning"},
            "message": 'local.unused is declared but not used',
            "range": {"filename": "main.tf", "start": {"line": line, "column": 3},
                      "end": {"line": line, "column": 17}},
        }]}

    def checkov_report(self, resource="aws_s3_bucket.old", line=1):
        return {
            "check_type": "terraform",
            "summary": {"failed": 1, "parsing_errors": 0},
            "results": {"failed_checks": [{
                "check_id": "CKV_AWS_1", "resource": resource,
                "file_path": "/main.tf", "file_line_range": [line, line + 2],
                "check_name": "Example security check",
            }]},
        }

    def trivy_report(self, resource="aws_s3_bucket.old", line=1):
        return {
            "SchemaVersion": 2, "ArtifactType": "filesystem",
            "Results": [{"Target": "main.tf", "Misconfigurations": [{
                "ID": "AVD-AWS-0001", "Severity": "HIGH", "Title": "Example check",
                "CauseMetadata": {"Resource": resource, "StartLine": line},
            }]}],
        }

    def test_line_shifts_do_not_create_new_findings(self):
        for tool, report in (("checkov", self.checkov_report()),
                             ("trivy", self.trivy_report())):
            with self.subTest(tool=tool):
                accepted = Counter(f.identity for f in checks.findings_from_report(tool, report))
                shifted = (self.checkov_report(line=15) if tool == "checkov"
                           else self.trivy_report(line=15))
                findings = checks.findings_from_report(tool, shifted)
                self.assertEqual(checks.new_findings(findings, accepted), [])
        accepted = Counter(f.identity for f in checks.findings_from_report("tflint", self.tflint_report()))
        self.source.write_text('\n\nlocals {\n  unused = "old"\n}\n')
        findings = checks.findings_from_report("tflint", self.tflint_report(line=4))
        self.assertEqual(checks.new_findings(findings, accepted), [])

    def test_new_resources_and_duplicate_instances_fail(self):
        for tool, original, added in (
            ("checkov", self.checkov_report(), self.checkov_report("aws_s3_bucket.new")),
            ("trivy", self.trivy_report(), self.trivy_report("aws_s3_bucket.new")),
        ):
            with self.subTest(tool=tool):
                old = checks.findings_from_report(tool, original)
                new = checks.findings_from_report(tool, added)
                accepted = Counter(f.identity for f in old)
                self.assertEqual(checks.new_findings(old + new, accepted), new)
                self.assertEqual(checks.new_findings(old + old, accepted), old)
                self.assertEqual(checks.new_findings([], accepted), [])

    def test_changed_tflint_expression_and_new_rule_fail(self):
        report = self.tflint_report()
        old = checks.findings_from_report("tflint", report)
        accepted = Counter(f.identity for f in old)
        self.source.write_text('locals {\n  unused = "new"\n}\n')
        self.assertEqual(len(checks.new_findings(
            checks.findings_from_report("tflint", report), accepted)), 1)
        changed = copy.deepcopy(report)
        changed["issues"][0]["rule"]["name"] = "new_rule"
        self.assertEqual(len(checks.new_findings(
            checks.findings_from_report("tflint", changed), accepted)), 1)

    def test_severity_increases_and_new_paths_fail(self):
        report = self.trivy_report()
        old = checks.findings_from_report("trivy", report)
        accepted = Counter(f.identity for f in old)
        report["Results"][0]["Misconfigurations"][0]["Severity"] = "CRITICAL"
        self.assertEqual(len(checks.new_findings(
            checks.findings_from_report("trivy", report), accepted)), 1)
        report["Results"][0]["Target"] = "new/main.tf"
        self.assertEqual(len(checks.new_findings(
            checks.findings_from_report("trivy", report), accepted)), 1)

    def test_container_and_host_paths_are_equivalent(self):
        self.assertEqual(checks.relative_path("/src/main.tf"), "main.tf")
        self.assertEqual(checks.relative_path(str(self.source)), "main.tf")
        self.assertEqual(checks.relative_path("/main.tf"), "main.tf")
        with self.assertRaises(ValueError):
            checks.relative_path("../main.tf")

    def test_reports_are_extracted_from_runner_metadata(self):
        for tool, report in (("tflint", self.tflint_report()),
                             ("checkov", self.checkov_report()),
                             ("trivy", self.trivy_report())):
            with self.subTest(tool=tool):
                output = "Hook.....Failed\n- exit code: 1\n\n" + json.dumps(report, indent=2)
                self.assertEqual(checks.report_from_output(tool, output, 1), report)
                with self.assertRaises(ValueError):
                    checks.report_from_output(tool, output + "\n" + json.dumps(report), 1)

    def test_missing_malformed_reports_and_scan_errors_fail(self):
        for tool in checks.TOOLS:
            for status in (0, 1):
                with self.subTest(tool=tool, status=status), self.assertRaises(ValueError):
                    checks.report_from_output(tool, '{"broken":', status)
        report = self.tflint_report()
        report["errors"] = [{"message": "invalid HCL"}]
        with self.assertRaises(ValueError):
            checks.findings_from_report("tflint", report)
        report = self.checkov_report()
        report["summary"]["parsing_errors"] = 1
        with self.assertRaises(ValueError):
            checks.findings_from_report("checkov", report)
        report = self.checkov_report()
        report["summary"]["failed"] = 2
        with self.assertRaises(ValueError):
            checks.findings_from_report("checkov", report)

    def test_clean_tflint_upstream_output(self):
        output = "TFLint...Passed\nCommand 'tflint --init' successfully done:\nAll plugins are already installed"
        self.assertEqual(checks.report_from_output("tflint", output, 0),
                         {"issues": [], "errors": []})
        with self.assertRaises(ValueError):
            checks.report_from_output("tflint", output, 1)

    def test_failed_scanner_with_json_is_not_accepted(self):
        result = subprocess.CompletedProcess([], 1, json.dumps(self.trivy_report()))
        with patch.object(checks.subprocess, "run", return_value=result):
            with self.assertRaises(ValueError):
                checks.scan("trivy")

    def test_scanner_receives_consistent_working_directory(self):
        result = subprocess.CompletedProcess([], 0, json.dumps(self.trivy_report()))
        with patch.object(checks.subprocess, "run", return_value=result) as run:
            checks.scan("trivy")
        self.assertEqual(run.call_args.kwargs["env"]["PWD"], str(self.root))
        self.assertEqual(run.call_args.kwargs["cwd"], self.root)

    def test_failed_update_preserves_baseline(self):
        baseline = self.root / "baseline.txt"
        baseline.write_text("original\n")
        with patch.object(checks, "BASELINE", baseline), \
                patch.object(checks, "scan", side_effect=[[], ValueError("scanner failed")]):
            with self.assertRaises(ValueError):
                checks.update_baseline()
        self.assertEqual(baseline.read_text(), "original\n")

    def test_missing_or_invalid_baseline_fails(self):
        baseline = self.root / "baseline.txt"
        with patch.object(checks, "BASELINE", baseline):
            with self.assertRaises(FileNotFoundError):
                checks.load_baseline()
            baseline.write_text('{"version": 1, "tools": {}}')
            with self.assertRaises(ValueError):
                checks.load_baseline()

    def test_text_baseline_round_trip(self):
        baseline = self.root / "baseline.txt"
        identity = checks.Identity("main.tf", "rule", 'subject | "quoted"\tvalue\nnext', "", "hash")
        expected = {tool: Counter() for tool in checks.TOOLS}
        expected["tflint"][identity] = 2
        with patch.object(checks, "BASELINE", baseline):
            checks.write_baseline(baseline, expected)
            self.assertEqual(checks.load_baseline(), expected)

    def test_invalid_text_baseline_entries_fail(self):
        baseline = self.root / "baseline.txt"
        header = "\t".join(checks.BASELINE_COLUMNS) + "\n"
        row = "tflint\t1\tmain.tf\trule\tsubject\twarning\thash\n"
        for body in (
            row.replace("tflint", "unknown"),
            row.replace("\t1\t", "\t0\t"),
            row.replace("\t1\t", "\t1.5\t"),
            row + row,
            "tflint\t1\n",
        ):
            with self.subTest(body=body), patch.object(checks, "BASELINE", baseline):
                baseline.write_text(header + body)
                with self.assertRaises(ValueError):
                    checks.load_baseline()

    def test_successful_update_writes_text_baseline(self):
        baseline = self.root / "baseline.txt"
        finding = checks.Finding(checks.Identity("main.tf", "rule", "resource", "HIGH"), 1, "issue")
        with patch.object(checks, "BASELINE", baseline), \
                patch.object(checks, "scan", side_effect=[[finding, finding], [], []]):
            checks.update_baseline()
            loaded = checks.load_baseline()
        self.assertEqual(loaded["tflint"], Counter({finding.identity: 2}))
        self.assertEqual(loaded["trivy"], Counter())
        self.assertFalse(baseline.with_suffix(".txt.tmp").exists())


if __name__ == "__main__":
    unittest.main()
