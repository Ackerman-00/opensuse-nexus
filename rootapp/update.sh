#!/bin/bash

SPEC_FILE="rootapp.spec"
CHANGES_FILE="rootapp.changes"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"
CHANGELOG_URL="https://www.rootapp.com/changelog"

echo "Checking for rootapp updates..."

LATEST_DATE=$(curl -s "$CHANGELOG_URL" | grep -oP '[A-Z][a-z]+ \d+, \d{4}' | head -1)
if [ -z "$LATEST_DATE" ]; then
    echo "Error: Could not parse changelog date."
    exit 1
fi

NEW_VER=$(date -d "$LATEST_DATE" +%Y%m%d 2>/dev/null)
if [ -z "$NEW_VER" ]; then
    echo "Error: Could not convert date '$LATEST_DATE' to version."
    exit 1
fi

CURRENT_VER=$(grep "^Version:" "$SPEC_FILE" | awk '{print $2}')

echo "   Current version: $CURRENT_VER"
echo "   Latest changelog: $LATEST_DATE -> $NEW_VER"

if [ "$NEW_VER" == "$CURRENT_VER" ]; then
    echo "Package is already at the latest version."
    exit 0
fi

echo "Update found: $CURRENT_VER -> $NEW_VER"

sed -i "s/^Version:.*/Version:        $NEW_VER/" "$SPEC_FILE"
sed -i "s/^Release:.*/Release:        0/" "$SPEC_FILE"

echo "Generating OBS changes file..."
FORMATTED_DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$FORMATTED_DATE - $PACKAGER\n\n- Update to $LATEST_DATE build ($NEW_VER)\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "Success! RootApp updated to $NEW_VER. Ready for OBS sync."
