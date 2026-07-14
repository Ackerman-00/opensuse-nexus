#!/bin/bash

SPEC_FILE="rootapp.spec"
CHANGES_FILE="rootapp.changes"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"
APPIMAGE_URL="https://installer.rootapp.com/installer/Linux/X64/Root.AppImage"

echo "Checking for rootapp updates..."

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

curl -sL -o "$TMPDIR/Root.AppImage" "$APPIMAGE_URL"
NEW_SHA=$(sha256sum "$TMPDIR/Root.AppImage" | awk '{print $1}')

CURRENT_VERSION=$(grep -E "^Version:" "$SPEC_FILE" | awk '{print $2}')
CURRENT_SHA=$(grep -E "^# sha256:" "$SPEC_FILE" | awk '{print $3}')

if [ -n "$CURRENT_SHA" ] && [ "$NEW_SHA" = "$CURRENT_SHA" ]; then
    echo "Package is up to date (sha256: $CURRENT_SHA)."
    exit 0
fi

echo "Downloaded AppImage SHA256: $NEW_SHA"
if [ -n "$CURRENT_SHA" ]; then
    echo "Previous SHA256: $CURRENT_SHA"
fi
echo "Update detected."

VERSION=""
EXTRACTED=0

if command -v unsquashfs &>/dev/null; then
    OFFSET=$(od -An -N8 -t u8 -j 40 "$TMPDIR/Root.AppImage" | tr -d ' ')
    MAGIC=$(dd if="$TMPDIR/Root.AppImage" bs=1 skip=$OFFSET count=4 2>/dev/null)

    if [ "$MAGIC" != "hsqs" ]; then
        OFFSET=$(python3 -c "
with open('$TMPDIR/Root.AppImage', 'rb') as f:
    d = f.read()
    p = d.find(b'hsqs', 200000)
    print(p if p >= 0 else 0)
")
    fi

    dd if="$TMPDIR/Root.AppImage" bs=$OFFSET skip=1 of="$TMPDIR/squashfs.img" 2>/dev/null
    unsquashfs -d "$TMPDIR/squashfs-root" -f "$TMPDIR/squashfs.img" >/dev/null 2>&1

    if [ -d "$TMPDIR/squashfs-root" ]; then
        EXTRACTED=1
    fi
fi

if [ "$EXTRACTED" = "1" ]; then
    ROOT="$TMPDIR/squashfs-root"

    if [ -f "$ROOT/resources/app/package.json" ]; then
        VERSION=$(python3 -c "
import json
try:
    d = json.load(open('$ROOT/resources/app/package.json'))
    print(d.get('version', ''))
except:
    print('')
")
    fi

    if [ -z "$VERSION" ] && [ -f "$ROOT/AppRun" ]; then
        VERSION=$(strings "$ROOT/AppRun" 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
    fi

    if [ -z "$VERSION" ]; then
        VERSION=$(grep -rI '"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$ROOT" 2>/dev/null | head -3 | sed 's/.*"\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/' | head -1)
    fi

    rm -rf "$TMPDIR/squashfs-root" "$TMPDIR/squashfs.img"
fi

if [ -n "$VERSION" ] && [ "$VERSION" != "$CURRENT_VERSION" ]; then
    echo "Detected version: $VERSION ($CURRENT_VERSION -> $VERSION)"
    sed -i "s/^Version:.*/Version:        $VERSION/" "$SPEC_FILE"
    sed -i "s/^Release:.*/Release:        0/" "$SPEC_FILE"
else
    VERSION="$CURRENT_VERSION"
    echo "Version unchanged: $VERSION"
fi

if grep -q "^# sha256:" "$SPEC_FILE"; then
    sed -i "s/^# sha256:.*/# sha256: $NEW_SHA/" "$SPEC_FILE"
else
    sed -i "/^Source0:/a # sha256:  $NEW_SHA" "$SPEC_FILE"
fi

FORMATTED_DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$FORMATTED_DATE - $PACKAGER\n\n- Update to $VERSION (sha256: $NEW_SHA)\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "Success! RootApp updated to $VERSION. Ready for OBS sync."
