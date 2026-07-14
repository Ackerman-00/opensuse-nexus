# These will be automatically populated by update.sh
%global commit          7202c6890fbf6448f37d134918ec7393f368bb80
%global shortcommit     7202c68
%global gitdate         20260714021108

Name:           noctalia-v5
Version:        5.0.0^%{gitdate}git%{shortcommit}
Release:        0
Summary:        A lightweight Wayland shell and bar built on Wayland + OpenGL ES
License:        MIT
Group:          System/GUI/Other
URL:            https://github.com/noctalia-dev/noctalia
Source0:        %{url}/archive/%{commit}/noctalia-%{shortcommit}.tar.gz

ExclusiveArch:  x86_64 aarch64

BuildRequires:  meson
BuildRequires:  gcc-c++
BuildRequires:  pkgconfig(wayland-client)
BuildRequires:  pkgconfig(wayland-protocols)
BuildRequires:  pkgconfig(egl)
BuildRequires:  pkgconfig(glesv2)
BuildRequires:  pkgconfig(freetype2)
BuildRequires:  pkgconfig(fontconfig)
BuildRequires:  pkgconfig(cairo)
BuildRequires:  pkgconfig(pango)
BuildRequires:  pkgconfig(xkbcommon)
BuildRequires:  sdbus-cpp-devel
BuildRequires:  pkgconfig(libpipewire-0.3)
BuildRequires:  pam-devel
BuildRequires:  pkgconfig(libcurl)
BuildRequires:  pkgconfig(libwebp)
BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  polkit-devel
BuildRequires:  pkgconfig(librsvg-2.0)
BuildRequires:  pkgconfig(libqalculate)
BuildRequires:  pkgconfig(libxml-2.0)
BuildRequires:  jemalloc-devel
BuildRequires:  wireplumber-devel
BuildRequires:  tomlplusplus-devel
BuildRequires:  md4c-devel
BuildRequires:  json-devel
BuildRequires:  stb-devel
BuildRequires:  libglvnd-devel

Requires:       polkit

Conflicts:      noctalia
Conflicts:      noctalia-bin
Conflicts:      noctalia-shell < 5.0.0
Provides:       noctalia-shell = %{version}
Provides:       noctalia = %{version}

%description
Noctalia is a lightweight Wayland shell and bar built directly on Wayland + OpenGL ES, 
with no Qt or GTK dependency. This package tracks the bleeding-edge main branch (formerly the v5 experimental branch).

%prep
# The upstream tarball now extracts to noctalia-%{commit}
%autosetup -n noctalia-%{commit}

%build
# Force C++23 standard to fix the std::string_view 'contains' compiler error
# Add -Wno-unused-result to bypass strict GCC warnings, matching the Arch PKGBUILD
export CXXFLAGS="%{optflags} -std=c++23 -Wno-unused-result"
export CFLAGS="%{optflags}"

%meson -Db_ndebug=true -Dtests=disabled
%meson_build

%install
%meson_install

%files
%license LICENSE
%doc README.md
%{_bindir}/noctalia
%{_datadir}/noctalia/
%{_datadir}/applications/dev.noctalia.Noctalia.desktop
%{_datadir}/icons/hicolor/scalable/apps/noctalia.svg

%changelog
