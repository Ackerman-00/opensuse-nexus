#!/bin/bash

# ==========================================
# zen-browser Auto-Updater strictly for Git
# ==========================================

SPEC_FILE="zen-browser.spec"
CHANGES_FILE="zen-browser.changes"
REPO="zen-browser/desktop"

echo "🔍 Checking for updates..."

# Get latest release tag from GitHub API
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
NEW_VER="${LATEST_TAG#v}"

if [ -z "$NEW_VER" ]; then
    echo "❌ Error: Could not fetch latest version from GitHub."
    exit 1
fi

# Check current local version using the .spec file
CURRENT_VER=$(grep "^Version:" "$SPEC_FILE" | awk '{print $2}')

echo "   📂 Current Local: $CURRENT_VER"
echo "   ☁️  Latest Online: $NEW_VER"

if [ "$NEW_VER" == "$CURRENT_VER" ]; then
    echo "✅ Package is already up to date."
    exit 0
fi

echo "🚀 New version found! Testing download URL..."
DOWNLOAD_URL="https://github.com/zen-browser/desktop/releases/download/${LATEST_TAG}/zen.linux-x86_64.tar.xz"
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" -I "$DOWNLOAD_URL" -L)

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "❌ Error: Download URL returned status $HTTP_STATUS. Asset might not be uploaded yet."
    exit 1
fi

echo "⚙️ Updating $SPEC_FILE..."
# Update Spec version and reset the release number to 0
sed -i "s/^Version:.*/Version:        $NEW_VER/" "$SPEC_FILE"
sed -i "s/^Release:.*/Release:        0/" "$SPEC_FILE"

echo "📝 Updating changelog ($CHANGES_FILE)..."
# Manually generate the OBS/RPM changelog format since we aren't using osc
CURRENT_DATE=$(LC_ALL=C date +"%a %b %d %Y")
NEW_CHANGELOG_ENTRY="* $CURRENT_DATE GitHub Actions <actions@github.com> - $NEW_VER-0\n- Update zen-browser to v$NEW_VER\n\n"

# Prepend the new entry to the changes file
if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "🎉 Success! Git files updated to v$NEW_VER. Ready for GitHub Action to commit."
