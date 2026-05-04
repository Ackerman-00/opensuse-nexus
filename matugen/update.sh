#!/bin/bash

SPEC_FILE="matugen.spec"
CHANGES_FILE="matugen.changes"
REPO="InioX/matugen"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "🔍 Checking for updates..."

# Get latest release tag from GitHub API
LATEST_JSON=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
LATEST_TAG=$(echo "$LATEST_JSON" | jq -r .tag_name)
NEW_VER="${LATEST_TAG#v}"

if [ -z "$NEW_VER" ] || [ "$NEW_VER" == "null" ]; then
    echo "❌ Error: Could not fetch latest version."
    exit 1
fi

CURRENT_VER=$(grep "^Version:" "$SPEC_FILE" | awk '{print $2}')

echo "   📂 Current Local: $CURRENT_VER"
echo "   ☁️  Latest Online: $NEW_VER"

if [ "$NEW_VER" == "$CURRENT_VER" ]; then
    echo "✅ Package is already up to date."
    exit 0
fi

echo "🚀 New version found! Updating $SPEC_FILE..."
sed -i "s|^Version:.*|Version:        $NEW_VER|" "$SPEC_FILE"
sed -i "s|^Release:.*|Release:        0|" "$SPEC_FILE"

echo "📝 Updating changelog..."
FORMATTED_DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$FORMATTED_DATE - $PACKAGER\n\n- Update matugen to v$NEW_VER\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "🎉 Success! Git files updated to v$NEW_VER. Ready for commit."
