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

echo "==> Make sure you are signed in to the App Store app before continuing."
echo "    (mas can no longer detect sign-in status; App Store installs will fail if you aren't.)"
echo "    Press Enter to continue, or Ctrl-C to abort."
read -r _

echo "==> Running playbook (you will be prompted for your sudo password — required by mas to install App Store apps)..."
ansible-playbook playbook.yml --ask-become-pass
