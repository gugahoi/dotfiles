# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

- **nvim** - Neovim configuration
- **tmux** - Tmux configuration
- **zsh** - Zsh configuration
- **gh** - GitHub CLI configuration
- **pi** - Pi coding agent extensions and config (`.config/pi/`)
- **.claude** - Claude Code hooks and scripts
- **focus-blocker** - Sink social-media domains in `/etc/hosts` on the Work Focus
- **Brewfile** - Homebrew package list

## Installation

### Prerequisites

Ensure you have GNU Stow installed:

```bash
brew install stow
```

Clone this repository to your home directory or a dedicated location:

```bash
git clone https://github.com/gugahoi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### Setup

Use Stow to create symlinks for configuration files:

```bash
# Stow all packages
stow .

# If files already exist locally, adopt them into this repo and restow
stow --adopt -R .
```

> **Note:** Stow's default target is the parent directory of wherever the repo
> lives. If you clone this repo somewhere other than directly under `$HOME`
> (e.g. `~/Projects/dotfiles` instead of `~/dotfiles`), you must set the
> target explicitly or symlinks will land in the wrong place:
>
> ```bash
> stow -t ~ .
> ```

This will create symlinks from the repository files to their target locations in your home directory (e.g., `.config/nvim`, `.config/pi/extensions`, `.zshrc`, etc.).

## Managing Files

### Add a New Configuration

1. Place the configuration file in the appropriate directory structure within this repository
2. Run `stow <package-name>` to create symlinks
3. Commit your changes:

```bash
git add .
git commit -m "Add/update <package> configuration"
git push
```

### Update an Existing Configuration

Since the files are symlinked, changes made in `~/.config` or `~/.<file>` will directly modify the files in this repository. Simply commit your changes:

```bash
git add .
git commit -m "Update <package> configuration"
git push
```

### Remove a Configuration

If you no longer want a package symlinked:

```bash
stow -D <package-name>
```

This removes the symlinks without deleting the files from the repository.

## How Stow Works

Stow uses a simple structure:
- Files in this repository should mirror the directory structure of your home directory
- When you run `stow`, it creates symlinks from the repo to your home directory
- For example: `dotfiles/.config/nvim/init.lua` → `~/.config/nvim/init.lua`

## Dotfiles Directory Structure

```
dotfiles/
├── .config/
│   ├── nvim/          # Neovim config
│   ├── gh/            # GitHub CLI config
│   ├── focus-blocker/ # Social-media blocklist for Focus modes
│   └── pi/            # Pi coding agent config
│       └── extensions/ # Pi extensions (plan-mode, subagent, etc.)
├── .local/bin/        # Personal scripts on PATH (focus-blocker, wt, ...)
├── .tmux.conf         # Tmux configuration
├── .zshrc             # Zsh configuration
├── .exports           # Env vars (incl. PI_CODING_AGENT_DIR)
├── .gitconfig         # Git configuration
├── Brewfile           # Homebrew packages
└── README.md
```

## Useful Stow Commands

```bash
# Simulate stowing without creating symlinks (dry-run)
stow -n .

# Show what stow would do
stow -v .

# Unstow a package
stow -D .

