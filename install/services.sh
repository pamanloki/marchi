#!/usr/bin/env bash
# Enable the runit services marchi needs (Void uses runit, not systemd).
set -euo pipefail

green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

enable() {
  local svc="$1"
  if [ -d "/etc/sv/$svc" ]; then
    sudo ln -sfn "/etc/sv/$svc" "/var/service/$svc"
    green "   enabled $svc"
  else
    yellow "   skip $svc (service not found)"
  fi
}

green "==> Enabling services"
enable dbus
enable elogind
enable polkitd
enable NetworkManager
enable bluetoothd

# NetworkManager conflicts with dhcpcd/wpa_supplicant running as global services.
for conflict in dhcpcd wpa_supplicant; do
  if [ -e "/var/service/$conflict" ]; then
    yellow "==> Disabling $conflict (conflicts with NetworkManager)"
    sudo rm -f "/var/service/$conflict"
  fi
done

# Add the current user to useful groups.
green "==> Adding $USER to groups: video, audio, input, bluetooth, network"
for grp in video audio input bluetooth network _seatd seat; do
  getent group "$grp" >/dev/null 2>&1 && sudo usermod -aG "$grp" "$USER" 2>/dev/null || true
done

green "==> Services configured (a reboot is recommended)"
