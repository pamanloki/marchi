#!/usr/bin/env bash
# Sanity checks before installing marchi on Void Linux.
set -euo pipefail

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }

if ! command -v xbps-install >/dev/null 2>&1; then
  red "marchi is built for Void Linux (xbps-install not found)."
  exit 1
fi

if [ "$(id -u)" = "0" ]; then
  red "Please run the installer as your normal user, not root."
  red "It will call sudo when it needs elevated privileges."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  red "sudo is required. Install it and add your user to the sudoers/wheel group."
  exit 1
fi

green "Preflight OK — Void Linux detected."
