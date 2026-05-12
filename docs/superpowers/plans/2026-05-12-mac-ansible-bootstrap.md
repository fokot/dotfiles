# Mac Ansible Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate Mac setup from `README.md` via a single Ansible playbook plus a bootstrap shell script that installs Homebrew and Ansible.

**Architecture:** A POSIX shell bootstrap script handles the chicken-and-egg problem (Homebrew/Ansible not yet installed) and performs prerequisite checks (Xcode CLT, App Store sign-in). The Ansible playbook then runs against `localhost` to install all formulas, casks, App Store apps, shell tooling, and writes a managed block to `~/.zshrc`. Apple-Silicon-only: Homebrew prefix is hardcoded to `/opt/homebrew`.

**Tech Stack:** Bash, Ansible (`community.general` collection bundled with `brew install ansible`), Homebrew, `mas` (Mac App Store CLI).

**Spec:** `docs/superpowers/specs/2026-05-10-mac-ansible-bootstrap-design.md`

---

## File Structure

All new files live at the project root:

- `bootstrap-mac.sh` — entry-point shell script. Handles pre-checks (Xcode CLT, brew, ansible, mas, App Store sign-in) and runs the playbook.
- `playbook.yml` — single Ansible playbook with all configuration tasks.
- `templates/zshrc.block.j2` — content of the Ansible-managed block appended to `~/.zshrc`.

No existing files are modified.

---

## Task 1: Create the zshrc template and bootstrap script

**Files:**
- Create: `templates/zshrc.block.j2`
- Create: `bootstrap-mac.sh`

- [ ] **Step 1.1: Create the templates directory and zshrc template**

Create `templates/zshrc.block.j2` with this exact content:

```sh
export PATH=/opt/homebrew/bin:$PATH

export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

source $(brew --prefix nvm)/nvm.sh
```

Note: there are no Jinja2 variables in this template — the `$(...)` syntax is shell command substitution, not Jinja. The file uses the `.j2` extension for convention and future flexibility.

- [ ] **Step 1.2: Create the bootstrap script**

Create `bootstrap-mac.sh` with this exact content:

```bash
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! xcode-select -p &>/dev/null; then
    echo "Xcode Command Line Tools not found. Install them first:"
    echo "  xcode-select --install"
    exit 1
fi

if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v ansible-playbook &>/dev/null; then
    echo "==> Installing Ansible..."
    brew install ansible
fi

if ! command -v mas &>/dev/null; then
    echo "==> Installing mas..."
    brew install mas
fi

echo "==> Checking App Store sign-in..."
if ! mas account &>/dev/null; then
    echo "Error: Not signed in to the App Store."
    echo "Open the App Store app, sign in with your Apple ID, then re-run this script."
    exit 1
fi

echo "==> Running playbook..."
ansible-playbook playbook.yml
```

- [ ] **Step 1.3: Make the bootstrap script executable**

Run:
```bash
chmod +x bootstrap-mac.sh
```

Verify:
```bash
ls -l bootstrap-mac.sh
```
Expected: `-rwxr-xr-x` permission prefix.

- [ ] **Step 1.4: Syntax-check the bootstrap script**

Run:
```bash
bash -n bootstrap-mac.sh
```
Expected: no output, exit code 0.

- [ ] **Step 1.5: Commit**

```bash
git add bootstrap-mac.sh templates/zshrc.block.j2
git commit -m "Add bootstrap script and zshrc template"
```

---

## Task 2: Write the playbook skeleton with package installs

**Files:**
- Create: `playbook.yml`

- [ ] **Step 2.1: Create `playbook.yml` with header, taps, formulas, and casks**

Create `playbook.yml` with this exact content:

```yaml
---
- name: Configure macOS
  hosts: localhost
  connection: local
  gather_facts: yes

  vars:
    brew_prefix: /opt/homebrew

  tasks:
    - name: Tap sdkman/tap
      community.general.homebrew_tap:
        name: sdkman/tap

    - name: Install Homebrew formulas
      community.general.homebrew:
        name:
          - sdkman-cli
          - nvm
          - fzf
          - gnupg
          - libpq
          - mas
          - kubernetes-cli
          - kubectx
        state: present

    - name: Install Homebrew casks
      community.general.homebrew_cask:
        name:
          - raycast
          - jetbrains-toolbox
          - font-sauce-code-pro-nerd-font
          - google-chrome
          - freelens
          - headlamp
        state: present
```

- [ ] **Step 2.2: Syntax-check the playbook**