# Adopt existing files into the stow directory and restow
stow --adopt -R .
```

## Troubleshooting

### Symlink conflicts

If Stow reports conflicts, it means files already exist in your home directory that conflict with the symlinks. You can:

1. Delete the existing file if it's redundant
2. Manually merge the content if needed
3. Use `stow --adopt` to move existing files into the stow directory

### Checking current symlinks

```bash
# See what's currently symlinked
ls -la ~/.config/nvim
ls -la ~/.zshrc
```

## Pi Coding Agent Layout

Pi's config lives under `.config/pi/` and is pointed at by `PI_CODING_AGENT_DIR`
(set in `.exports`):

```sh
export PI_CODING_AGENT_DIR="$HOME/.config/pi"
```

Pi treats that directory as its **agent dir** and discovers resources at fixed
sub-paths directly beneath it:

| Resource   | Path pi reads                    |
|------------|----------------------------------|
| Extensions | `~/.config/pi/extensions/`       |
| Settings   | `~/.config/pi/settings.json`     |
| Sessions   | `~/.config/pi/sessions/`         |
| Auth       | `~/.config/pi/auth.json` (local, gitignored) |

> **Gotcha:** extensions must sit at `.config/pi/extensions/`, **not**
> `.config/pi/agent/extensions/`. The extra `agent/` layer only applies to pi's
> *default* dir (`~/.pi/agent`); since `PI_CODING_AGENT_DIR` already points at
> `.config/pi`, nesting them under `agent/` makes pi silently find zero
> extensions (no `/plan`, etc.). After adding or moving extensions, run
> `/reload` in pi or restart it.

Each extension is either a single `*.ts` file or a directory with an
`index.ts`. Current extensions: `plan-mode`, `subagent`,
`github-issue-autocomplete`, `questionnaire`.

## Focus Blocker

Redirects distracting domains to `0.0.0.0` in `/etc/hosts` (and flushes the DNS
cache) while the macOS **Work** Focus is on, and restores them when it turns
off. Hardened: the passwordless-sudo rule points at **root-owned copies**, not
at scripts inside this (user-writable) repo.

**Files**

| Repo file (Stow source) | Installed to (root-owned) | Purpose |
|-------------------------|---------------------------|---------|
| `.local/bin/focus-blocker` | `/usr/local/bin/focus-blocker` (`root:wheel 0755`) | `enable`/`disable`/`status` |
| `.config/focus-blocker/blocklist.txt` | `/usr/local/etc/focus-blocker/blocklist.txt` (`root:wheel 0644`) | domains to block (one per line, `#` comments) |
| `.local/bin/setup-focus-blocker` | *(run in place)* | installs the two copies + sudo rule |

Stow first symlinks the sources into `~/.local/bin` and `~/.config`;
`setup-focus-blocker` then copies them into the root-owned locations above.

### Install

```bash
stow -t ~ .            # symlink the script, setup script, and blocklist
setup-focus-blocker    # copy root-owned binary + blocklist, add sudo rule
```

`setup-focus-blocker` copies the script to `/usr/local/bin/focus-blocker` and
the blocklist to `/usr/local/etc/focus-blocker/`, both `root:wheel`, then
installs `/etc/sudoers.d/focus-blocker` granting passwordless sudo for the exact
`enable` and `disable` invocations only (validated with `visudo` first). It
refuses to run if `/usr/local/bin` is user-writable. Test it:

```bash
sudo focus-blocker enable
focus-blocker status     # no sudo needed (reads world-readable /etc/hosts)
sudo focus-blocker disable
```

> **Why copies, not symlinks:** a passwordless-sudo rule pointing at a symlink
> into this (user-writable) repo would let anything running as you rewrite the
> script and gain root without a prompt. Copying into a root-owned dir means the
> executed code can't be altered by a user-level process.
>
> **Re-sync after edits:** the root-owned copies are what actually run, so after
> editing the script or `blocklist.txt` in this repo, re-run
> `setup-focus-blocker` (one password prompt) to push the changes live.
>
> **Maximum hardening (optional):** to drop the passwordless-sudo rule entirely,
> use a root `launchd` daemon that watches a user-writable trigger file the
> Shortcut writes with no sudo. Stronger, but more moving parts.

### Wire it to the Work Focus (Shortcuts)

1. **Shortcuts app → two shortcuts**, each a single **Run Shell Script** action:
   - *Work Focus - Block*: `sudo /usr/local/bin/focus-blocker enable`
   - *Work Focus - Unblock*: `sudo /usr/local/bin/focus-blocker disable`
2. **Automations tab → +**:
   - *When Work turns On* → Run *Work Focus - Block* (Run Immediately, notify off)
   - *When Work turns Off* → Run *Work Focus - Unblock* (Run Immediately, notify off)

### Browser DoH caveat

Firefox / Zen can use **DNS over HTTPS**, which bypasses `/etc/hosts`. Under
*Settings → Privacy & Security → DNS over HTTPS*, set it to **Default** or
**Off** so lookups go through the system resolver and the block takes effect.

## Notes

- Keep your dotfiles in version control for easy backup and portability
- Test changes on a new system or in a virtual environment first
- Some applications may cache configs; restart them to see changes take effect
