#!/bin/bash

SPEC_FILE="obsidian.spec"
CHANGES_FILE="obsidian.changes"
GITHUB_REPO="obsidianmd/obsidian-releases"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "🔍 Checking for upstream updates on $GITHUB_REPO..."

# Retry on transient network/API failures so one hiccup does not stub the
# version and abort the whole update.
LATEST_TAG=""
for attempt in 1 2 3; do
    if [ -n "$GITHUB_TOKEN" ]; then
        API_RESPONSE=$(curl -sL --retry 3 --connect-timeout 15 -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
    else
        API_RESPONSE=$(curl -sL --retry 3 --connect-timeout 15 "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
    fi
    LATEST_TAG=$(echo "$API_RESPONSE" | jq -r '.tag_name')
    if [ -n "$LATEST_TAG" ] && [ "$LATEST_TAG" != "null" ]; then
        break
    fi
    echo "   Retry $attempt: could not fetch latest tag from GitHub..."
    sleep 5
done
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

# 0. Download and VERIFY both source tarballs BEFORE touching the spec. A failed
#    or error-stubbed download (e.g. rate-limited HTML page) must NOT bump the
#    version or reach OBS - otherwise the sync step uploads a stub and deletes
#    the previous good tarball, breaking the build.
echo "📦 Downloading source tarballs..."
rm -f obsidian-*.tar.gz

X86_URL="https://github.com/$GITHUB_REPO/releases/download/$LATEST_TAG/obsidian-$LATEST_VER.tar.gz"
ARM_URL="https://github.com/$GITHUB_REPO/releases/download/$LATEST_TAG/obsidian-$LATEST_VER-arm64.tar.gz"

curl -fsSL --retry 3 --connect-timeout 20 "$X86_URL" -o "obsidian-$LATEST_VER.tar.gz" \
    || { echo "❌ x86_64 tarball download failed; OBS sources left untouched."; exit 1; }
curl -fsSL --retry 3 --connect-timeout 20 "$ARM_URL" -o "obsidian-$LATEST_VER-arm64.tar.gz" \
    || { echo "❌ arm64 tarball download failed; OBS sources left untouched."; exit 1; }

# Verify both files are real gzip tarballs (not HTML error stubs) before use.
for f in "obsidian-$LATEST_VER.tar.gz" "obsidian-$LATEST_VER-arm64.tar.gz"; do
    if ! [ -s "$f" ] || ! tar -tzf "$f" > /dev/null 2>&1; then
        echo "❌ $f is missing, empty, or not a valid tarball; OBS sources left untouched."
        exit 1
    fi
done
echo "✅ Both tarballs verified (x86_64 $(du -h "obsidian-$LATEST_VER.tar.gz" | cut -f1), arm64 $(du -h "obsidian-$LATEST_VER-arm64.tar.gz" | cut -f1))."

# 1. Update the spec file
sed -i -E "s/^Version:.*/Version:        $LATEST_VER/" "$SPEC_FILE"
sed -i -E "s/^Release:.*/Release:        0/" "$SPEC_FILE"

# 2. Generate OBS Changes File
echo "📝 Generating OBS changes file..."
FORMATTED_DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$FORMATTED_DATE - $PACKAGER\n\n- Update to upstream version $LATEST_VER\n- Switch to native system Electron dependency\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "🎉 Success! Obsidian updated to $LATEST_VER. Ready for OBS sync."