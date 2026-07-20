# These will be automatically populated by update.sh
%global commit          820e27eaf892c4606a49b6aa0c0bd60c99167cc5
%global shortcommit     820e27e
%global gitdate         20260719091335

%global pkg_name        mangowm
%global src_name        mango

Name:           %{pkg_name}-git
Version:        0.15.2+git%{gitdate}.%{shortcommit}
Release:        0
Summary:        A scrollable-tiling Wayland compositor (Nexus Optimized)

License:        MIT
Group:          System/GUI/Other
URL:            https://github.com/mangowm/mango
Source0:        %{src_name}-%{shortcommit}.tar.gz

ExclusiveArch:  x86_64 aarch64

BuildRequires:  meson
BuildRequires:  ninja
BuildRequires:  pkg-config
BuildRequires:  gcc-c++
BuildRequires:  systemd-rpm-macros
BuildRequires:  fdupes

# Wayland
BuildRequires:  pkgconfig(wayland-client)
BuildRequires:  pkgconfig(wayland-server) >= 1.23.1
BuildRequires:  wayland-protocols-devel

# Graphics/Display
BuildRequires:  pkgconfig(libdrm)
BuildRequires:  pkgconfig(pixman-1)
BuildRequires:  pkgconfig(libinput) >= 1.27.1
BuildRequires:  pkgconfig(xkbcommon)
BuildRequires:  pkgconfig(pangocairo)
BuildRequires:  pkgconfig(libpcre2-8)

# wlroots + scenefx (from X11:Wayland / home projects)
BuildRequires:  pkgconfig(wlroots-0.20) >= 0.20.0
BuildRequires:  pkgconfig(scenefx-0.5) >= 0.5.0

# XWayland support
BuildRequires:  pkgconfig(xcb)
BuildRequires:  pkgconfig(xcb-icccm)

# Utilities
BuildRequires:  pkgconfig(libcjson)

# Runtime
Requires:       xwayland
Requires:       Mesa-dri
Requires:       Mesa-libEGL1

Conflicts:      %{pkg_name}
Provides:       %{pkg_name} = %{version}
Provides:       wayland-compositor

%description
Mango is a Wayland compositor built on wlroots and scenefx with
scrollable-tiling and eye-candy effects. This package tracks the
bleeding-edge main branch.

%prep
%autosetup -n %{src_name}-%{commit}

%build
%meson
%meson_build

%install
%meson_install

# Remove empty or unnecessary dirs if any
%fdupes -s %{buildroot}%{_prefix}

%files
%license LICENSE
%doc README.md
%{_bindir}/mango
%{_bindir}/mmsg
%{_mandir}/man1/mmsg.1*

# Session
%dir %{_datadir}/wayland-sessions
%{_datadir}/wayland-sessions/mango.desktop

# Portal
%dir %{_datadir}/xdg-desktop-portal
%{_datadir}/xdg-desktop-portal/mango-portals.conf

# Config (sysconfdir)
%dir %{_sysconfdir}/mango
%config(noreplace) %{_sysconfdir}/mango/config.conf

%changelog
