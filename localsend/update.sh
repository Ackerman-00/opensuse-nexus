#!/bin/bash

SPEC_FILE="localsend.spec"
CHANGES_FILE="localsend.changes"
GITHUB_REPO="localsend/localsend"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "Checking for upstream updates on $GITHUB_REPO..."

# Get latest tag via git ls-remote (no rate limit)
LATEST_TAG=$(git ls-remote --tags https://github.com/$GITHUB_REPO.git 2>/dev/null | awk '{print $2}' | sed 's|refs/tags/||;s/\^{}//' | grep -E '^v?[0-9]' | sort -V | tail -1)

if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ]; then
    echo "Error: Failed to fetch LocalSend version from GitHub. Check API limits or connection."
    exit 1
fi

# RPM spec files do not allow dashes in the Version field. Sanitize it.
LATEST_VERSION=$(echo "$LATEST_TAG" | sed 's/^v//;s@-@.@g')

# Grab the current version from the spec file
CURRENT_VERSION=$(grep -E "^Version:" "$SPEC_FILE" | awk '{print $2}')

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Already up to date ($CURRENT_VERSION)."
    exit 0
fi

echo "Update found: $CURRENT_VERSION -> $LATEST_VERSION"

# 1. Update the Version and Release fields
sed -i -E "s/^Version:.*/Version:        $LATEST_VERSION/" "$SPEC_FILE"
sed -i -E "s/^Release:.*/Release:        0/" "$SPEC_FILE"

# 2. Update the download URL path in the spec file with the RAW tag
sed -i -E "s|download/[^/]+/LocalSend-[^/]+\.deb|download/$LATEST_TAG/LocalSend-$LATEST_VERSION-linux-x86-64.deb|g" "$SPEC_FILE"

# 3. Update .changes
CURRENT_DATE=$(LC_ALL=C date +"%a %b %d %Y")
NEW_CHANGELOG_ENTRY="* $CURRENT_DATE $PACKAGER - $LATEST_VERSION-0\n- Update localsend to v$LATEST_VERSION\n\n"

if [ -f "$CHANGES_FILE" ]; then
    echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
else
    echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
fi

echo "Successfully updated to $LATEST_VERSION."
