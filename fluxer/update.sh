#!/bin/bash

SPEC_FILE="fluxer.spec"
CHANGES_FILE="fluxer.changes"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"
API_URL="https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/rpm"
RPM_FILE="fluxer.rpm"

echo "Checking for fluxer updates..."

VERSION=$(curl -sI "$API_URL" | grep -i "^X-Fluxer-Version:" | awk '{print $2}' | tr -d '\r')

if [ -z "$VERSION" ]; then
    echo "Error: Failed to fetch upstream version."
    exit 1
fi

CURRENT_VERSION=$(grep "^Version:" "$SPEC_FILE" | awk '{print $2}')

# The Source0 RPM is gitignored and never present in CI checkouts. Always
# ensure it exists locally so the OBS sync step can upload it; if OBS ever
# loses the RPM while the version is unchanged, this prevents a rebuild
# failure. The version guard above stays a pure version comparison.
if [ -f "$RPM_FILE" ] && [ "$CURRENT_VERSION" = "$VERSION" ]; then
    echo "Package is already at $VERSION. No update needed."
    exit 0
fi

echo "Downloading RPM..."
curl -fsSL --retry 3 --connect-timeout 30 -o "$RPM_FILE" "$API_URL" \
    || { echo "RPM download failed; spec left untouched."; exit 1; }
if ! [ -s "$RPM_FILE" ] || ! rpm -qp "$RPM_FILE" >/dev/null 2>&1; then
    echo "Downloaded file is empty or not a valid RPM; spec left untouched."
    rm -f "$RPM_FILE"
    exit 1
fi

if [ "$CURRENT_VERSION" = "$VERSION" ]; then
    echo "Version unchanged but RPM refreshed; only the artifact needs re-syncing to OBS."
    exit 0
fi

echo "Update available: $CURRENT_VERSION -> $VERSION"

sed -i "s/^Version:.*/Version:        $VERSION/" "$SPEC_FILE"
sed -i "s/^Release:.*/Release:        0/" "$SPEC_FILE"

CURRENT_DATE=$(LC_ALL=C date +"%a %b %d %Y")
NEW_CHANGELOG_ENTRY="* $CURRENT_DATE $PACKAGER - $VERSION-0\n- Update fluxer to v$VERSION\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "Successfully updated to $VERSION."