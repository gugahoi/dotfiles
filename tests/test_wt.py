"""Integration tests for wt's picker, deletion and multiplexer helpers.

No network, tmux or Rex needed: tmux and rex are stubs on PATH that log their arguments.
Needs git, bash and jq (wt parses Rex's JSON with jq; without it the Rex tests fail, not skip).
Run: python3 -m unittest discover -s tests -p 'test_wt.py'
"""

import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / ".local/bin/wt"

# Inherited from the terminal running the tests; they would point wt at a live tmux or Rex.
SCRUBBED_ENV = ("TMUX", "TMUX_PANE", "REX_SESSION", "REX_BLOCK", "REX_CLIENT", "WT_MULTIPLEXER")

# The tools wt's helpers need, for PATHs that leave out tmux, rex or jq.
TOOLS = ("bash", "git", "awk", "sed", "grep", "sort", "tr", "cut", "cat", "mkdir", "rm", "mv",
         "mktemp", "readlink", "realpath", "touch", "curl", "jq")

# Trimmed from real --json output of rex 0.0.1793131181 (API revision 7).
REX_INSPECT = {
    "client": {"client_id": "client:01a1800a-b4f1-71d8-be7a-e38922f26a90", "info": {"kind": "app", "name": "Rex Beta"}},
    "actions": [
        {"name": "session.new", "kind": "client", "title": "New Session"},
        {"name": "session.select", "kind": "client", "title": "Go to Session", "args": {
            "type": "object", "required": ["session_id"],
            "properties": {"session_id": {"type": "string"}, "window_id": {"type": "string"}}}},
    ],
}
REX_WHOAMI_LIVE = {
    "rex_version": "0.0.1793131181-gdd9a20", "session_count": 1,
    "session_id": "session:01a17fee-578c-79ac-9f5b-e1594ece24e4",
    "window_id": "window:01a17ff4-aea6-7a3d-a9a5-c05238a0d8ca",
    "block_id": "block:01a17ff4-ae83-7b89-9991-87047c89f2e5",
}
REX_WHOAMI_STALE = {"rex_version": "0.0.1793131181-gdd9a20", "session_count": 1}

# One script stubs both tmux and rex, by the name it's run as. Every call is logged as a JSON
# array per line; files in $WT_STUB_DIR change the answers. rex's exit codes are the real ones.
STUB = r'''#!PYTHON
import json, os, sys
from pathlib import Path

state = Path(os.environ["WT_STUB_DIR"])
name, args = Path(sys.argv[0]).name, sys.argv[1:]
with open(state / "calls", "a") as log:
    log.write(json.dumps([name, *args]) + "\n")

def read(file, default):
    path = state / file
    return json.loads(path.read_text()) if path.exists() else default

def fail(file, code):
    if (state / file).exists():
        sys.stderr.write((state / file).read_text())
        sys.exit(code)

if name == "tmux":
    sys.exit(1 if args[0] == "has-session" and not (state / "tmux-has-session").exists() else 0)

while args[0].startswith("--"):
    args.pop(0)
if args[0] == "whoami":
    print(json.dumps(read("whoami.json", {})))
elif args[0] == "client":
    fail("client-error", 3)
    print(json.dumps(read("inspect.json", INSPECT)))
elif args[0] == "ls":
    print(json.dumps({"sessions": read("sessions.json", [])}))
elif args[0] == "new":
    sessions = read("sessions.json", [])
    session_id = "session:01a1801a-0000-7000-8000-%012d" % len(sessions)
    (state / "sessions.json").write_text(json.dumps(sessions + [{"session_id": session_id, "label": args[1]}]))
    fail("new-error", 1)
    print(json.dumps({"session_id": session_id, "initial_windows": [
        {"window_id": "window:01a1801a-0000-7000-8000-000000000000", "block_ids": [], "revision": 1}]}))
elif args[0] == "do":
    fail("do-error", 1)
'''.replace("PYTHON", sys.executable).replace("INSPECT", repr(REX_INSPECT))


