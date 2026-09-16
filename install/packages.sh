#!/usr/bin/env bash
# Install marchi's packages from the Void repositories with xbps.
# Official packages install in a single transaction (fast, one progress bar).
# Third-party packages (from the solocco repo) are installed separately so a
# single flaky one can't derail the rest.
set -euo pipefail

green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

installed() { xbps-query "$1" >/dev/null 2>&1; }

# Compositor + core desktop
CORE=(niri Waybar foot fuzzel mako swaylock swayidle swaybg wlsunset
      wl-clipboard cliphist grim slurp brightnessctl playerctl)

# Audio
AUDIO=(pipewire wireplumber pavucontrol)

# Network + Bluetooth
NET=(NetworkManager network-manager-applet bluez blueman)

# Session: portals, polkit, seat/login management
SESSION=(xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr
         polkit polkit-gnome elogind dbus)

# Fonts + theming. JetBrains Mono Nerd Font is fetched by install/fonts.sh.
FONTS=(noto-fonts-ttf noto-fonts-emoji font-awesome
       papirus-icon-theme gnome-themes-extra qt6-wayland)

# Handy extras from the official repos
EXTRAS=(Thunar btop jq git curl unzip)

# Packages from third-party repos (enabled in repos.sh). Kept separate because
# their key/signing/availability is outside the official repos.
THIRD_PARTY=(yazi-bin)

OFFICIAL=("${CORE[@]}" "${AUDIO[@]}" "${NET[@]}" "${SESSION[@]}" "${FONTS[@]}" "${EXTRAS[@]}")

green "==> Syncing repositories"
sudo xbps-install -Sy

green "==> Installing ${#OFFICIAL[@]} packages (this can take a while on first run)"
if ! sudo xbps-install -y "${OFFICIAL[@]}"; then
  yellow "==> Bulk install failed; retrying one at a time to find the culprits"
  failed=()
  for pkg in "${OFFICIAL[@]}"; do
    if installed "$pkg"; then continue; fi
    green "   installing $pkg"
    sudo xbps-install -y "$pkg" || failed+=("$pkg")
  done
  if [ ${#failed[@]} -gt 0 ]; then
    yellow "==> Could not install: ${failed[*]}"
    yellow "    Retry manually: sudo xbps-install ${failed[*]}"
  fi
fi

green "==> Installing third-party packages: ${THIRD_PARTY[*]}"
for pkg in "${THIRD_PARTY[@]}"; do
  if installed "$pkg"; then green "   $pkg already installed"; continue; fi
  if ! sudo xbps-install -y "$pkg"; then
    yellow "==> Could not install '$pkg' from the solocco repo."
    yellow "    Common causes: the repo's signing key isn't imported yet, or"
    yellow "    the repodata is out of sync with the release .xbps files."
    yellow "    Try:  sudo xbps-install -S && sudo xbps-install $pkg"
    yellow "    (yazi is optional here — Thunar is the default file manager.)"
  fi
done

green "==> Package installation done"
