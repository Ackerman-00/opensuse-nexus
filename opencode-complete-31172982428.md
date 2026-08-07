# opencode-auto complete — Run 31172982428 (2026-08-07)

Autonomous maintainer pass for opensuse-nexus (home:ackerman OBS project).

**Run ID:** 31172982428
**Completed:** 2026-08-07

## Summary

Verification-only pass. Nothing was broken or outdated this run: all 17
packages build clean on OBS (Tumbleweed + Slowroll), all packaged versions
match real upstream, OBS specs match local, no open issues, no open PRs, and
the auto-updater correctly advanced 3 packages which were install-tested in
fresh Tumbleweed containers. No spec/source/updater edits were required.

## 1. Version Inventory Table (100% coverage — all 17 packages)

| Package | Packaged Ver | Upstream Latest | Status |
|---------|--------------|-----------------|--------|
| bibata-cursor-theme | 2.0.7 | v2.0.7 | up-to-date |
| fluxer | 2026.731.153836 | X-Fluxer-Version 2026.731.153836 | up-to-date |
| localsend | 1.17.0 | v1.17.0 | up-to-date |
| mangowm-git | 0.15.6+git20260807073239.38fd988 | main HEAD 38fd988 | up-to-date |
| matugen | 4.1.0 | v4.1.0 | up-to-date |
| niri-git | 26.04+git20260802200721.feb3e43 | main HEAD feb3e43 | up-to-date |
| noctalia | 5.0.0~beta7 | v5.0.0-beta.7 | up-to-date |
| noctalia-greeter | 1.2.1 | v1.2.1 | up-to-date |
| obsidian | 1.13.4 | v1.13.4 | up-to-date |
| opencode-desktop | 1.18.15 | v1.18.15 | up-to-date |
| rootapp | 0.9.126 | AppImage X-AppImage-Version 0.9.126 | up-to-date |
| scenefx | 0.5 | tag 0.5 | up-to-date |
| stb | 20260802 | master HEAD 2c980bb (2026-08-02) | up-to-date |
| vesktop | 1.6.5 | v1.6.5 | up-to-date |
| wlroots | 0.20.2 | GitLab 0.20.2 | up-to-date |
| xwayland-satellite-git | 0.8.2+git20260722002452.8d135d3 | main HEAD 8d135d3 | up-to-date |
| zen-browser | 1.21.12b | 1.21.12b | up-to-date |

## 2. Failed Builds (Step 1)

None. All 17 packages `succeeded` on openSUSE_Tumbleweed and
openSUSE_Slowroll (34/34), verified via `_result?view=status`. mangowm-git
was briefly `blocked` on Slowroll waiting for scenefx dep; it resolved to
`succeeded` on both repos.

## 3. Auto-Updater Health (Step 3)

Last full auto-updater run (31171193981) completed **success**. It advanced
3 packages that genuinely changed upstream (mangowm-git, opencode-desktop,
zen-browser) — all verified current. No broken updaters; all 16 update.sh
pass `bash -n`; no-churn commit-SHA guards verified in mangowm/niri/
xwayland updaters.

## 4. Issues / PRs (Steps 4 & 5)

None open. No action.

## 5. Dependency Audit Table (Step 6, 100% coverage)

| Package | Upstream deps found | In spec | Missing/Added | Status |
|---------|--------------------|---------|---------------|--------|
| bibata-cursor-theme | noarch, no deps | - | none | deps-verified |
| fluxer | Electron runtime libs | soname Requires | none | deps-verified |
| localsend | Flutter libs | present | none | deps-verified |
| mangowm-git (changed) | meson.build deps (wlroots-0.20, scenefx-0.5, wayland, libinput, xkbcommon, xcb, xcb-icccm, libcjson, libpcre2-8, libdrm, pixman, pangocairo, libm) | all present | none | deps-verified |
| matugen | Rust (vendored) | cargo-packaging | none | deps-verified |
| niri-git | Rust vendored | present | none | deps-verified |
| noctalia | pkgconfig set | present | none | deps-verified |
| noctalia-greeter | wlroots-devel | present | none | deps-verified |
| obsidian | electron+bash | present | none | deps-verified |
| opencode-desktop | Electron sonames | present | none | deps-verified |
| rootapp | AppImage torn (GTK/NSS) | present | none | deps-verified |
| scenefx | wlroots-0.20 | present | none | deps-verified |
| stb | header only | present | none | deps-verified |
| vesktop | Electron sonames | present | none | deps-verified |
| wlroots | pkgconfig set | present | none | deps-verified |
| xwayland-satellite-git | rustc+systemd | present | none | deps-verified |
| zen-browser | Firefox runtime | present | none | deps-verified |

## 7. INSTALL-VERIFICATION SWEEP (my changed packages)

| Package | OBS Build | zypper install test | smoke | status |
|---------|-----------|--------------------:|--------|--------|
| mangowm-git | succeeded (TW+SL) | PASS (fresh tumbleweed, pulls nexus libwlroots/libscenefx) | n/a compositor | installable |
| opencode-desktop | succeeded (TW+SL) | PASS | Electron launch | installable |
| zen-browser | succeeded (TW+SL) | PASS | "Mozilla Zen 1.21.12b" | installable |

(14 remaining packages unchanged since prior install-test, prior results valid.)

## Pre-Completion Gate

1. git status clean work tree — PASS
2. Every touched package has fresh install-test — PASS
3. Ledger updated in relay — PASS
4. Dep audit covers 100% — PASS
5. All claims command-backed — PASS
6. Not-verified stated — PASS (headless GUI smoke, aarch64)
7. complete marker committed & pushed — PASS (this file)

Not verified: functional GUI launching of compositor/desktop apps headless;
aarch64; Slowroll separate container installs.