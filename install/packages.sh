#!/usr/bin/env bash
# Install marchi's packages from the Void repositories with xbps.
# Installs in a single transaction so xbps shows one progress bar and resolves
# dependencies once. If that fails, retries per-package to pinpoint bad names.
set -euo pipefail

green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

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

# Fonts + theming.
# NOTE: JetBrains Mono Nerd Font is NOT installed from xbps here — the Void
# `nerd-fonts` package bundles *every* Nerd Font and is several GB. Instead,
# install/fonts.sh downloads just the JetBrains Mono Nerd Font (a small zip).
FONTS=(noto-fonts-ttf noto-fonts-emoji font-awesome
       papirus-icon-theme gnome-themes-extra qt6-wayland)

# Handy extras (yazi-bin comes from the solocco repo enabled in repos.sh)
EXTRAS=(Thunar btop jq yazi-bin git curl unzip)

ALL=("${CORE[@]}" "${AUDIO[@]}" "${NET[@]}" "${SESSION[@]}" "${FONTS[@]}" "${EXTRAS[@]}")

green "==> Syncing repositories"
sudo xbps-install -Sy

green "==> Installing ${#ALL[@]} packages (this can take a while on first run)"
if sudo xbps-install -y "${ALL[@]}"; then
  green "==> All packages installed"
  exit 0
fi

yellow "==> Bulk install failed; retrying one at a time to find the culprits"
failed=()
for pkg in "${ALL[@]}"; do
  green "   installing $pkg"
  if ! sudo xbps-install -y "$pkg"; then
    failed+=("$pkg")
  fi
done

if [ ${#failed[@]} -gt 0 ]; then
  yellow "==> These packages could not be installed (check names / enable repos):"
  printf '   - %s\n' "${failed[@]}"
  yellow "    Retry manually: sudo xbps-install ${failed[*]}"
else
  green "==> All packages installed"
fi