class WtTestCase(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="wt-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.stubs = self.root / "stubs"
        self.stubs.mkdir()
        for name in ("tmux", "rex"):
            (self.stubs / name).write_text(STUB)
            (self.stubs / name).chmod(0o755)
        self.stub_state = self.root / "stub-state"
        self.stub_state.mkdir()
        self.env = {k: v for k, v in os.environ.items() if k not in SCRUBBED_ENV}
        self.env.update(PATH=f"{self.stubs}:{os.environ['PATH']}", WT_STUB_DIR=str(self.stub_state))
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

    def run_command(self, *args, cwd=None, env=None, check=True):
        result = subprocess.run(
            args, cwd=cwd or self.repo, env={**self.env, **(env or {})},
            text=True, capture_output=True, check=check,
        )
        return result if not check else result.stdout.strip()

    def git(self, *args):
        return self.run_command("git", *args)

    def shell(self, body, *args):
        return self.run_command(
            "bash", "-c", 'source "$1"; shift\n' + body,
            "test", str(self.library), *args,
        )

    def wt(self, body, *args, **env):
        """Runs body with wt's functions sourced, returning the completed process whatever its status."""
        return self.run_command(
            "bash", "-c", 'source "$1"; shift\n' + body,
            "test", str(self.library), *args, env=env, check=False,
        )

    def calls(self):
        log = self.stub_state / "calls"
        return [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []

    def stub(self, file, value):
        """Changes a stub's answer: a JSON value to return, or an error message to fail with."""
        (self.stub_state / file).write_text(value if isinstance(value, str) else json.dumps(value))

    def path_without(self, *missing):
        """A PATH with the tools wt needs and the tmux/rex stubs, except those missing."""
        path = self.root / ("path-without-" + "-".join(missing))
        if path.exists():
            return str(path)
        path.mkdir()
        for name in TOOLS + ("tmux", "rex"):
            found = shutil.which(name, path=self.env["PATH"])
            if name not in missing and found:
                (path / name).symlink_to(found)
        return str(path)

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


class WorktreePickerTests(WtTestCase):
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

    def test_issues_and_prs_are_newest_first(self):
        self.git("branch", "1-old")  # a branch no longer lifts its issue to the top
        issues = [{"number": n, "createdAt": c, "updatedAt": c, "title": "t", "labels": []}
                  for n, c in ((1, "2026-01-01"), (3, "2026-03-01"), (2, "2026-02-01"))]
        prs = [{"number": n, "createdAt": c, "updatedAt": c, "isDraft": d, "isCrossRepository": False,
                "headRefName": f"b{n}", "title": "t", "author": {"login": "me"}, "labels": []}
               for n, c, d in ((4, "2026-01-01", False), (5, "2026-02-01", True),
                               (6, "2026-03-01", False), (7, "2026-04-01", True))]
        output = self.shell(
            'issues=$1 prs=$2\n'
            'gh() { local json=$prs; [ "$1" = issue ] && json=$issues; jq -r "${@: -1}" <<<"$json"; }\n'
            'fetch_issues && fetch_prs && { cmd_lines issue; cmd_lines pr; } | cut -f2',
            json.dumps(issues), json.dumps(prs),
        )
        self.assertEqual(output.split(), ["3", "2", "1", "6", "4", "7", "5"])


class TmuxTests(WtTestCase):
    """tmux's arguments, as they were before wt supported other multiplexers."""

    def switch(self, **env):
        self.git("branch", "feature/x.y")
        result = self.wt('switch_to_branch "$1"', "feature/x.y", **env)
        self.assertEqual(result.returncode, 0, result.stderr)
        return str(self.repo / "feature/x.y")

    def clone(self, **env):
        self.run_command(str(SCRIPT), "clone", str(self.remote), "cloned", cwd=self.root, env=env)
        return str(self.root / "cloned/main")

    def test_switch_outside_tmux_attaches(self):
        path = self.switch()
        self.assertEqual(self.calls(), [["tmux", "new-session", "-A", "-s", "feature_x_y", "-c", path]])

    def test_switch_inside_tmux_creates_and_switches(self):
        path = self.switch(TMUX="/tmp/tmux-test,1,0")
        self.assertEqual(self.calls(), [
            ["tmux", "has-session", "-t", "=feature_x_y"],
            ["tmux", "new-session", "-d", "-s", "feature_x_y", "-c", path],
            ["tmux", "switch-client", "-t", "=feature_x_y"],
        ])

    def test_switch_inside_tmux_reuses_session(self):
        self.stub("tmux-has-session", "")
        self.switch(TMUX="/tmp/tmux-test,1,0")
        self.assertEqual(self.calls(), [
            ["tmux", "has-session", "-t", "=feature_x_y"],
            ["tmux", "switch-client", "-t", "=feature_x_y"],
        ])

    def test_clone_outside_tmux_attaches(self):
        path = self.clone()
        self.assertEqual(self.calls(), [["tmux", "new-session", "-A", "-s", "main", "-c", path]])

    def test_clone_inside_tmux_creates_and_switches(self):
        path = self.clone(TMUX="/tmp/tmux-test,1,0")
        self.assertEqual(self.calls(), [
            ["tmux", "has-session", "-t", "=main"],
            ["tmux", "new-session", "-d", "-s", "main", "-c", path],
            ["tmux", "switch-client", "-t", "=main"],
        ])


IN_TMUX = {"TMUX": "/tmp/tmux-test,1,0"}
IN_REX = {"REX_SESSION": REX_WHOAMI_LIVE["session_id"]}


class SelectionTests(WtTestCase):
    def pick(self, whoami=REX_WHOAMI_LIVE, **env):
        self.stub("whoami.json", whoami)
        result = self.wt('mux_preflight && echo "$MUX"', **env)
        return result.stdout.strip() if result.returncode == 0 else result.stderr

    def test_auto_selection(self):
        for name, env, whoami, expected in [
            ("unset, no context", {}, REX_WHOAMI_LIVE, "tmux"),
            ("auto, no context", {"WT_MULTIPLEXER": "auto"}, REX_WHOAMI_LIVE, "tmux"),
            ("tmux", IN_TMUX, REX_WHOAMI_LIVE, "tmux"),
            ("live Rex", IN_REX, REX_WHOAMI_LIVE, "rex"),
            ("stale Rex", IN_REX, REX_WHOAMI_STALE, "tmux"),
            ("tmux inside Rex", {**IN_TMUX, **IN_REX}, REX_WHOAMI_LIVE, "tmux"),
        ]:
            with self.subTest(name):
                self.assertEqual(self.pick(whoami, **env), expected)
        # Confirming a stale REX_SESSION must never start a Rex server
        whoami = [call for call in self.calls() if "whoami" in call]
        self.assertTrue(whoami)
        self.assertTrue(all(call[:2] == ["rex", "--autostart=false"] for call in whoami))

    def test_explicit_selection_wins(self):
        for name, env, expected in [
            ("tmux inside Rex", {**IN_REX, "WT_MULTIPLEXER": "tmux"}, "tmux"),
            ("Rex inside tmux", {**IN_TMUX, "WT_MULTIPLEXER": "rex"}, "rex"),
            ("Rex outside Rex", {"WT_MULTIPLEXER": "rex"}, "rex"),
        ]:
            with self.subTest(name):
                self.assertEqual(self.pick(**env), expected)

    def test_invalid_setting_fails(self):
        self.assertIn("WT_MULTIPLEXER must be auto, tmux or rex, not 'screen'", self.pick(WT_MULTIPLEXER="screen"))
        self.assertEqual(self.calls(), [])

    def test_rex_failure_never_falls_back_or_memoizes(self):
        self.stub("client-error", "Error: rex server is not running\n")
        result = self.wt('mux_preflight; echo "$?[$MUX]"; mux_preflight; echo "$?[$MUX]"', WT_MULTIPLEXER="rex", **IN_TMUX)
        self.assertEqual(result.stdout.split(), ["1[]", "1[]"])
        self.assertIn("rex server is not running", result.stderr)
        # Inside tmux, the error is also shown on its status line, but no tmux session is opened
        tmux = [call[:2] for call in self.calls() if call[0] == "tmux"]
        self.assertEqual(tmux, [["tmux", "display-message"]] * 2)


class PreflightTests(WtTestCase):
    """A multiplexer that can't open the worktree fails before wt changes anything."""

    def failures(self):
        no_select = {**REX_INSPECT, "actions": [a for a in REX_INSPECT["actions"] if a["name"] != "session.select"]}
        return [
            ("invalid setting", {"WT_MULTIPLEXER": "bogus"}, None, "WT_MULTIPLEXER must be"),
            ("tmux missing", {"WT_MULTIPLEXER": "tmux", "PATH": self.path_without("tmux")}, None, "tmux not found"),
            ("rex missing", {"WT_MULTIPLEXER": "rex", "PATH": self.path_without("rex")}, None, "needs rex and jq"),
            ("jq missing", {"WT_MULTIPLEXER": "rex", "PATH": self.path_without("jq")}, None, "needs rex and jq"),
            ("server down", {"WT_MULTIPLEXER": "rex"}, ("client-error", "Error: rex server is not running\n"),
             "rex server is not running"),
            ("ambiguous apps", {"WT_MULTIPLEXER": "rex"},
             ("client-error", "Error: 2 app clients are connected; choose one with -C\n"), "REX_CLIENT"),
            ("no session.select", {"WT_MULTIPLEXER": "rex"}, ("inspect.json", no_select), "no session.select"),
        ]

    def check(self, run, mutated):
        for name, env, stub, message in self.failures():
            with self.subTest(name):
                for file in self.stub_state.iterdir():
                    file.unlink()
                if stub:
                    self.stub(*stub)
                result = run(env)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(message, result.stderr)
                self.assertFalse(mutated())
                self.assertEqual([c for c in self.calls() if c[:2] in (["rex", "new"], ["rex", "do"])
                                  or c[0] == "tmux"], [])

    def test_switch(self):
        self.check(lambda env: self.wt('switch_to_branch new-branch', **env),
                   lambda: self.has_ref("refs/heads/new-branch") or (self.repo / "new-branch").exists())

    def test_clone(self):
        self.check(lambda env: self.run_command(str(SCRIPT), "clone", str(self.remote), "cloned",
                                                cwd=self.root, env=env, check=False),
                   lambda: (self.root / "cloned").exists())

    def test_pr(self):
        self.remote_branch("pr-branch")
        self.git("update-ref", "-d", "refs/remotes/origin/pr-branch")
        (self.repo / ".git/wt-state").mkdir()
        (self.repo / ".git/wt-state/prs").write_text("7\t2026-01-01T00:00:00Z\tfalse\tfalse\tpr-branch\tTitle\tme\t\n")
        self.check(lambda env: self.wt("open_pr 7", **env),
                   lambda: self.has_ref("refs/heads/pr-branch") or self.has_ref("refs/remotes/origin/pr-branch"))


class IsolationTests(WtTestCase):
    """Commands that don't open a worktree never need, or touch, a multiplexer."""

    def test_helpers_work_without_multiplexers_or_jq(self):
        env = {"PATH": self.path_without("tmux", "rex", "jq"), "WT_MULTIPLEXER": "bogus"}
        for args in (["--list-branches"], ["--header"], ["--lines", "issue"], ["list"], ["--help"]):
            with self.subTest(args):
                result = self.run_command(str(SCRIPT), *args, env=env, check=False)
                self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("WT_MULTIPLEXER", self.run_command(str(SCRIPT), "--help"))

    def test_deletion_never_calls_a_multiplexer(self):
        for branch in ("gone", "gone-too"):
            self.git("worktree", "add", "-q", "-b", branch, str(self.root / branch))
        self.delete_selected("refs/heads/gone", "gone [wt]")
        result = self.wt('fzf() { grep -F gone-too; }; cmd_delete <<<y', **IN_TMUX, **IN_REX)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.root / "gone").exists() or (self.root / "gone-too").exists())
        self.assertEqual(self.calls(), [])

    def test_cancelled_pickers_are_no_ops(self):
        (self.repo / ".git/wt-state").mkdir()
        (self.repo / ".git/wt-state/issues").write_text("5\t2026-01-01T00:00:00Z\tAn issue\t\n")
        env = {"PATH": self.path_without("rex", "jq"), "WT_MULTIPLEXER": "rex"}
        for body in ('fzf() { cat >/dev/null; return 130; }; cmd_switch', 'fzf() { return 130; }; cmd_github issue',
                     'fzf() { return 130; }; open_issue 5', 'switch_to_branch ""'):
            with self.subTest(body):
                result = self.wt(f'SCRIPT_PATH="$1"; {body}', str(SCRIPT), **env)
                self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [])

    def test_invalid_setting_fails_before_pickers(self):
        for body in ('cmd_switch', 'cmd_github issue'):
            with self.subTest(body):
                result = self.wt(f'fzf() {{ echo picker shown >&2; }}; {body}', WT_MULTIPLEXER="bogus")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("WT_MULTIPLEXER must be", result.stderr)
                self.assertNotIn("picker shown", result.stderr)


