#!/usr/bin/env bash
# Install a wayland session entry so a display manager can launch marchi/niri,
# and make marchi-session available system-wide.
set -euo pipefail

green() { printf '\033[32m%s\033[0m\n' "$*"; }

REPO="$(cd "$(dirname "$0")/.." && pwd)"

green "==> Installing marchi-session to /usr/local/bin"
sudo install -Dm755 "$REPO/bin/marchi-session" /usr/local/bin/marchi-session

green "==> Installing wayland session entry"
sudo install -d /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/marchi.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=marchi (niri)
Comment=Omarchy-inspired niri desktop
Exec=marchi-session
Type=Application
DesktopNames=niri
EOF

green "==> Session installed"
green "    Log out and choose the 'marchi (niri)' session in your display manager,"
green "    or from a TTY run: marchi-session"
