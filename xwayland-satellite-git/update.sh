#!/bin/bash

SPEC_FILE="xwayland-satellite-git.spec"
CHANGES_FILE="xwayland-satellite-git.changes"
GITHUB_REPO="Supreeeme/xwayland-satellite"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "🔍 Checking for upstream updates on $GITHUB_REPO..."

if [ -n "$GITHUB_TOKEN" ]; then
    LATEST_COMMIT=$(curl -sL -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPO/commits/main" | jq -r '.sha')
else
    LATEST_COMMIT=$(curl -sL "https://api.github.com/repos/$GITHUB_REPO/commits/main" | jq -r '.sha')
fi

if [ -z "$LATEST_COMMIT" ] || [ "$LATEST_COMMIT" == "null" ]; then
    echo "❌ Error: Failed to fetch Xwayland-Satellite commit from GitHub. Check API limits or connection."
    exit 1
fi

CURRENT_COMMIT=$(grep -E "^%global commit" "$SPEC_FILE" | awk '{print $3}')
SHORT_COMMIT=${LATEST_COMMIT:0:7}
DATE_VER=$(date -u +%Y%m%d)

if [ "$CURRENT_COMMIT" == "$LATEST_COMMIT" ]; then
    echo "✅ Package is already at the latest commit ($SHORT_COMMIT). No update needed."
    exit 0
fi

echo "🚀 Update found: ${CURRENT_COMMIT:0:7} -> $SHORT_COMMIT"

# 1. Update the spec file globals natively
sed -i -E "s/^%global commit.*/%global commit          $LATEST_COMMIT/" "$SPEC_FILE"
sed -i -E "s/^%global shortcommit.*/%global shortcommit     $SHORT_COMMIT/" "$SPEC_FILE"
sed -i -E "s/^Version:.*/Version:        $DATE_VER/" "$SPEC_FILE"
sed -i -E "s/^Release:.*/Release:        0/" "$SPEC_FILE"

# 2. Download source and vendor Rust dependencies
echo "📦 Downloading source and generating Rust vendor tarball..."
rm -f xwayland-satellite-*.tar.gz vendor.tar.xz cargo_config
curl -sL "https://github.com/$GITHUB_REPO/archive/$LATEST_COMMIT.tar.gz" -o "xwayland-satellite-$SHORT_COMMIT.tar.gz"

tar -xzf "xwayland-satellite-$SHORT_COMMIT.tar.gz"
cd "xwayland-satellite-$LATEST_COMMIT" || exit 1

echo "⚙️  Vendoring cargo dependencies (This might take a minute)..."
cargo vendor > ../cargo_config

echo "🗜️  Compressing vendor tarball..."
tar -cJf ../vendor.tar.xz vendor

cd ..
rm -rf "xwayland-satellite-$LATEST_COMMIT"

# 3. Generate OBS Changes File
echo "📝 Generating OBS changes file..."
FORMATTED_DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$FORMATTED_DATE - $PACKAGER\n\n- Nightly sync with upstream main branch (Commit: $SHORT_COMMIT)\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "🎉 Success! Xwayland-Satellite updated to $SHORT_COMMIT. Ready for OBS sync."
