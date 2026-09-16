#!/usr/bin/env bash
# Enable extra xbps repositories used by marchi.
#
# solocco-void-packages provides fresh binary packages (e.g. yazi-bin) so we
# don't have to compile them. niri/Waybar still come from the official repos.
set -euo pipefail

green() { printf '\033[32m%s\033[0m\n' "$*"; }

SOLOCCO_URL="https://github.com/solocco/solocco-void-packages/releases/download/repo-latest"
CONF="/etc/xbps.d/20-solocco.conf"

green "==> Enabling solocco-void-packages repository"
echo "repository=$SOLOCCO_URL" | sudo tee "$CONF" >/dev/null

green "==> Syncing repositories (accepting the repo's signing key)"
# -y assumes yes, which also confirms importing the repo's public key.
sudo xbps-install -Sy
