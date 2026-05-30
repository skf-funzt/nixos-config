#!/usr/bin/env bash
set -euo pipefail

# run-all.sh
# Orchestrates the entire NixOS install by running each numbered script in order.
# Destructive scripts (02, 03, 04) already ask for confirmation internally.
# This script stops immediately if any step fails.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_step() {
    local num="$1"
    local script="$SCRIPT_DIR/${num}-*.sh"
    local matched
    matched=$(ls -1 $script 2>/dev/null | head -n1)

    if [[ -z "$matched" ]]; then
        echo "ERROR: No script found for step $num"
        exit 1
    fi

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║  STEP $num: $(basename "$matched")"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    "$matched"
}

# ── Pre-install: unmount through hardware generation ──
run_step 01
run_step 02
run_step 03
run_step 04
run_step 05
run_step 06

# ── Pause for UUID wiring ──
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  PAUSE: Update UUIDs in the flake                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "The generated hardware-configuration.nix contains the Btrfs"
echo "device UUIDs. You MUST update them in:"
echo ""
echo "  modules/system/btrfs-laptop.nix"
echo ""
echo "Read the generated file:"
echo "  /mnt/etc/nixos/modules/hosts/laptop/hardware-configuration.nix"
echo ""
read -r -p "Press Enter when UUIDs are updated and you are ready to continue..."

# ── Copy config and install ──
run_step 07
run_step 08

# ── Done ──
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  INSTALL COMPLETE                                           ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Next: reboot into the new system, then run:"
echo "  ./09-post-install.sh"
echo ""
