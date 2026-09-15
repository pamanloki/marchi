#!/usr/bin/env bash
# Install marchi's packages from the Void repositories with xbps.
# Missing/renamed packages are reported but do not abort the whole install.
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

# Fonts + theming
FONTS=(nerd-fonts noto-fonts-ttf noto-fonts-emoji font-awesome
       papirus-icon-theme gnome-themes-extra qt6-wayland)

# Handy extras
EXTRAS=(Thunar btop jq yazi git curl unzip)

ALL=("${CORE[@]}" "${AUDIO[@]}" "${NET[@]}" "${SESSION[@]}" "${FONTS[@]}" "${EXTRAS[@]}")

green "==> Syncing repositories"
sudo xbps-install -Sy

green "==> Installing packages"
failed=()
for pkg in "${ALL[@]}"; do
  if ! sudo xbps-install -y "$pkg" >/dev/null 2>&1; then
    failed+=("$pkg")
  fi
done

if [ ${#failed[@]} -gt 0 ]; then
  yellow "==> These packages could not be installed (check names / enable repos):"
  printf '   - %s\n' "${failed[@]}"
  yellow "    You can retry them manually: sudo xbps-install ${failed[*]}"
else
  green "==> All packages installed"
fi
