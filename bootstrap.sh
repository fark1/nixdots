#!/usr/bin/env bash
# Bootstrap this flake config onto a freshly installed NixOS machine.
#
# Fresh machine flow:
#   mkdir -p ~/.config/dots
#   git clone https://github.com/fark1/nixdots.git ~/.config/dots/nixdots
#   cd ~/.config/dots/nixdots
#   ./bootstrap.sh [hostname]
#
# This script clones dots-common as a sibling repo (~/.config/dots/dots-common)
# if it isn't already there, then generates hardware-configuration.nix and
# switches. Run as the normal user; it uses sudo itself where root is
# actually needed.
#
# Usage: bootstrap.sh [hostname]
#   Prompts for a hostname if not given as an argument. It names the
#   hosts/<hostname>/ folder, which is also what networking.hostName
#   becomes (see flake.nix specialArgs / configuration.nix).

set -euo pipefail

HOST="${1:-}"
if [ -z "$HOST" ]; then
  read -rp "Hostname for this machine: " HOST
fi
if ! [[ "$HOST" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*$ ]]; then
  echo "invalid hostname '$HOST' - letters, digits, hyphens only, can't start with a hyphen" >&2
  exit 1
fi

NIX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$NIX_DIR/hosts/$HOST"

# NIX_DIR is .config/dots/nixdots - its parent is .config/dots, where
# dots-common lives as a sibling repo. home.nix's stow activation reads
# from here; it silently no-ops if this doesn't exist yet, so it has to
# be cloned before the rebuild below, not after.
DOTS_ROOT="$(dirname "$NIX_DIR")"
DOTS_COMMON_DIR="$DOTS_ROOT/dots-common"

if [ ! -d "$DOTS_COMMON_DIR" ]; then
  echo "==> Cloning dots-common"
  git clone https://github.com/fark1/dots-common.git "$DOTS_COMMON_DIR"
else
  echo "==> $DOTS_COMMON_DIR already exists, leaving it alone"
fi

mkdir -p "$HOST_DIR"

if [ ! -f "$HOST_DIR/hardware-configuration.nix" ]; then
  echo "==> Generating hardware-configuration.nix for $HOST"
  sudo cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"
  sudo chown "$USER": "$HOST_DIR/hardware-configuration.nix"
else
  echo "==> $HOST_DIR/hardware-configuration.nix already exists, leaving it alone"
fi

echo "==> Switching to flake config for host '$HOST'"
sudo nixos-rebuild switch --flake "path:$NIX_DIR#$HOST"

echo "==> Done. Reboot to confirm the Limine boot menu (latest/zen) looks right."