Run:
```bash
ansible-playbook --syntax-check playbook.yml
```
Expected: `playbook: playbook.yml` and exit code 0.

If `ansible-playbook` is not installed, install with `brew install ansible` first.

- [ ] **Step 2.3: Commit**

```bash
git add playbook.yml
git commit -m "Add playbook skeleton with Homebrew taps, formulas, and casks"
```

---

## Task 3: Add App Store apps, kubectl plugin symlinks, and Claude Code

**Files:**
- Modify: `playbook.yml` (append tasks)

- [ ] **Step 3.1: Append App Store install tasks to `playbook.yml`**

Append the following block to the `tasks:` list in `playbook.yml`, after the "Install Homebrew casks" task:

```yaml
    - name: List installed App Store apps
      ansible.builtin.command: mas list
      register: mas_list
      changed_when: false

    - name: Install Slack from App Store
      ansible.builtin.command: mas install 803453959
      when: "'803453959' not in mas_list.stdout"

    - name: Install WhatsApp from App Store
      ansible.builtin.command: mas install 1147396723
      when: "'1147396723' not in mas_list.stdout"
```

If `mas install` fails with "Could not find app", verify the IDs with:
```bash
mas search Slack
mas search WhatsApp
```
and update the IDs in the playbook.

- [ ] **Step 3.2: Append kubectl plugin symlink tasks**

Append to the `tasks:` list, after the App Store tasks:

```yaml
    - name: Symlink kubectx as kubectl-ctx
      ansible.builtin.file:
        src: "{{ brew_prefix }}/bin/kubectx"
        dest: "{{ brew_prefix }}/bin/kubectl-ctx"
        state: link

    - name: Symlink kubens as kubectl-ns
      ansible.builtin.file:
        src: "{{ brew_prefix }}/bin/kubens"
        dest: "{{ brew_prefix }}/bin/kubectl-ns"
        state: link
```

- [ ] **Step 3.3: Append Claude Code install task**

Append to the `tasks:` list, after the symlink tasks:

```yaml
    - name: Install Claude Code
      ansible.builtin.shell: curl -fsSL https://claude.ai/install.sh | bash
      args:
        creates: "{{ ansible_env.HOME }}/.local/bin/claude"
```

Note: `~/.local/bin/claude` is the expected install path for the Claude Code native installer. If the installer writes elsewhere, update the `creates:` path so re-runs are idempotent (verify by running the installer once and `which claude`).

- [ ] **Step 3.4: Syntax-check the playbook**

Run:
```bash
ansible-playbook --syntax-check playbook.yml
```
Expected: exit code 0.

- [ ] **Step 3.5: Commit**

```bash
git add playbook.yml
git commit -m "Add App Store, kubectl plugin symlinks, Claude Code"
```

---

## Task 4: Add shell environment setup (oh-my-zsh, powerlevel10k, fzf, zshrc)

**Files:**
- Modify: `playbook.yml` (append tasks)

The order in this task matters: `oh-my-zsh` install must come before any task that edits `~/.zshrc`, because the official oh-my-zsh installer writes a fresh `~/.zshrc` if one doesn't already exist (and skips if it does). If we edited `~/.zshrc` first, oh-my-zsh would never write its template (so no `source $ZSH/oh-my-zsh.sh` line, so no theme loading).

- [ ] **Step 4.1: Append fzf install task**

Append to the `tasks:` list, after the Claude Code task:

```yaml
    - name: Run fzf install script
      ansible.builtin.command: "{{ brew_prefix }}/opt/fzf/install --all --no-update-rc"
      args:
        creates: "{{ ansible_env.HOME }}/.fzf.zsh"
```

`--all` accepts all defaults (key bindings, fuzzy completion). `--no-update-rc` prevents fzf from editing `~/.zshrc` directly; instead, fzf writes its key bindings to `~/.fzf.zsh`, and our managed block (step 4.5) sources that file.

- [ ] **Step 4.2: Append oh-my-zsh install task**

Append to the `tasks:` list:

```yaml
    - name: Install oh-my-zsh
      ansible.builtin.shell: 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
      args:
        creates: "{{ ansible_env.HOME }}/.oh-my-zsh"
      environment:
        RUNZSH: 'no'
        CHSH: 'no'
```

The `--unattended` flag, plus `RUNZSH=no` and `CHSH=no`, ensure the installer doesn't try to launch zsh interactively or call `chsh`. The `creates:` guard prevents re-runs.

