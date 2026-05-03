%global debug_package %{nil}

%global __requires_exclude_from ^/opt/Vesktop/.*$
%global __provides_exclude_from ^/opt/Vesktop/.*$

Name:           vesktop
Version:        1.6.5
Release:        0
Summary:        Custom Discord desktop client with Vencord preinstalled (Nexus Optimized)
License:        GPL-3.0-or-later
Group:          Productivity/Networking/Talk/Clients
URL:            https://github.com/Vencord/Vesktop
Source0:        https://github.com/Vencord/Vesktop/releases/download/v1.6.5/vesktop-1.6.5.x86_64.rpm

ExclusiveArch:  x86_64


BuildRequires:  cpio

BuildRequires:  hicolor-icon-theme

Requires:       gtk3
Requires:       libnotify4
Requires:       mozilla-nss
Requires:       libXss1
Requires:       libXtst6
Requires:       xdg-utils
Requires:       at-spi2-core
Requires:       util-linux
Requires:       libsecret-1-0
Requires:       libgbm1
Requires:       libasound2
Requires:       libappindicator3-1
Requires:       hicolor-icon-theme

Provides:       vencorddesktop = %{version}-%{release}
Provides:       vesktop = %{version}-%{release}
Obsoletes:      vencorddesktop < %{version}

%description
Vesktop is a custom Discord client designed to enhance your experience while keeping everything lightweight.
Packaged exclusively for the Nexus repository. This version bypasses bloated source compilation by natively extracting the upstream RPM, enforces strict sandbox permissions, and includes an auto-Wayland wrapper.

%prep
%setup -q -c -T
# Rip open the upstream RPM natively
rpm2cpio %{SOURCE0} | cpio -idmv

%build
# No compilation required for pre-built binaries

%install
rm -rf %{buildroot}

# 1. Install the main application folder
install -d -m 0755 %{buildroot}/opt/Vesktop
cp -a opt/Vesktop/* %{buildroot}/opt/Vesktop/

# 2. Install standard desktop entries and icons
install -d -m 0755 %{buildroot}%{_datadir}
cp -a usr/share/applications %{buildroot}%{_datadir}/
cp -a usr/share/icons %{buildroot}%{_datadir}/

# 3. Create the Native Wayland Wrapper Script
install -d -m 0755 %{buildroot}%{_bindir}
cat <<-'EOF' > %{buildroot}%{_bindir}/vesktop
#!/bin/sh
# Automatically force native Wayland rendering if detected
if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    export ELECTRON_OZONE_PLATFORM_HINT="auto"
fi
exec /opt/Vesktop/vesktop "$@"
EOF
chmod 0755 %{buildroot}%{_bindir}/vesktop

# Bypass openSUSE's strict build checks for pre-compiled binaries
export NO_BRP_CHECK_RPATH=true

%files
%defattr(-,root,root)
%{_bindir}/vesktop
%{_datadir}/applications/*.desktop
%{_datadir}/icons/hicolor/*/apps/*.*
%dir /opt/Vesktop
# Exclude chrome-sandbox from the generic wildcard so it isn't listed twice
%exclude /opt/Vesktop/chrome-sandbox
/opt/Vesktop/*
# Enforce strict sandbox permissions natively
%attr(4755, root, root) /opt/Vesktop/chrome-sandbox

%changelog
