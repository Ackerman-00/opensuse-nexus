#!/bin/bash

SPEC_FILE="mangowm-git.spec"
CHANGES_FILE="mangowm-git.changes"
GITHUB_REPO="mangowm/mango"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "Checking for upstream commits on $GITHUB_REPO..."

if [ -n "$GITHUB_TOKEN" ]; then
    API_RESPONSE=$(curl -sL -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPO/commits/main")
else
    API_RESPONSE=$(curl -sL "https://api.github.com/repos/$GITHUB_REPO/commits/main")
fi

LATEST_COMMIT=$(echo "$API_RESPONSE" | jq -r '.sha')
LATEST_DATE_RAW=$(echo "$API_RESPONSE" | jq -r '.commit.committer.date')

if [ -z "$LATEST_COMMIT" ] || [ "$LATEST_COMMIT" == "null" ]; then
    echo "Error: Failed to fetch Mango commit from GitHub. Check API limits or connection."
    exit 1
fi

CURRENT_COMMIT=$(grep -E "^%global commit" "$SPEC_FILE" | awk '{print $3}')
SHORT_COMMIT=${LATEST_COMMIT:0:7}
LATEST_DATE=$(echo "$LATEST_DATE_RAW" | sed 's/[-T:Z]//g')

if [ "$CURRENT_COMMIT" == "$LATEST_COMMIT" ]; then
    echo "Package is already at the latest commit ($SHORT_COMMIT). No update needed."
    exit 0
fi

echo "Update found: ${CURRENT_COMMIT:0:7} -> $SHORT_COMMIT"

sed -i -E "s/^%global commit.*/%global commit          $LATEST_COMMIT/" "$SPEC_FILE"
sed -i -E "s/^%global shortcommit.*/%global shortcommit     $SHORT_COMMIT/" "$SPEC_FILE"
sed -i -E "s/^%global gitdate.*/%global gitdate         $LATEST_DATE/" "$SPEC_FILE"
sed -i -E "s/^Release:.*/Release:        0/" "$SPEC_FILE"

echo "Downloading source tarball..."
rm -f mango-*.tar.gz
curl -sL "https://github.com/$GITHUB_REPO/archive/$LATEST_COMMIT.tar.gz" -o "mango-$SHORT_COMMIT.tar.gz"

echo "Generating OBS changes file..."
FORMATTED_DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$FORMATTED_DATE - $PACKAGER\n\n- Nightly sync with upstream main branch (Commit: $SHORT_COMMIT)\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "Success! Mango updated to $SHORT_COMMIT. Ready for OBS sync."
