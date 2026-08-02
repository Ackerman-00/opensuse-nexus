#!/bin/bash

SPEC_FILE="opencode-desktop.spec"
CHANGES_FILE="opencode-desktop.changes"
GITHUB_REPO="anomalyco/opencode"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "Checking for upstream updates on $GITHUB_REPO..."

LATEST_TAG=$(git ls-remote --tags https://github.com/$GITHUB_REPO.git 2>/dev/null | awk '{print $2}' | sed 's|refs/tags/||;s/\^{}//' | grep -E '^v?[0-9]' | sort -V | tail -1)
LATEST_VERSION=$(echo "$LATEST_TAG" | sed 's/^v//')

if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Failed to fetch latest tag."
    exit 1
fi

CURRENT_VERSION=$(grep -E "^Version:" "$SPEC_FILE" | awk '{print $2}')

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Package is already at $LATEST_VERSION. No update needed."
    exit 0
fi

echo "Update found: $CURRENT_VERSION -> $LATEST_VERSION"

sed -i "s/^Version:.*/Version:        $LATEST_VERSION/" "$SPEC_FILE"
sed -i "s/^Release:.*/Release:        0/" "$SPEC_FILE"

CURRENT_DATE=$(LC_ALL=C date +"%a %b %d %Y")
NEW_CHANGELOG_ENTRY="* $CURRENT_DATE $PACKAGER - $LATEST_VERSION-0\n- Update opencode-desktop to v$LATEST_VERSION\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "Successfully updated to $LATEST_VERSION."
