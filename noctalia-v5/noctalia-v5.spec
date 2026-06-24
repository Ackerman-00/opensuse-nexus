# These will be automatically populated by update.sh
%global commit          842bd87a5b88e73a9f7f29df0fac768325a6b285
%global shortcommit     842bd87
%global gitdate         20260624194334

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
# New dependencies added per upstream v5 announcement
BuildRequires:  pkgconfig(libqalculate)
BuildRequires:  pkgconfig(libxml-2.0)
# Missing dependency that causes Meson to abort
BuildRequires:  jemalloc-devel

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

%meson -Db_ndebug=true
%meson_build

%install
%meson_install

%files
%license LICENSE
%doc README.md
%{_bindir}/noctalia
%{_datadir}/noctalia/

%changelog
