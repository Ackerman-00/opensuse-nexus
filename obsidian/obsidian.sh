#!/bin/bash
# Obsidian launcher for the bundled Electron runtime in /opt/obsidian.
# No system electron needed (fixes issue #9: distro nodejs-electron
# requires libabsl sonames nothing provides).
OBSIDIAN_USER_FLAGS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian/user-flags.conf"

# Allow users to override command-line options for Wayland/GPU acceleration
if [ -f "$OBSIDIAN_USER_FLAGS_FILE" ]; then
   mapfile -t OBSIDIAN_USER_FLAGS < <(sed -r "/^( *#|$)/d;s% %\n%g" "$OBSIDIAN_USER_FLAGS_FILE")
fi

# Native Wayland rendering when available (same as vesktop/stoat wrappers)
if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    export ELECTRON_OZONE_PLATFORM_HINT="${ELECTRON_OZONE_PLATFORM_HINT:-auto}"
fi

# Launch Obsidian via the bundled Electron binary
exec /opt/obsidian/obsidian "${OBSIDIAN_USER_FLAGS[@]}" "$@"
