"""Run with python3 -m unittest discover -s modules/update_batch_job_definition_step/tests.

Executes only the actual buildspec's jq command, without AWS calls.
"""

import copy
import json
import os
from pathlib import Path
import re
import subprocess
import unittest


SOURCE = "https://github.com/hmrc/platsec-ci-terraform"
IMAGE = "example/scanner:new"
DEFINITION = {
    "jobDefinitionName": "scanner-jd",
    "type": "container",
    "parameters": {"scan": "all"},
    "containerProperties": {"image": "example/scanner:old", "memory": 4096},
    "retryStrategy": {"attempts": 2},
    "timeout": {"attemptDurationSeconds": 7200},
    "platformCapabilities": ["FARGATE"],
    "propagateTags": True,
    "revision": 25,
    "status": "ACTIVE",
}


class RegistrationTagsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        buildspec = (Path(__file__).parents[1] / "assets/buildspec-deploy.yaml").read_text()
        cls.command = re.search(r'export NEW_JOB_DEF=\$\((.*?<<<"\$\{CURRENT_JOB_DEF\}")\)', buildspec, re.S).group(1)

    def register_payload(self, definition):
        result = subprocess.run(
            ["bash", "-c", self.command],
            input="",
            env={
                **os.environ,
                "CURRENT_JOB_DEF": json.dumps(definition),
                "NEW_IMAGE": IMAGE,
                "SOURCE_TAG": SOURCE,
            },
            text=True,
            capture_output=True,
            check=True,
        )
        return json.loads(result.stdout)

    def expected_payload(self, tags):
        expected = copy.deepcopy(DEFINITION)
        del expected["revision"]
        del expected["status"]
        expected["containerProperties"]["image"] = IMAGE
        expected["tags"] = tags
        return expected

    def test_existing_nonblank_source_and_other_fields_are_preserved(self):
        for source in ["https://github.com/hmrc/platsec-terraform/", "  existing-source  "]:
            with self.subTest(source=source):
                tags = {"source": source, "team": "platsec", "environment": "development"}
                definition = {**DEFINITION, "tags": tags}
                self.assertEqual(self.register_payload(definition), self.expected_payload(tags))

    def test_missing_or_blank_source_uses_provider_fallback(self):
        for tags in [
            None,
            {},
            {"team": "platsec"},
            {"source": None},
            {"source": ""},
            {"source": " \t\n", "team": "platsec"},
        ]:
            with self.subTest(tags=tags):
                definition = {**DEFINITION, "tags": tags}
                expected_tags = {**(tags or {}), "source": SOURCE}
                self.assertEqual(self.register_payload(definition), self.expected_payload(expected_tags))

    def test_absent_tags_get_source_and_null_optional_fields_are_omitted(self):
        definition = {**DEFINITION, "parameters": None, "timeout": None, "propagateTags": False}
        expected = self.expected_payload({"source": SOURCE})
        del expected["parameters"]
        del expected["timeout"]
        expected["propagateTags"] = False
        self.assertEqual(self.register_payload(definition), expected)


if __name__ == "__main__":
    unittest.main()
