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
