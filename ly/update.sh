#!/bin/bash
# update.sh for Ly display manager (OBS edition)

SPEC_FILE="ly.spec"
CHANGES_FILE="ly.changes"
GIT_REPO="https://codeberg.org/fairyglade/ly.git"
PACKAGER="Ackerman-00 <quietcraft@gmail.com>"

echo "🔍 Checking for upstream updates on codeberg.org/fairyglade/ly..."

# Get latest tag via git ls-remote (no rate limit)
LATEST_TAG=$(git ls-remote --tags "$GIT_REPO" 2>/dev/null | awk '{print $2}' | sed 's|refs/tags/||;s/\^{}//' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)

if [ -z "$LATEST_TAG" ]; then
    echo "  -> ❌ [ERROR] Failed to fetch latest tag."
    exit 1
fi

LATEST_VERSION="${LATEST_TAG#v}"

# Read current version from the spec file
CURRENT_VERSION=$(grep -E "^Version:" "$SPEC_FILE" | awk '{print $2}')

# Compare and update
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "  -> 🚀 [UPDATE] New version detected: $LATEST_VERSION (Current: $CURRENT_VERSION)"

    # The Codeberg archive URL exists for every tag (Forgejo generates it on
    # demand), but verify it anyway so a stub tag never reaches OBS.
    ARCHIVE_URL="https://codeberg.org/fairyglade/ly/archive/$LATEST_TAG.tar.gz"
    echo "  -> [CHECK] Verifying $ARCHIVE_URL"
    if ! curl --output /dev/null --silent --location --head --fail "$ARCHIVE_URL"; then
        echo "  -> ❌ [ERROR] Codeberg archive for $LATEST_TAG is not available. Skipping update."
        exit 1
    fi

    # 1. Update the Version and Release fields
    sed -i "s/^Version:\s*.*/Version:        $LATEST_VERSION/" "$SPEC_FILE"
    sed -i "s/^Release:\s*.*/Release:        0/" "$SPEC_FILE"

    # 2. Prepend an entry to the OBS changes file
    DATE=$(LC_ALL=C date +"%a %b %d %T UTC %Y")
    NEW_CHANGELOG_ENTRY="-------------------------------------------------------------------\n$DATE - $PACKAGER\n\n- Update to upstream release $LATEST_TAG\n\n"

    if [ -f "$CHANGES_FILE" ]; then
        echo -e "$NEW_CHANGELOG_ENTRY$(cat $CHANGES_FILE)" > "$CHANGES_FILE"
    else
        echo -e "$NEW_CHANGELOG_ENTRY" > "$CHANGES_FILE"
    fi

    echo "  -> ✅ [DONE] $SPEC_FILE is ready for OBS sync."
else
    echo "  -> ✅ [OK] Ly is already on latest ($CURRENT_VERSION)."
fi