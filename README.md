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
# 1. Add the OBS repository (as root)
zypper addrepo https://download.opensuse.org/repositories/home:ackerman/openSUSE_Tumbleweed/home:ackerman.repo
zypper refresh

# 2. Install a package (example)
zypper install zen-browser
```

> [!NOTE]
> For **Slowroll**, use `openSUSE_Slowroll` in the URL instead of `openSUSE_Tumbleweed`:
>
> ```bash
> zypper addrepo https://download.opensuse.org/repositories/home:ackerman/openSUSE_Slowroll/home:ackerman.repo
> zypper refresh
> ```

### List available packages

```bash
zypper se --repo nexus
```

Or **[browse all packages and their builds online](https://build.opensuse.org/project/show/home:ackerman)**.

---

## Packages

| Package | Description | Install |
|---|---|---|
| **bibata-cursor-theme** | Open source, compact, material designed cursor set | `sudo zypper install bibata-cursor-theme` |
| **fluxer** | Free and open source messaging & VoIP platform | `sudo zypper install fluxer` |
| **localsend** | Open source cross-platform alternative to AirDrop | `sudo zypper install localsend` |
| **mangowm-git** | Scrollable-tiling Wayland compositor (Nexus optimized) | `sudo zypper install mangowm-git` |
| **matugen** | Material You color generation tool | `sudo zypper install matugen` |
| **noctalia** | Sleek minimal Wayland desktop shell | `sudo zypper install noctalia` |
| **noctalia-greeter** | Greeter for Noctalia (greetd login screen) | `sudo zypper install noctalia-greeter` |
| **niri-git** | Scrollable-tiling Wayland compositor | `sudo zypper install niri-git` |
| **obsidian** | Knowledge base for plain-text Markdown notes | `sudo zypper install obsidian` |
| **opencode-desktop** | Open source AI coding agent | `sudo zypper install opencode-desktop` |
| **rootapp** | Run GUI apps as root via Polkit | `sudo zypper install rootapp` |
| **scenefx** | Drop-in wlroots scene API replacement with eye-candy effects | `sudo zypper install scenefx` |
| **stb** | Single-file public domain libraries for C/C++ | `sudo zypper install stb-devel` |
| **vesktop** | Custom Discord client with Vencord preinstalled | `sudo zypper install vesktop` |
| **wlroots** | Modular Wayland compositor library | `sudo zypper install wlroots` |
| **xwayland-satellite-git** | Rootless Xwayland integration for Wayland compositors | `sudo zypper install xwayland-satellite-git` |
| **zen-browser** | Minimal browser focused on privacy and calm browsing | `sudo zypper install zen-browser` |

---

## Build status

Automated OBS builds are triggered on every push to `main` (via the `update-packages.yml` pipeline) and every ~2h the autonomous opencode maintainer verifies and repairs failed builds.

| Project | Status |
|---|---|
| `home:ackerman` | [View builds](https://build.opensuse.org/project/show/home:ackerman) |
