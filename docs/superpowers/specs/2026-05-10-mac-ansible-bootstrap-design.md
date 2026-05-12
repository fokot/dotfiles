# Mac Ansible Bootstrap

Automate Mac setup from `README.md` with an Ansible playbook, plus a bootstrap shell script that installs Homebrew and Ansible before running it.

## Goals

- Single command takes a fresh Mac from "Xcode CLT installed" to "configured per `README.md`".
- Idempotent: safe to re-run.
- Manual steps from `README.md` that depend on GUI (Terminal font selection, `p10k configure`, choosing a Java version) remain manual.

## File layout

All files at project root:

- `bootstrap-mac.sh` — installs Homebrew (if missing) and Ansible, then runs the playbook.
- `playbook.yml` — single playbook, `hosts: localhost`, `connection: local`.
- `templates/zshrc.block.j2` — content of the Ansible-managed block appended to `~/.zshrc`.

## Bootstrap script (`bootstrap-mac.sh`)

Bash, `set -euo pipefail`. Steps:

1. **Check Xcode Command Line Tools.** If `xcode-select -p` fails, print instructions to run `xcode-select --install` and exit non-zero. (We don't trigger the GUI installer because it blocks on user interaction.)
2. **Install Homebrew** if `command -v brew` fails, using the official curl installer. After install, eval `/opt/homebrew/bin/brew shellenv` so `brew` is on PATH for the rest of the script.
3. **Install Ansible** via `brew install ansible` if not present.
4. **Run the playbook:** `ansible-playbook playbook.yml`. No `--ask-become-pass` — none of the tasks need sudo.

## Playbook (`playbook.yml`)

`hosts: localhost`, `connection: local`, `gather_facts: yes`.

Tasks (each named, idempotent):

1. **Tap `sdkman/tap`** — `community.general.homebrew_tap`.
2. **Install Homebrew formulas** — `community.general.homebrew` with list: `sdkman-cli`, `nvm`, `fzf`, `gnupg`, `libpq`, `mas`.
3. **Install Homebrew casks** — `community.general.homebrew_cask` with list: `raycast`, `jetbrains-toolbox`, `font-sauce-code-pro-nerd-font`, `google-chrome`, `freelens`, `headlamp`.
3a. **Install App Store apps via `mas`** — `ansible.builtin.command` with `mas install <id>` for each: Slack (`803453959`), WhatsApp (`1147396723`). Use `mas list | grep <id>` as the `creates`-equivalent guard (via `register` + `when`) so re-runs are no-ops. Caveat: first install of an app never associated with the user's Apple ID will fail; the failure message tells the user to install once manually from the App Store, then re-run the playbook. The exact App Store IDs will be verified against `mas search` during implementation.
4. **Run fzf install script** — `ansible.builtin.command` invoking `/opt/homebrew/opt/fzf/install --all --no-update-rc`. Uses `creates:` on `~/.fzf.zsh` so it only runs once. The `--no-update-rc` flag prevents fzf from editing `~/.zshrc` (we manage that block ourselves).
5. **Install oh-my-zsh** — `ansible.builtin.shell` running the official curl installer with `RUNZSH=no CHSH=no` env vars. Guarded by `creates: ~/.oh-my-zsh`.
6. **Clone powerlevel10k** — `ansible.builtin.git` to `~/.oh-my-zsh/custom/themes/powerlevel10k`, `depth: 1`, `update: no` (don't auto-pull on re-runs).
7. **Manage `~/.zshrc` block** — `ansible.builtin.blockinfile`, `create: yes`, marker `# {mark} ANSIBLE MANAGED BLOCK — mac bootstrap`, content from `templates/zshrc.block.j2`.
8. **Set `ZSH_THEME` to powerlevel10k** — `ansible.builtin.lineinfile` on `~/.zshrc`, regexp `^ZSH_THEME=`, line `ZSH_THEME="powerlevel10k/powerlevel10k"`. This replaces the default `ZSH_THEME="robbyrussell"` line that the oh-my-zsh installer writes. Done as a separate task (not via `blockinfile`) because `ZSH_THEME` must be set *before* oh-my-zsh is sourced — i.e., the line has to live in its original position in the file, not appended at the end.
9. **Set git pull-current alias** — `community.general.git_config`, `scope: global`, `name: alias.pull-current`, `value: !git pull origin $(git branch --show-current)`.

Homebrew prefix is hardcoded to `/opt/homebrew` (Apple Silicon assumption — simpler than detecting at runtime).

## `templates/zshrc.block.j2`

```sh
export PATH=/opt/homebrew/bin:$PATH

export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

source $(brew --prefix nvm)/nvm.sh
```

## Idempotency notes

- Homebrew install: official installer detects existing install and exits cleanly.
- oh-my-zsh: guarded by `creates: ~/.oh-my-zsh`.
- powerlevel10k: `update: no` prevents re-pull churn.
- fzf install: guarded by `creates: ~/.fzf.zsh`.
- `blockinfile`: replaces same-marker block on re-run.
- `lineinfile` for `ZSH_THEME`: regexp match replaces in place.
- `git_config`: native idempotency.

## Out of scope

- Xcode Command Line Tools auto-install (script prints instructions and exits).
- Terminal.app font selection (GUI-only).
- `p10k configure` (interactive wizard).
- `sdk install java <version>` (version choice is per-machine).
- Bash-it migration content and `manjaro-init.sh` (Linux-only legacy).
- `pinentry-mac` (README says "if needed" — left manual).
- `~/.p10k.zsh` content.
