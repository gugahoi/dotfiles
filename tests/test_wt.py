"""Integration tests for wt's picker and deletion helpers (no network or tmux needed).

Run: python3 -m unittest discover -s tests -p 'test_wt.py'
"""

from pathlib import Path
import re
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / ".local/bin/wt"


class WorktreePickerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="wt-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.remote = self.root / "remote.git"
        self.run_command("git", "init", "--bare", "-q", "-b", "main", str(self.remote))
        self.git("init", "-q", "-b", "main")
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.com")
        self.git("commit", "-q", "--allow-empty", "-m", "base")
        self.git("remote", "add", "origin", str(self.remote))
        self.git("push", "-q", "-u", "origin", "main")
        self.git("remote", "set-head", "origin", "main")
        self.library = self.root / "wt-functions"
        self.library.write_text(SCRIPT.read_text().split("# Main command dispatcher")[0])

    def run_command(self, *args, **kwargs):
        return subprocess.run(
            args, cwd=self.repo, text=True, capture_output=True, check=True, **kwargs
        ).stdout.strip()

    def git(self, *args):
        return self.run_command("git", *args)

    def shell(self, body, *args):
        return self.run_command(
            "bash", "-c", 'source "$1"; shift\n' + body,
            "test", str(self.library), *args,
        )

    def rows(self):
        output = self.run_command(str(SCRIPT), "--list-branches")
        clean = re.sub(r"\x1b\[[0-9;]*m", "", output)
        return {fields[0]: fields[1:] for fields in map(lambda s: s.split("\t"), clean.splitlines())}

    def remote_branch(self, name):
        self.git("branch", name)
        self.git("push", "-q", "origin", name)
        self.git("branch", "-D", name)

    def delete_selected(self, ref, name, choice="Cancel"):
        # Mock only the interactive confirmation; execute real git deletion against
        # the disposable bare remote, and wait for wt's background deletion job.
        self.shell(
            'MOCK_CHOICE="$3"; fzf() { printf "%s\\n" "$MOCK_CHOICE"; }; '
            'cmd_delete_selected "$1" "$2"; wait',
            ref, name, choice,
        )

    def has_ref(self, ref, remote=False):
        args = ["git"]
        if remote:
            args += ["--git-dir=" + str(self.remote)]
        result = subprocess.run(
            args + ["show-ref", "--verify", "--quiet", ref], cwd=self.repo
        )
        return result.returncode == 0

    def test_remote_only_label_and_local_tip_precedence(self):
        self.remote_branch("remote-only")
        self.git("checkout", "-q", "-b", "both")
        self.git("push", "-q", "origin", "both")
        self.git("commit", "-q", "--allow-empty", "-m", "unmerged local work")
        self.git("checkout", "-q", "main")
        rows = self.rows()
        self.assertIn("[remote-only: origin/remote-only]", rows["remote-only"][0])
        self.assertEqual(rows["remote-only"][1], "refs/remotes/origin/remote-only")
        self.assertNotIn("remote-only", rows["both"][0])
        self.assertNotIn("[merged]", rows["both"][0])
        self.assertIn("last commit:", rows["both"][0])
        self.assertEqual(rows["both"][1], "refs/heads/both")
        self.assertNotIn("HEAD", rows)

    def test_local_deletion_preserves_remote_and_relabels_entry(self):
        self.git("branch", "both")
        self.git("push", "-q", "origin", "both")
        self.delete_selected("refs/heads/both", "both")
        self.assertFalse(self.has_ref("refs/heads/both"))
        self.assertTrue(self.has_ref("refs/heads/both", remote=True))
        self.assertIn("[remote-only: origin/both]", self.rows()["both"][0])

    def test_local_branch_without_worktree_is_deleted(self):
        self.git("branch", "local-only")
        self.delete_selected("refs/heads/local-only", "local-only")
        self.assertNotIn("local-only", self.rows())

    def test_worktree_deletion_still_works(self):
        worktree = self.root / "active"
        self.git("worktree", "add", "-q", "-b", "123-active", str(worktree))
        self.assertIn("123-active [wt]", self.rows())
        self.delete_selected("refs/heads/123-active", "123-active [wt]")
        self.assertFalse(worktree.exists())
        self.assertFalse(self.has_ref("refs/heads/123-active"))

    def test_cancel_or_abort_preserves_remote(self):
        self.remote_branch("keep")
        self.delete_selected("refs/remotes/origin/keep", "keep", "Cancel")
        self.shell('fzf() { return 130; }; cmd_delete_selected "$1" "$2"; wait',
                   "refs/remotes/origin/keep", "keep")
        self.assertTrue(self.has_ref("refs/heads/keep", remote=True))
        self.assertTrue(self.has_ref("refs/remotes/origin/keep"))

    def test_confirmed_remote_deletion_handles_slashes(self):
        self.remote_branch("feature/nested")
        self.delete_selected("refs/remotes/origin/feature/nested", "feature/nested", "Delete remote branch")
        self.assertFalse(self.has_ref("refs/heads/feature/nested", remote=True))
        self.assertFalse(self.has_ref("refs/remotes/origin/feature/nested"))
        self.assertNotIn("feature/nested", self.rows())

    def test_rejected_remote_deletion_is_visible_and_retryable(self):
        self.remote_branch("protected")
        hook = self.remote / "hooks/pre-receive"
        hook.write_text("#!/bin/sh\necho 'Deletion forbidden' >&2\nexit 1\n")
        hook.chmod(0o755)
        self.delete_selected("refs/remotes/origin/protected", "protected", "Delete remote branch")
        self.assertTrue(self.has_ref("refs/heads/protected", remote=True))
        self.assertTrue(self.has_ref("refs/remotes/origin/protected"))
        header = self.run_command(str(SCRIPT), "--header")
        self.assertIn("Deletion of 'protected' failed", header)
        self.assertIn("Deletion forbidden", header)
        pending = self.repo / ".git/wt-state/pending"
        self.assertEqual(list(pending.iterdir()), [])

    def test_local_deletion_failure_is_visible(self):
        # Simulate the branch becoming current between listing and deleting it.
        self.delete_selected("refs/heads/main", "main")
        self.assertTrue(self.has_ref("refs/heads/main"))
        self.assertIn("Deletion of 'main' failed", self.run_command(str(SCRIPT), "--header"))

    def test_other_remote_uses_exact_ref_for_deletion(self):
        self.remote_branch("topic")
        self.git("remote", "add", "upstream", str(self.remote))
        self.git("fetch", "-q", "upstream")
        self.assertIn("[remote-only: upstream/topic]", self.rows()["upstream/topic"][0])
        self.delete_selected("refs/remotes/upstream/topic", "upstream/topic", "Delete remote branch")
        self.assertFalse(self.has_ref("refs/heads/topic", remote=True))
        self.assertFalse(self.has_ref("refs/remotes/upstream/topic"))

    def test_remote_selection_switches_and_issue_markers_survive(self):
        self.remote_branch("123-topic")
        self.git("remote", "add", "upstream", str(self.remote))
        self.git("fetch", "-q", "upstream")
        row = self.rows()["upstream/123-topic"]
        selected = "upstream/123-topic\t" + "\t".join(row)
        output = self.shell(
            'unset TMUX; tmux() { printf "%s\\n" "$*"; }; switch_to_branch "$1"', selected
        )
        self.assertIn("new-session -A -s 123-topic", output)
        self.assertEqual(self.git("config", "branch.123-topic.remote"), "upstream")
        state = self.repo / ".git/wt-state"
        state.mkdir(exist_ok=True)
        (state / "issues").write_text("123\t2026-01-01\tTest issue\t\n")
        self.assertIn("#123 [wt]", self.shell("cmd_issue_lines"))


if __name__ == "__main__":
    unittest.main()
