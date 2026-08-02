#!/bin/bash

SPEC_FILE="fluxer.spec"
CHANGES_FILE="fluxer.changes"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"
API_URL="https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/rpm"

echo "Checking for fluxer updates..."

VERSION=$(curl -sI "$API_URL" | grep -i "^X-Fluxer-Version:" | awk '{print $2}' | tr -d '\r')

if [ -z "$VERSION" ]; then
    echo "Error: Failed to fetch upstream version."
    exit 1
fi

CURRENT_VERSION=$(grep "^Version:" "$SPEC_FILE" | awk '{print $2}')

if [ "$CURRENT_VERSION" = "$VERSION" ]; then
    echo "Package is already at $VERSION. No update needed."
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
