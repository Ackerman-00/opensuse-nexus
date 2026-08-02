%global appid app.fluxer.Fluxer

%global debug_package %{nil}

# Prevent RPM from trying to auto-generate dependencies from the bundled Electron libraries
%global __requires_exclude_from ^/usr/lib64/%{name}/.*$
%global __provides_exclude_from ^/usr/lib64/%{name}/.*$

Name:           fluxer
Version:        2026.731.153836
Release:        0
Summary:        Free and open source instant messaging and VoIP platform
License:        AGPL-3.0-or-later AND BSD
Group:          Productivity/Networking/Talk/Clients
URL:            https://fluxer.app
Source0:        https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/rpm
Source1:        fluxer-rpmlintrc

ExclusiveArch:  x86_64

BuildRequires:  cpio
BuildRequires:  hicolor-icon-theme

# Simplified dependencies to satisfy openSUSE policy
Requires:       gamemode
Requires:       mangohud

%description
Fluxer is a free and open source instant messaging and VoIP platform built for
friends, groups, and communities. Self-hosting and more.

%prep
%setup -q -c -T
rpm2cpio %{SOURCE0} | cpio -idmv

%build
# No compilation required

%install
rm -rf %{buildroot}

# 1. Install main app
install -d -m 0755 %{buildroot}%{_libdir}/%{name}
cp -a opt/Fluxer/* %{buildroot}%{_libdir}/%{name}/

# 2. Launcher wrapper
install -d -m 0755 %{buildroot}%{_bindir}
cat > %{buildroot}%{_bindir}/%{name} <<'EOF'
#!/bin/sh
exec %{_libdir}/%{name}/%{name} "$@"
EOF
chmod 0755 %{buildroot}%{_bindir}/%{name}

# 3. Desktop file
install -Dm0644 usr/share/applications/fluxer.desktop \
    %{buildroot}%{_datadir}/applications/%{appid}.desktop

# Fix Exec= and Icon= for our relocation
sed -i 's|^Exec=.*|Exec=%{_bindir}/%{name} %U|' \
    %{buildroot}%{_datadir}/applications/%{appid}.desktop
sed -i 's|^Icon=.*|Icon=%{appid}|' \
    %{buildroot}%{_datadir}/applications/%{appid}.desktop

# 4. Icons
for iconpath in usr/share/icons/hicolor/*/apps/fluxer.png; do
    size=$(echo "$iconpath" | cut -d/ -f5)
    install -Dm0644 "$iconpath" \
        %{buildroot}%{_datadir}/icons/hicolor/${size}/apps/%{appid}.png
done

%files
%defattr(-,root,root)
%license opt/Fluxer/LICENSE.electron.txt
%doc opt/Fluxer/LICENSES.chromium.html
%{_bindir}/%{name}
%{_libdir}/%{name}/
%{_datadir}/applications/%{appid}.desktop
%dir %{_datadir}/icons/hicolor
%dir %{_datadir}/icons/hicolor/*
%dir %{_datadir}/icons/hicolor/*/apps
%{_datadir}/icons/hicolor/*/apps/%{appid}.png

%changelog