- [ ] **Step 4.3: Append powerlevel10k clone task**

Append to the `tasks:` list:

```yaml
    - name: Clone powerlevel10k theme
      ansible.builtin.git:
        repo: https://github.com/romkatv/powerlevel10k.git
        dest: "{{ ansible_env.HOME }}/.oh-my-zsh/custom/themes/powerlevel10k"
        depth: 1
        update: no
```

`update: no` prevents Ansible from auto-pulling on re-runs.

- [ ] **Step 4.4: Append `ZSH_THEME` lineinfile task**

Append to the `tasks:` list:

```yaml
    - name: Set ZSH_THEME to powerlevel10k
      ansible.builtin.lineinfile:
        path: "{{ ansible_env.HOME }}/.zshrc"
        regexp: '^ZSH_THEME='
        line: 'ZSH_THEME="powerlevel10k/powerlevel10k"'
```

This replaces the default `ZSH_THEME="robbyrussell"` line the oh-my-zsh installer wrote. The regexp `^ZSH_THEME=` matches any existing `ZSH_THEME=...` line. Idempotent — re-runs match the existing replacement line.

- [ ] **Step 4.5: Update `templates/zshrc.block.j2` to source fzf, then append blockinfile task**

First, edit `templates/zshrc.block.j2` to append a line sourcing `~/.fzf.zsh` (created in step 4.1). The full template becomes:

```sh
export PATH=/opt/homebrew/bin:$PATH

export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

source $(brew --prefix nvm)/nvm.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```

Then append the blockinfile task to `playbook.yml`:

```yaml
    - name: Manage zshrc block
      ansible.builtin.blockinfile:
        path: "{{ ansible_env.HOME }}/.zshrc"
        marker: "# {mark} ANSIBLE MANAGED BLOCK — mac bootstrap"
        block: "{{ lookup('ansible.builtin.template', 'templates/zshrc.block.j2') }}"
        create: yes
```

`create: yes` is a safety net — by this point oh-my-zsh has already created `~/.zshrc`, but if for some reason it hasn't, blockinfile will create the file. The marker uses an em dash to make it visually distinct in `~/.zshrc`.

- [ ] **Step 4.6: Syntax-check the playbook**

Run:
```bash
ansible-playbook --syntax-check playbook.yml
```
Expected: exit code 0.

- [ ] **Step 4.7: Commit**

```bash
git add playbook.yml templates/zshrc.block.j2
git commit -m "Add oh-my-zsh, powerlevel10k, fzf, and zshrc management"
```

---

## Task 5: Add git alias and verify everything

**Files:**
- Modify: `playbook.yml` (append final task)

- [ ] **Step 5.1: Append git alias task to `playbook.yml`**

Append to the `tasks:` list:

```yaml
    - name: Set git pull-current alias
      community.general.git_config:
        scope: global
        name: alias.pull-current
        value: '!git pull origin $(git branch --show-current)'
```

The single quotes around the value are required because the value contains `$()` (shell substitution) and `git config` stores the literal string — Ansible should pass it through unchanged.

- [ ] **Step 5.2: Full syntax check**

Run:
```bash
ansible-playbook --syntax-check playbook.yml
```
Expected: exit code 0.

- [ ] **Step 5.3: Verify the final task list**

Run:
```bash
ansible-playbook --list-tasks playbook.yml
```
Expected output should list these tasks in order:

```
    Tap sdkman/tap
    Install Homebrew formulas
    Install Homebrew casks
    List installed App Store apps
    Install Slack from App Store
    Install WhatsApp from App Store
    Symlink kubectx as kubectl-ctx
    Symlink kubens as kubectl-ns
    Install Claude Code
    Run fzf install script
    Install oh-my-zsh
    Clone powerlevel10k theme
    Set ZSH_THEME to powerlevel10k
    Manage zshrc block
    Set git pull-current alias
```

- [ ] **Step 5.4: Commit**

```bash
git add playbook.yml
git commit -m "Add git pull-current alias"
```

---

## Verification on a real Mac (optional, manual)

Once committed, the end-to-end test is to run `./bootstrap-mac.sh` on a fresh Mac. This isn't a step in the plan because the developer running the plan likely isn't on a fresh Mac, but it's the only true verification of behavior.

Partial verification on a non-fresh Mac:
- `ansible-playbook --check playbook.yml` will run in dry-run mode. Some tasks (like the `shell`/`command` tasks for the curl installers) don't support check mode and will be skipped, but it confirms idempotency of the supported tasks.
