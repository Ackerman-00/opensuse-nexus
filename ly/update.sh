#!/bin/bash
# update.sh for Ly display manager (OBS edition)
#
# Ly builds with Zig 0.16 whose package manager fetches pinned git
# dependencies (clap, zigini, termbox2, translate-c) at build time.
# OBS build chroots are offline, so the deps are vendored as a
# pre-populated global cache (ly-zig-cache.tar.gz, containing the
# canonical p/<hash>.tar.gz packages) and served to zig via
# --global-cache-dir. This script regenerates that tarball whenever a
# version bump changes any pinned dependency hash.

SPEC_FILE="ly.spec"
CHANGES_FILE="ly.changes"
CACHE_FILE="ly-zig-cache.tar.gz"
GIT_REPO="https://codeberg.org/fairyglade/ly.git"
ZIG_VERSION="0.16.0"
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

# Pure version comparison guard: exit 0 (no churn) when current == latest.
# Never require local artifact files to exist - they are gitignored and
# absent from CI checkouts.
if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
    echo "  -> ✅ [OK] Ly is already on latest ($CURRENT_VERSION)."
    exit 0
fi

echo "  -> 🚀 [UPDATE] New version detected: $LATEST_VERSION (Current: $CURRENT_VERSION)"

# The Codeberg archive URL exists for every tag (Forgejo generates it on
# demand), but verify it anyway so a stub tag never reaches OBS.
ARCHIVE_URL="https://codeberg.org/fairyglade/ly/archive/$LATEST_TAG.tar.gz"
echo "  -> [CHECK] Verifying $ARCHIVE_URL"
if ! curl --output /dev/null --silent --location --head --fail "$ARCHIVE_URL"; then
    echo "  -> ❌ [ERROR] Codeberg archive for $LATEST_TAG is not available. Skipping update."
    exit 1
fi

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

echo "  -> [FETCH] Downloading source for $LATEST_TAG..."
curl --fail --silent --location --retry 3 "$ARCHIVE_URL" -o "$WORKDIR/ly.tar.gz" || {
    echo "  -> ❌ [ERROR] Download failed; spec left untouched."
    exit 1
}
tar xzf "$WORKDIR/ly.tar.gz" -C "$WORKDIR"
SRCDIR=$(find "$WORKDIR" -mindepth 1 -maxdepth 1 -type d | head -1)

# Collect every pinned dependency hash referenced by the new source. If the
# existing vendored cache already contains all of them, keep it (no churn);
# otherwise regenerate it (network available on the CI runner).
echo "  -> [CHECK] Comparing pinned dependency hashes against $CACHE_FILE"
REQUIRED_HASHES=$(find "$SRCDIR" -name 'build.zig.zon' -print0 | xargs -0 grep -oP '\.hash = "\K[^"]+' | sed 's/^[^:]*://' | sort -u)

CACHE_OK=1
if [ -f "$CACHE_FILE" ] && [ -n "$REQUIRED_HASHES" ]; then
    for h in $REQUIRED_HASHES; do
        if ! tar -tzf "$CACHE_FILE" 2>/dev/null | grep -q "p/${h}\.tar\.gz$"; then
            echo "    -> missing from cache: $h"
            CACHE_OK=0
        fi
    done
else
    CACHE_OK=0
fi

if [ "$CACHE_OK" != "1" ]; then
    echo "  -> [ZIG] Regenerating vendored cache (zig $ZIG_VERSION)..."
    ZIG_TARBALL="$WORKDIR/zig.tar.xz"
    if ! curl --fail --silent --location --retry 3 \
         "https://ziglang.org/download/$ZIG_VERSION/zig-x86_64-linux-$ZIG_VERSION.tar.xz" -o "$ZIG_TARBALL"; then
        echo "  -> ❌ [ERROR] Failed to download zig $ZIG_VERSION; spec left untouched."
        exit 1
    fi
    tar xJf "$ZIG_TARBALL" -C "$WORKDIR"
    ZIGDIR=$(find "$WORKDIR" -mindepth 1 -maxdepth 1 -type d -name 'zig-*' | head -1)

    # Running `zig build` populates the global cache with the canonical
    # p/<hash>.tar.gz packages. Build failures (missing -devel on the CI
    # host) are expected and irrelevant - the cache is what we keep.
    ( cd "$SRCDIR" && "$ZIGDIR/zig" build \
        --global-cache-dir "$WORKDIR/cache" \
        --cache-dir "$WORKDIR/zig-cache" \
        >/dev/null 2>&1 || true )

    if [ ! -d "$WORKDIR/cache/p" ] || [ -z "$(ls -A "$WORKDIR/cache/p" 2>/dev/null)" ]; then
        echo "  -> ❌ [ERROR] Zig failed to fetch dependencies; spec left untouched."
        exit 1
    fi
    for h in $REQUIRED_HASHES; do
        if [ ! -f "$WORKDIR/cache/p/${h}.tar.gz" ]; then
            echo "  -> ❌ [ERROR] Dependency $h was not fetched; spec left untouched."
            exit 1
        fi
    done

    mkdir -p "$WORKDIR/ly-zig-cache"
    cp -r "$WORKDIR/cache/p" "$WORKDIR/ly-zig-cache/"
    # Deterministic output (fixed mtime/sort/owner) so a no-change
    # regeneration produces a byte-identical tarball (no churn commits).
    tar czf "$WORKDIR/$CACHE_FILE" --mtime='@0' --sort=name --owner=0 --group=0 -C "$WORKDIR" ly-zig-cache
    cp "$WORKDIR/$CACHE_FILE" "$CACHE_FILE"
    echo "  -> ✅ Vendored cache regenerated: $(du -h "$CACHE_FILE" | cut -f1)"
else
    echo "  -> ✅ Vendored cache already covers all pinned dependencies."
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