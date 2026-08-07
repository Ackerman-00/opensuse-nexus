# opencode Maintenance Run — 31136326049 (2026-08-07)

**Result: All systems green. No package changes needed this run.**

This was a clean maintenance pass. Every package was verified current against
upstream, all OBS builds succeeded/published on Tumbleweed + Slowroll, and all
17 binary packages install-tested in fresh Tumbleweed containers using the
exact user path (`zypper in` from the home:ackerman repo).

## Full Final Summary

### 1. Failed OBS builds — none
`_result?view=status` showed all 17 packages `succeeded`/`published` on both
openSUSE_Tumbleweed and openSUSE_Slowroll (x86_64). No failed/broken/
unresolvable builds.

### 2. Version inventory sweep — 100% covered, all UPDATED/up-to-date

| Package | Packaged version | Upstream latest | Status |
|---------|-----------------|-----------------|--------|
| bibata-cursor-theme | 2.0.7 | v2.0.7 | up-to-date |
| fluxer | 2026.731.153836 | 2026.731.153836 (API header) | up-to-date |
| localsend | 1.17.0 | v1.17.0 | up-to-date |
| mangowm-git | 0.15.6+git20260806133312.c33047e | c33047e (main HEAD) | up-to-date |
| matugen | 4.1.0 | v4.1.0 | up-to-date |
| niri-git | 26.04+git20260802200721.feb3e43 | feb3e43 (main HEAD) | up-to-date |
| noctalia | 5.0.0~beta7 | v5.0.0-beta.7 | up-to-date |
| noctalia-greeter | 1.2.1 | v1.2.1 | up-to-date |
| obsidian | 1.13.4 | v1.13.4 | up-to-date |
| opencode-desktop | 1.18.14 | v1.18.14 | up-to-date |
| rootapp | 0.9.126 | 0.9.126 (AppImage internal) | up-to-date |
| scenefx | 0.5 | 0.5 | up-to-date |
| stb | 20260802 | 2c980bb (master HEAD) | up-to-date |
| vesktop | 1.6.5 | v1.6.5 | up-to-date |
| wlroots | 0.20.2 | 0.20.2 | up-to-date |
| xwayland-satellite-git | 0.8.2+git20260722002452.8d135d3 | 8d135d3 (main HEAD) | up-to-date |
| zen-browser | 1.21.11b | 1.21.11b | up-to-date |

Evidence: GitHub API (gh api releases/latest + tags + commits), GitLab API for
wlroots, fluxer `X-Fluxer-Version` header (HTTP 200), rootapp AppImage torn
apart (sha256 0736926f...d910 matches spec comment; internal
X-AppImage-Version=0.9.126 matches spec Version).

No wrong versions, no stale versions. No bumps required.

### 3. GitHub Actions health
Latest auto-updater run 31136010661 succeeded (2026-08-07 00:50). The only
recent failure was opencode-schedule run 31101046955 (2026-08-06 12:21),
which died on a transient LLM API `503 "The request queue is full"` — an
upstream infra error, not a repo/workflow bug. Nothing to fix in workflows.

### 4. Open issues
- Issue #1 "autonomous run failed: 2026-08-06" — **CLOSED** with comment.
  Root cause: transient LLM 503 in run 31101046955, not a repo bug.

### 5. Open PRs
None.

## Install-verification sweep — 17/17 PASS (20260807, fresh containers)

Every test: fresh `docker run registry.opensuse.org/opensuse/tumbleweed:latest`,
add OSS + home:ackerman repos, `zypper in <pkg>`. Each run a brand-new container
(no mounted state, no leftover repo metadata).

| Package | OBS build | zypper install | Smoke | Status |
|---------|-----------|----------------|-------|--------|
| bibata-cursor-theme | succeeded | PASS | skip (noarch theme) | installable |
| fluxer | succeeded | PASS | skip (GUI) | installable |
| localsend | succeeded | PASS | skip (GUI) | installable |
| mangowm-git | succeeded | PASS | skip (compositor) | installable |
| matugen | succeeded | PASS | PASS (--version) | installable |
| niri-git | succeeded | PASS | skip (compositor) | installable |
| noctalia | succeeded | PASS | skip (GUI) | installable |
| noctalia-greeter | succeeded | PASS | skip (greeter) | installable |
| obsidian | succeeded | PASS | skip (GUI) | installable |
| opencode-desktop | succeeded | PASS | skip (GUI) | installable |
| rootapp | succeeded | PASS | skip (GUI) | installable |
| libscenefx-0_5 | succeeded | PASS | – (lib) | installable |
| stb-devel | succeeded | PASS | – (headers) | installable |
| vesktop | succeeded | PASS | skip (GUI) | installable |
| libwlroots-0_20 | succeeded | PASS | – (lib) | installable |
| xwayland-satellite-git | succeeded | PASS | skip (service) | installable |
| zen-browser | succeeded | PASS | skip (GUI) | installable |

### Dependency deep audit — 100% covered
Method: OBS `_builddepinfo` ground truth (all 17 packages resolved their full
BuildRequires sets; builds succeeded) + clean-container zypper installs (proves
every Requires name exists in openSUSE repos). All packages `deps-verified`,
no missing/added/extra deps. Full table in .opencode-relay.md.

## What was NOT verified
1. GUI runtime/smoke for most apps (no compositor in headless container).
2. Slowroll container install (identical binaries/toolchain to TW; SL builds
   publish — TW proof per repo policy).
3. aarch64 builds (all x86_64-targeted).

## Pre-Completion Gate Checklist

| # | Gate | Status | Evidence |
|---|------|--------|----------|
| 1 | `git status --porcelain` empty | PASS | `git status --porcelain` → empty before final commit |
| 2 | Every touched package has passing install test in clean container | PASS | 17/17 PASS, fresh containers 20260807 (matugen smoke too) |
| 3 | Coverage ledger updated in .opencode-relay.md | PASS | Ledger in relay file updated 20260807 |
| 4 | Dependency audit table covers 100% inventory | PASS | All 17 in table, deps-verified |
| 5 | Every claim backed by command output | PASS | Versions via gh api/curl headers/AppImage sha256; builds via OBS _result; installs via docker logs |
| 6 | What was NOT verified stated | PASS | See "Not Verified" above |
| 7 | opencode-complete-31136326049.md committed + pushed | PASS | This file |

## What remains
Nothing. All work complete. Next scheduled run performs a fresh maintenance
pass. (No package changed, so no XBS re-sync / rebuild was triggered — none was
needed; that is the correct no-churn outcome.)