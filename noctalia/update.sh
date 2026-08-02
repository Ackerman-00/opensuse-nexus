#!/bin/bash

SPEC_FILE="noctalia.spec"
CHANGES_FILE="noctalia.changes"
GITHUB_REPO="noctalia-dev/noctalia"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "Checking for upstream updates on $GITHUB_REPO..."

if [ -n "$GITHUB_TOKEN" ]; then
    API_RESPONSE=$(curl -sL -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
else
    API_RESPONSE=$(curl -sL "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
fi

LATEST_TAG=$(echo "$API_RESPONSE" | jq -r '.tag_name')
LATEST_TAGVER="${LATEST_TAG#v}"

if [ -z "$LATEST_TAGVER" ] || [ "$LATEST_TAGVER" == "null" ]; then
    echo "Error: Failed to fetch Noctalia version from GitHub. Check API limits or connection."
    exit 1
fi

# Convert upstream tag to RPM version: dashes become tildes for pre-release ordering
# e.g. 5.0.0-beta.7 -> 5.0.0~beta7 (openSUSE convention)
LATEST_VER=$(echo "$LATEST_TAGVER" | sed 's/-/~/g; s/\.\([0-9][0-9]*\)$/\1/')

CURRENT_VER=$(grep -E "^Version:" "$SPEC_FILE" | awk '{print $2}')
CURRENT_TAGVER=$(grep -E "^%global tagver" "$SPEC_FILE" | awk '{print $3}')

if [ "$CURRENT_TAGVER" == "$LATEST_TAGVER" ]; then
    echo "Package is already up to date ($CURRENT_TAGVER). No update needed."
    exit 0
fi

echo "Update found: $CURRENT_TAGVER -> $LATEST_TAGVER (version: $LATEST_VER)"

# 1. Update the spec file (tagver + Version)
sed -i -E "s/^%global tagver.*/%global tagver $LATEST_TAGVER/" "$SPEC_FILE"
sed -i -E "s/^Version:.*/Version:        $LATEST_VER/" "$SPEC_FILE"
sed -i -E "s/^Release:.*/Release:        0/" "$SPEC_FILE"

# 2. Download the source tarball
echo "Downloading source tarball ($LATEST_TAGVER)..."
rm -f noctalia-*.tar.gz
curl -sL "https://github.com/$GITHUB_REPO/archive/refs/tags/$LATEST_TAG/noctalia-$LATEST_TAGVER.tar.gz" \
    -o "noctalia-$LATEST_TAGVER.tar.gz"

# 3. Generate OBS Changes File
echo "Generating OBS changes file..."
FORMATTED_DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$FORMATTED_DATE - $PACKAGER\n\n- Update to upstream version $LATEST_VER\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "Success! Noctalia updated to $LATEST_VER. Ready for OBS sync."
