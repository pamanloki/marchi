#!/usr/bin/env bash
# Install JetBrains Mono Nerd Font (only that font, not the multi-GB nerd-fonts
# package) from the Nerd Fonts release into ~/.local/share/fonts.
set -euo pipefail

green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
  green "==> JetBrains Mono Nerd Font already installed"
  exit 0
fi

green "==> Downloading JetBrains Mono Nerd Font"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if ! curl -fL --retry 3 -o "$tmp/JetBrainsMono.zip" "$URL"; then
  yellow "==> Could not download the font (no network?)."
  yellow "    Install it later with: install/fonts.sh"
  yellow "    Or: sudo xbps-install nerd-fonts (large), then rerun marchi update."
  exit 0
fi

mkdir -p "$FONT_DIR"
unzip -o -q "$tmp/JetBrainsMono.zip" -d "$FONT_DIR" -x "*.md" "LICENSE" "*.txt" || \
  unzip -o -q "$tmp/JetBrainsMono.zip" -d "$FONT_DIR"

green "==> Refreshing font cache"
fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1 || true

if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
  green "==> JetBrains Mono Nerd Font installed"
else
  yellow "==> Font files placed in $FONT_DIR (fc-cache may need a re-login)"
fi
