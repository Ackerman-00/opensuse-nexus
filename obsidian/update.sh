#!/bin/bash

SPEC_FILE="obsidian.spec"
CHANGES_FILE="obsidian.changes"
GITHUB_REPO="obsidianmd/obsidian-releases"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "🔍 Checking for upstream updates on $GITHUB_REPO..."

if [ -n "$GITHUB_TOKEN" ]; then
    API_RESPONSE=$(curl -sL -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
else
    API_RESPONSE=$(curl -sL "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
fi

LATEST_TAG=$(echo "$API_RESPONSE" | jq -r '.tag_name')
LATEST_VER="${LATEST_TAG#v}" # Strip the 'v' prefix

if [ -z "$LATEST_VER" ] || [ "$LATEST_VER" == "null" ]; then
    echo "❌ Error: Failed to fetch Obsidian version from GitHub. Check API limits or connection."
    exit 1
fi

CURRENT_VER=$(grep -E "^Version:" "$SPEC_FILE" | awk '{print $2}')

if [ "$CURRENT_VER" == "$LATEST_VER" ]; then
    echo "✅ Package is already up to date ($CURRENT_VER). No update needed."
    exit 0
fi

echo "🚀 Update found: $CURRENT_VER -> $LATEST_VER"

# 1. Update the spec file
sed -i -E "s/^Version:.*/Version:        $LATEST_VER/" "$SPEC_FILE"
sed -i -E "s/^Release:.*/Release:        0/" "$SPEC_FILE"

# 2. Download BOTH architectures directly from GitHub release assets
echo "📦 Downloading source tarballs..."
rm -f obsidian-*.tar.gz

X86_URL="https://github.com/$GITHUB_REPO/releases/download/$LATEST_TAG/obsidian-$LATEST_VER.tar.gz"
ARM_URL="https://github.com/$GITHUB_REPO/releases/download/$LATEST_TAG/obsidian-$LATEST_VER-arm64.tar.gz"

curl -sL "$X86_URL" -o "obsidian-$LATEST_VER.tar.gz"
curl -sL "$ARM_URL" -o "obsidian-$LATEST_VER-arm64.tar.gz"

# 3. Generate OBS Changes File
echo "📝 Generating OBS changes file..."
FORMATTED_DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$FORMATTED_DATE - $PACKAGER\n\n- Update to upstream version $LATEST_VER\n- Switch to native system Electron dependency\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "🎉 Success! Obsidian updated to $LATEST_VER. Ready for OBS sync."
