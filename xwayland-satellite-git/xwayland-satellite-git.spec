# These will be automatically populated by update.sh
%global commit          0000000000000000000000000000000000000000
%global shortcommit     a879e5e
%global gitdate         20260316005105

Name:           xwayland-satellite-git
# Automatically combines the base version (0.8.1) with the exact timestamp and commit
Version:        0.8.1+git%{gitdate}.%{shortcommit}
Release:        0
Summary:        Rootless Xwayland integration for Wayland compositors (Nexus Optimized)

License:        MPL-2.0
Group:          System/GUI/Other
URL:            https://github.com/Supreeeme/xwayland-satellite
Source0:        xwayland-satellite-%{shortcommit}.tar.gz
Source1:        vendor.tar.xz
Source2:        cargo_config

ExclusiveArch:  x86_64 aarch64

BuildRequires:  cargo-packaging
BuildRequires:  clang
BuildRequires:  clang-devel
BuildRequires:  llvm-devel
BuildRequires:  gcc-c++
BuildRequires:  systemd-rpm-macros
BuildRequires:  pkgconfig(fontconfig)
BuildRequires:  pkgconfig(wayland-client)
BuildRequires:  pkgconfig(wayland-cursor)
BuildRequires:  pkgconfig(wayland-server)
BuildRequires:  pkgconfig(xcb-cursor)

# OpenSUSE specific naming
Requires:       xwayland
Requires:       google-opensans-fonts

Conflicts:      xwayland-satellite
Provides:       xwayland-satellite = %{version}

%description
xwayland-satellite grants rootless Xwayland integration to any Wayland
compositor implementing xdg_wm_base and viewporter. This package tracks 
the bleeding-edge master branch.

%prep
# Extract Source0 and Source1
%autosetup -n xwayland-satellite-%{commit} -p1 -a1

# Inject offline cargo config
mkdir -p .cargo
cp %{SOURCE2} .cargo/config

# Dynamically fix the executable path in the systemd unit
sed -i 's|/usr/local/bin|/usr/bin|g' resources/xwayland-satellite.service

# Remove vendored decoration font if it exists in the current git tree
rm -f OpenSans-Regular.ttf

%build
# We let Cargo handle the compilation entirely offline with specific features
cargo build --offline --release --features systemd,fontconfig

%install
install -Dpm0755 target/release/xwayland-satellite -t %{buildroot}%{_bindir}
install -Dpm0644 resources/xwayland-satellite.service -t %{buildroot}%{_userunitdir}

%post
%systemd_user_post xwayland-satellite.service

%preun
%systemd_user_preun xwayland-satellite.service

%postun
%systemd_user_postun xwayland-satellite.service

%files
%license LICENSE
%doc README.md
%{_bindir}/xwayland-satellite
%{_userunitdir}/xwayland-satellite.service

%changelog
