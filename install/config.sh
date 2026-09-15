#!/usr/bin/env bash
# Deploy marchi configs, scripts, and themes into the user's home.
# Safe to re-run (used by `marchi update`). Existing configs are backed up once.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CFG="$HOME/.config"
BIN="$HOME/.local/bin"
SHARE="$HOME/.local/share/marchi"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/marchi"
BACKUP="$HOME/.local/share/marchi/backup-$(date +%Y%m%d-%H%M%S)"

green() { printf '\033[32m%s\033[0m\n' "$*"; }

mkdir -p "$CFG" "$BIN" "$SHARE" "$STATE/current/theme" \
         "$CFG/niri" "$CFG/waybar" "$CFG/foot" "$CFG/fuzzel" "$CFG/mako" \
         "$HOME/Pictures/Screenshots"

backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP"
    cp -a "$target" "$BACKUP/" 2>/dev/null || true
  fi
}

green "==> Installing scripts to $BIN"
for f in "$REPO"/bin/*; do
  ln -sfn "$f" "$BIN/$(basename "$f")"
done

green "==> Linking themes"
ln -sfn "$REPO/themes" "$CFG/marchi/themes" 2>/dev/null || {
  mkdir -p "$CFG/marchi"; ln -sfn "$REPO/themes" "$CFG/marchi/themes"; }
ln -sfn "$REPO/version" "$CFG/marchi/version" 2>/dev/null || true

green "==> Deploying config files"
# niri config is copied (not symlinked) because marchi-theme-set patches it.
backup "$CFG/niri/config.kdl"
cp -f "$REPO/config/niri/config.kdl"      "$CFG/niri/config.kdl"
backup "$CFG/waybar/config.jsonc"; cp -f "$REPO/config/waybar/config.jsonc" "$CFG/waybar/config.jsonc"
backup "$CFG/waybar/style.css";    cp -f "$REPO/config/waybar/style.css"    "$CFG/waybar/style.css"
backup "$CFG/foot/foot.ini"; cp -f "$REPO/config/foot/foot.ini" "$CFG/foot/foot.ini"

# fuzzel + mako read the generated theme files via a stable symlink.
backup "$CFG/fuzzel/fuzzel.ini"
ln -sfn "$STATE/current/theme/fuzzel.ini" "$CFG/fuzzel/fuzzel.ini"
backup "$CFG/mako/config"
ln -sfn "$STATE/current/theme/mako.ini"   "$CFG/mako/config"

green "==> Installing data files"
cp -f "$REPO/data/emoji.txt" "$SHARE/emoji.txt" 2>/dev/null || true

green "==> Ensuring ~/.local/bin is on PATH"
add_path_line='export PATH="$HOME/.local/bin:$PATH"'
for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.zprofile"; do
  [ -e "$rc" ] || continue
  if ! grep -qs '.local/bin' "$rc"; then
    printf '\n# marchi\n%s\n' "$add_path_line" >>"$rc"
  fi
done
export PATH="$HOME/.local/bin:$PATH"

green "==> Applying default theme"
current_theme=$(cat "$STATE/current/theme.name" 2>/dev/null || echo "tokyo-night")
MARCHI_CONFIG="$CFG/marchi" "$BIN/marchi-theme-set" "$current_theme" || \
  MARCHI_CONFIG="$CFG/marchi" "$BIN/marchi-theme-set" tokyo-night

green "==> marchi configs deployed"
[ -d "$BACKUP" ] && green "    (previous configs backed up to $BACKUP)"
