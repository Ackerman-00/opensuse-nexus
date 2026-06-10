#!/bin/bash

SPEC_FILE="noctalia-v5.spec"
CHANGES_FILE="noctalia-v5.changes"
GITHUB_REPO="noctalia-dev/noctalia"
BRANCH="main"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "🔍 Checking for upstream commits on $GITHUB_REPO (Branch: $BRANCH)..."

# Fetch the latest commit data from the main branch
if [ -n "$GITHUB_TOKEN" ]; then
    API_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPO/commits/$BRANCH")
else
    API_RESPONSE=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/commits/$BRANCH")
fi

LATEST_COMMIT=$(echo "$API_RESPONSE" | jq -r '.sha')
LATEST_DATE_RAW=$(echo "$API_RESPONSE" | jq -r '.commit.committer.date')

if [ -z "$LATEST_COMMIT" ] || [ "$LATEST_COMMIT" == "null" ]; then
    echo "❌ Error: Failed to fetch the latest commit. Check API limits or connection."
    exit 1
fi

# Create a chronological integer (e.g., 20260504143200)
LATEST_DATE=$(echo "$LATEST_DATE_RAW" | sed 's/[-T:Z]//g')
SHORT_COMMIT=${LATEST_COMMIT:0:7}

# Extract the current commit from the spec file
CURRENT_COMMIT=$(grep -E "^%global commit" "$SPEC_FILE" | awk '{print $3}')

if [ "$CURRENT_COMMIT" == "$LATEST_COMMIT" ]; then
    echo "✅ Package is already tracking the latest commit ($SHORT_COMMIT). No update needed."
    exit 0
fi

echo "🚀 New commit found: $SHORT_COMMIT (Timestamp: $LATEST_DATE)"

# 1. Update the globals in the .spec file (now handling shortcommit directly)
sed -i "s/^%global commit.*/%global commit          $LATEST_COMMIT/" "$SPEC_FILE"
sed -i "s/^%global shortcommit.*/%global shortcommit     $SHORT_COMMIT/" "$SPEC_FILE"
sed -i "s/^%global gitdate.*/%global gitdate         $LATEST_DATE/" "$SPEC_FILE"
sed -i "s/^Release:.*/Release:        0/" "$SPEC_FILE"

# 2. Clean up old tarballs and download the new one natively
echo "📦 Downloading source tarball from GitHub..."
rm -f noctalia-*.tar.gz
curl -sL "https://github.com/$GITHUB_REPO/archive/$LATEST_COMMIT.tar.gz" -o "noctalia-$SHORT_COMMIT.tar.gz"

# 3. Generate OBS changes file
echo "📝 Generating OBS changes file..."
FORMATTED_DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$FORMATTED_DATE - $PACKAGER\n\n- Nightly sync with upstream $BRANCH branch (Commit: $SHORT_COMMIT)\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "🎉 Success! noctalia-v5 is updated to git $SHORT_COMMIT and tarball is ready. Ready for OBS sync."
