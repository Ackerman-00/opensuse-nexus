# ⚡ Nexus (openSUSE)

[![OBS](https://img.shields.io/badge/OBS-home:ackerman-73BA25?style=for-the-badge&logo=opensuse)](https://build.opensuse.org/project/show/home:ackerman)
[![Build](https://img.shields.io/badge/build-status-73BA25?style=for-the-badge&logo=opensuse)](https://build.opensuse.org/project/show/home:ackerman)

**Bleeding-edge Wayland & gaming packages for openSUSE**

Curated packages optimized for minimal Wayland compositors (Niri, Mangowm) and high-performance gaming. Recipes live in [opensuse-nexus](https://github.com/Ackerman-00/opensuse-nexus) and are built on the [openSUSE Build Service](https://build.opensuse.org/project/show/home:ackerman).

> [!TIP]
> Packages update automatically — just run `sudo zypper dup` as usual.

---

## Installation

```bash
# 1. Add the OBS repository
sudo zypper addrepo --refresh "https://download.opensuse.org/repositories/home:ackerman/openSUSE_Tumbleweed/home:ackerman.repo" nexus

# 2. Install a package (example)
sudo zypper install zen-browser
```

> [!NOTE]
> The URL above targets **openSUSE Tumbleweed**. For Leap, replace `openSUSE_Tumbleweed` with your release (e.g. `openSUSE_Leap_15.6`) in the `.repo` URL, or grab it from the project's *Download repository* section.

### List available packages

```bash
zypper se --repo nexus
```

Or **[browse all packages and their builds online](https://build.opensuse.org/project/show/home:ackerman)**.

---

## Packages

| Package | Description | Install |
|---|---|---|
| **fluxer** | Free and open source messaging & VoIP platform | `sudo zypper install fluxer` |
| **mangowm-git** | Scrollable-tiling Wayland compositor (Nexus optimized) | `sudo zypper install mangowm-git` |
| **matugen** | Material You color generation tool | `sudo zypper install matugen` |
| **niri-git** | Scrollable-tiling Wayland compositor | `sudo zypper install niri-git` |
| **obsidian** | Knowledge base for plain-text Markdown notes | `sudo zypper install obsidian` |
| **rootapp** | Run GUI apps as root via Polkit | `sudo zypper install rootapp` |
| **scenefx** | Drop-in wlroots scene API replacement with eye-candy effects | `sudo zypper install scenefx` |
| **vesktop** | Custom Discord client with Vencord preinstalled | `sudo zypper install vesktop` |
| **wlroots** | Modular Wayland compositor library | `sudo zypper install wlroots` |
| **xwayland-satellite-git** | Rootless Xwayland integration for Wayland compositors | `sudo zypper install xwayland-satellite-git` |
| **zen-browser** | Minimal browser focused on privacy and calm browsing | `sudo zypper install zen-browser` |

---

## Build status

Automated OBS builds are triggered on every push to `main` (via the `update-packages.yml` pipeline) and every ~4h the autonomous opencode maintainer verifies and repairs failed builds.

| Project | Status |
|---|---|
| `home:ackerman` | [View builds](https://build.opensuse.org/project/show/home:ackerman) |
