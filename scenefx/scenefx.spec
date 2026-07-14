%global version_underscore 0_5
%global version_dot 0.5

Name:           scenefx
Version:        0.5.0
Release:        0
Summary:        Drop-in replacement for wlroots scene API with eye-candy effects
License:        MIT
URL:            https://github.com/wlrfx/scenefx
Source0:        %{url}/archive/%{version}/%{name}-%{version}.tar.gz

BuildRequires:  meson >= 1.3
BuildRequires:  gcc-c++
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(egl)
BuildRequires:  pkgconfig(gbm)
BuildRequires:  pkgconfig(glesv2)
BuildRequires:  pkgconfig(libdrm) >= 2.4.129
BuildRequires:  pkgconfig(pixman-1) >= 0.43.0
BuildRequires:  pkgconfig(xkbcommon) >= 1.8.0
BuildRequires:  pkgconfig(wlroots-0.20) >= 0.20.0
BuildRequires:  pkgconfig(wayland-server) >= 1.24.0
BuildRequires:  pkgconfig(wayland-protocols)

%description
SceneFX is a drop-in replacement for the wlroots scene API that
allows Wayland compositors to render surfaces with eye-candy
effects including blur, shadows, and rounded corners.

%package -n libscenefx-%{version_underscore}
Summary:        SceneFX shared library
Group:          System/Libraries

%description -n libscenefx-%{version_underscore}
SceneFX shared library providing eye-candy rendering effects
for wlroots-based Wayland compositors.

%package devel
Summary:        Development files for SceneFX
Group:          Development/Libraries/C and C++
Requires:       libscenefx-%{version_underscore} = %{version}

%description devel
Headers and pkg-config files for developing against SceneFX,
a drop-in replacement for the wlroots scene API with support
for blur, shadows, and rounded corners.

%prep
%autosetup -n %{name}-%{version}

%build
%meson \
    -Dexamples=false
%meson_build

%install
%meson_install

%ldconfig_scriptlets -n libscenefx-%{version_underscore}

%files -n libscenefx-%{version_underscore}
%license LICENSE
%{_libdir}/libscenefx-%{version_dot}.so

%files devel
%doc README.md
%{_includedir}/%{name}-%{version_dot}/
%{_libdir}/pkgconfig/%{name}-%{version_dot}.pc

%changelog