def git_hash(text):
    data = text.encode()
    return hashlib.sha1(b"blob %d\0" % len(data) + data).hexdigest()


class RexTests(WtTestCase):
    def setUp(self):
        super().setUp()
        self.worktree = str(self.repo / "feature/x.y")
        self.label = "repo-feature_x.y-" + git_hash(self.worktree)[:10]

    def switch(self, branch="feature/x.y", **env):
        return self.wt('switch_to_branch "$1"', branch, WT_MULTIPLEXER="rex", **env)

    def rex_calls(self):
        return [call[1:] for call in self.calls() if call[0] == "rex" and call[1:3] != ["--autostart=false", "client"]]

    def session(self, n):
        return "session:01a1801a-0000-7000-8000-%012d" % n

    def test_creates_session_then_reuses_it(self):
        result = self.switch()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.rex_calls(), [
            ["ls", "--json"],
            ["new", self.label, "-c", self.worktree, "--json"],
            ["do", "session.select", f"session_id={self.session(0)}"],
        ])
        (self.stub_state / "calls").unlink()
        self.assertEqual(self.switch().returncode, 0)
        self.assertEqual(self.rex_calls(), [["ls", "--json"], ["do", "session.select", f"session_id={self.session(0)}"]])

    def test_symlinked_path_reuses_session(self):
        self.switch()
        (self.root / "alias").symlink_to(self.worktree)
        (self.stub_state / "calls").unlink()
        result = self.wt('mux_open_worktree "$1" feature/x.y', str(self.root / "alias"), WT_MULTIPLEXER="rex")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.rex_calls(), [["ls", "--json"], ["do", "session.select", f"session_id={self.session(0)}"]])

    def test_prefix_matches_are_not_reused(self):
        self.stub("sessions.json", [
            {"session_id": "session:prefix", "label": self.label[:-1]},
            {"session_id": "session:longer", "label": self.label + "-2"},
            {"session_id": "session:no-hash", "label": "repo-feature_x.y"},
        ])
        self.assertEqual(self.switch().returncode, 0)
        self.assertIn(["new", self.label, "-c", self.worktree, "--json"], self.rex_calls())
        self.assertEqual(self.rex_calls()[-1], ["do", "session.select", f"session_id={self.session(3)}"])

    def test_duplicate_labels_fail(self):
        self.stub("sessions.json", [{"session_id": "session:a", "label": self.label},
                                    {"session_id": "session:b", "label": self.label}])
        result = self.switch()
        self.assertEqual(result.returncode, 1)
        self.assertIn(f"wt: worktree ready at {self.worktree}; Rex session could not be opened: "
                      f"several sessions are labelled {self.label}: session:a, session:b", result.stderr)
        self.assertEqual(self.rex_calls(), [["ls", "--json"]])
        self.assertTrue(Path(self.worktree).is_dir())

    def test_uncertain_creation_reuses_created_session(self):
        self.stub("new-error", "Error: timed out\n")
        result = self.switch()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.rex_calls(), [
            ["ls", "--json"],
            ["new", self.label, "-c", self.worktree, "--json"],
            ["ls", "--json"],
            ["do", "session.select", f"session_id={self.session(0)}"],
        ])

    def test_activation_failure_keeps_worktree(self):
        self.stub("do-error", "Error: The operation couldn't be completed.\n")
        result = self.switch()
        self.assertEqual(result.returncode, 1)
        self.assertIn(f"wt: worktree ready at {self.worktree}; Rex session could not be opened: "
                      f"can't show session {self.session(0)}: Error: The operation", result.stderr)
        self.assertTrue(Path(self.worktree).is_dir())
        self.assertTrue(self.has_ref("refs/heads/feature/x.y"))

    def test_quotes_paths_with_spaces(self):
        worktree = self.root / "dir with space/feature.a"
        self.git("worktree", "add", "-q", "-b", "feature/a.b", str(worktree))
        self.assertEqual(self.switch("feature/a.b").returncode, 0)
        label = "repo-feature_a.b-" + git_hash(str(worktree))[:10]
        self.assertIn(["new", label, "-c", str(worktree), "--json"], self.rex_calls())

    def test_labels(self):
        for repo in ("a/app", "b/app"):
            self.run_command("git", "init", "-q", "-b", "main", str(self.root / repo))
        label = 'rex_label "$1" "$2"'
        a = self.shell(label, str(self.root / "a/app"), "main")
        b = self.shell(label, str(self.root / "b/app"), "main")
        self.assertEqual(a, "app-main-" + git_hash(str(self.root / "a/app"))[:10])
        self.assertNotEqual(a, b)
        long = self.shell(label, str(self.root / "a/app"), "x" * 200)
        self.assertEqual(len(long), 111)
        self.assertTrue(long.endswith("-" + git_hash(str(self.root / "a/app"))[:10]))


if __name__ == "__main__":
    unittest.main()
