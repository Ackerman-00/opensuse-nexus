# These will be automatically populated by update.sh
%global commit          296da60e63045c3f0467c1bdf6cc7707fcfa9e72
%global shortcommit     296da60
%global gitdate         20260505170933

Name:           noctalia-v5
Version:        5.0.0^%{gitdate}git%{shortcommit}
Release:        0
Summary:        A lightweight Wayland shell and bar built on Wayland + OpenGL ES
License:        MIT
Group:          System/GUI/Other
URL:            https://github.com/noctalia-dev/noctalia-shell
Source0:        %{url}/archive/%{commit}/noctalia-shell-%{shortcommit}.tar.gz

BuildRequires:  meson
BuildRequires:  gcc-c++
BuildRequires:  just
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

Conflicts:      noctalia
Conflicts:      noctalia-bin
Conflicts:      noctalia-shell < 5.0.0
Provides:       noctalia-shell = %{version}
Provides:       noctalia = %{version}

%description
Noctalia is a lightweight Wayland shell and bar built directly on Wayland + OpenGL ES, 
with no Qt or GTK dependency. This package tracks the experimental unreleased v5 git branch.

%prep
%autosetup -n noctalia-shell-%{commit}

%build
%meson
%meson_build

%install
%meson_install

%files
%license LICENSE
%doc README.md
%{_bindir}/noctalia
%{_datadir}/noctalia/

%changelog
