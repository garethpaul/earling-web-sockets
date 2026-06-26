#!/usr/bin/env python3
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class MakefileAuthorityTests(unittest.TestCase):
    def run_make(self, *arguments):
        return subprocess.run(
            [
                "make",
                "--no-print-directory",
                "-f",
                str(ROOT / "Makefile"),
                *arguments,
            ],
            cwd=ROOT.parent,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=False,
            env={"PATH": os.environ.get("PATH", "")},
        )

    def test_later_makefile_cannot_replace_or_append_public_recipes(self):
        for separator in (":", "::"):
            with self.subTest(separator=separator), tempfile.TemporaryDirectory() as directory:
                temporary = Path(directory)
                marker = temporary / "later-recipe-ran"
                later_makefile = temporary / "later.mk"
                later_makefile.write_text(
                    (
                        "all deps compile lint test security-test verify check "
                        f"check-tools force{separator}\n\t@touch '{marker}'\n"
                    ),
                    encoding="utf-8",
                )

                result = self.run_make("-f", str(later_makefile), "check")

                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertFalse(marker.exists(), result.stdout)

    def test_non_executing_and_error_ignoring_modes_fail_closed(self):
        for flag in (
            "-n",
            "--just-print",
            "--dry-run",
            "--recon",
            "-t",
            "--touch",
            "-q",
            "--question",
            "-i",
            "--ignore-errors",
        ):
            with self.subTest(flag=flag):
                result = self.run_make(flag, "check")
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn(
                    "non-executing or error-ignoring MAKEFLAGS are not supported",
                    result.stdout,
                )

    def test_make_invocation_variable_overrides_fail_closed(self):
        for variable, diagnostic in (
            ("MAKEFLAGS=-n", "MAKEFLAGS must not be overridden"),
            (
                "MAKEFILES=/tmp/untrusted",
                "MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone",
            ),
            ("MAKEFILE_LIST=/tmp/untrusted", "MAKEFILE_LIST must not be overridden"),
        ):
            with self.subTest(variable=variable):
                result = self.run_make("check", variable)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn(diagnostic, result.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
