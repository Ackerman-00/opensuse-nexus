%global debug_package %{nil}

# Prevent RPM from trying to auto-generate dependencies from the bundled Electron libraries
%global __requires_exclude_from ^/opt/Vesktop/.*$
%global __provides_exclude_from ^/opt/Vesktop/.*$

Name:           vesktop
Version:        1.6.5
Release:        0
Summary:        Custom Discord desktop client with Vencord preinstalled
License:        GPL-3.0-or-later
Group:          Productivity/Networking/Talk/Clients
URL:            https://github.com/Vencord/Vesktop
Source0:        https://github.com/Vencord/Vesktop/releases/download/v1.6.5/vesktop-1.6.5.x86_64.rpm
# Source1 is the filter file to bypass the "Badness" check
Source1:        vesktop-rpmlintrc

ExclusiveArch:  x86_64

BuildRequires:  cpio
BuildRequires:  hicolor-icon-theme
# Required for desktop file validation
BuildRequires:  update-desktop-files

# Simplified dependencies to satisfy openSUSE policy
Requires:       gtk3
Requires:       xdg-utils
Requires:       hicolor-icon-theme
Requires:       libnotify4

Provides:       vencorddesktop = %{version}-%{release}
Provides:       vesktop = %{version}-%{release}
Obsoletes:      vencorddesktop < %{version}

%description
Vesktop is a custom Discord client designed to enhance your experience.
Repackaged for openSUSE with auto-Wayland support.

%prep
%setup -q -c -T
rpm2cpio %{SOURCE0} | cpio -idmv

%build
# No compilation required

%install
rm -rf %{buildroot}

# 1. Install main app
install -d -m 0755 %{buildroot}/opt/Vesktop
cp -a opt/Vesktop/* %{buildroot}/opt/Vesktop/

# 2. Install icons and desktop files
install -d -m 0755 %{buildroot}%{_datadir}
cp -a usr/share/applications %{buildroot}%{_datadir}/
cp -a usr/share/icons %{buildroot}%{_datadir}/

# 3. Native Wayland Wrapper
install -d -m 0755 %{buildroot}%{_bindir}
cat <<-'EOF' > %{buildroot}%{_bindir}/vesktop
#!/bin/sh
if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    export ELECTRON_OZONE_PLATFORM_HINT="auto"
fi
exec /opt/Vesktop/vesktop "$@"
EOF
chmod 0755 %{buildroot}%{_bindir}/vesktop

# Fix desktop file for openSUSE
%suse_update_desktop_file vesktop

%files
%defattr(-,root,root)
%{_bindir}/vesktop
%{_datadir}/applications/vesktop.desktop
%{_datadir}/icons/hicolor/*/apps/*.*
%dir /opt/Vesktop
%exclude /opt/Vesktop/chrome-sandbox
/opt/Vesktop/*
%attr(4755, root, root) /opt/Vesktop/chrome-sandbox

%changelog
