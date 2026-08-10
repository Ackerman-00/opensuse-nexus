# Raw upstream tag version (GitHub archive dir uses this, no v prefix)
%global tagver 5.0.0-beta.8

Name:           noctalia
Version:        5.0.0~beta8
Release:        0
Summary:        A sleek and minimal desktop shell thoughtfully crafted for Wayland.
License:        MIT
Group:          System/GUI/Other
URL:            https://github.com/noctalia-dev/noctalia
Source0:        %{url}/archive/refs/tags/v%{tagver}/%{name}-%{tagver}.tar.gz

BuildRequires:  meson
BuildRequires:  gcc-c++
BuildRequires:  fdupes
BuildRequires:  hicolor-icon-theme
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(wayland-client)
BuildRequires:  pkgconfig(wayland-egl)
BuildRequires:  pkgconfig(wayland-protocols)
BuildRequires:  pkgconfig(epoxy)
BuildRequires:  pkgconfig(egl)
BuildRequires:  pkgconfig(glesv2)
BuildRequires:  pkgconfig(freetype2)
BuildRequires:  pkgconfig(fontconfig)
BuildRequires:  pkgconfig(cairo)
BuildRequires:  pkgconfig(cairo-ft)
BuildRequires:  pkgconfig(pango)
BuildRequires:  pkgconfig(pangocairo)
BuildRequires:  pkgconfig(pangoft2)
BuildRequires:  pkgconfig(harfbuzz)
BuildRequires:  pkgconfig(xkbcommon)
BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(gobject-2.0)
BuildRequires:  pkgconfig(gio-2.0)
BuildRequires:  pkgconfig(libsecret-1)
BuildRequires:  pkgconfig(libsodium)
BuildRequires:  pkgconfig(sdbus-c++) >= 2.0.0
BuildRequires:  pkgconfig(libpipewire-0.3)
BuildRequires:  pkgconfig(wireplumber-0.5)
BuildRequires:  pkgconfig(pam)
BuildRequires:  pkgconfig(polkit-agent-1)
BuildRequires:  pkgconfig(polkit-gobject-1)
BuildRequires:  pkgconfig(libcurl)
BuildRequires:  pkgconfig(libwebp)
BuildRequires:  pkgconfig(libjxl)
BuildRequires:  pkgconfig(libjxl_threads)
BuildRequires:  pkgconfig(sndfile)
BuildRequires:  pkgconfig(librsvg-2.0)
BuildRequires:  pkgconfig(libqalculate)
BuildRequires:  pkgconfig(libxml-2.0)
BuildRequires:  pkgconfig(md4c)
BuildRequires:  pkgconfig(tomlplusplus)
BuildRequires:  pkgconfig(libical)
BuildRequires:  pkgconfig(nlohmann_json)
BuildRequires:  pkgconfig(stb)
BuildRequires:  pkgconfig(jemalloc)

Requires:       qalculate

Recommends:     upower

Conflicts:      noctalia-git

%description
A lightweight Wayland shell and bar built directly on Wayland + OpenGL ES,
with no Qt or GTK dependency.

Noctalia is in early development. Expect breaking configuration and
behavior changes while the project is still taking shape.

%prep
%autosetup -n noctalia-%{tagver}

%build
%meson
%meson_build

%install
%meson_install

find %{buildroot}%{_datadir}/noctalia/assets/templates \
	-type f -name '*.sh' \
	-exec sed -i '1s|^#!/usr/bin/env bash$|#!/usr/bin/bash|' {} +

find %{buildroot}%{_datadir}/noctalia/assets/templates \
	-type f -name '*.py' \
	-exec sed -i '1s|^#!/usr/bin/env python3$|#!/usr/bin/python3|' {} +

find %{buildroot}%{_datadir}/noctalia/assets/templates \
	-type f \( -name '*.sh' -o -name '*.py' \) \
	-exec chmod 0755 {} +

%fdupes %{buildroot}%{_datadir}

%files
%defattr(-,root,root)
%license LICENSE
%doc README.md
%{_bindir}/noctalia
%{_datadir}/noctalia
%{_datadir}/applications/dev.noctalia.Noctalia.desktop
%{_datadir}/icons/hicolor/scalable/apps/noctalia.svg

%changelog
