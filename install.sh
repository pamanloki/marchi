#!/usr/bin/env bash
# marchi installer for Void Linux.
#
#   git clone https://github.com/pamanloki/marchi ~/.local/share/marchi/repo
#   ~/.local/share/marchi/repo/install.sh
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
export MARCHI_REPO="$HERE"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }

bold "
                            888      d8b
                            888      Y8P
                            888
88888b.d88b.   8888b.  888d888 .d8888b 88888b.  888
888  888  88b     88b  888P   d88P     888  88b 888
888  888  888 .d888888 888    888      888  888 888
888  888  888 888  888 888    Y88b.    888  888 888
888  888  888  Y888888 888      Y8888P 888  888 888

  Omarchy-inspired niri desktop for Void Linux
"

bash "$HERE/install/preflight.sh"
bash "$HERE/install/repos.sh"
bash "$HERE/install/packages.sh"
bash "$HERE/install/fonts.sh"
bash "$HERE/install/config.sh"
bash "$HERE/install/services.sh"
bash "$HERE/install/session.sh"

bold "
Done! Next steps:
  1. Reboot (so group + service changes take effect), then
  2. Log in and pick the 'marchi (niri)' session,
     or from a TTY run:  marchi-session

Handy keys:  SUPER+Return terminal · SUPER+Space launcher ·
             SUPER+Escape menu · SUPER+K keybindings ·
             SUPER+Ctrl+Shift+Space theme switcher
"
