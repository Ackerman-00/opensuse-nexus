%global debug_package %{nil}
%global __os_install_post %{nil}
%global __requires_exclude_from ^/opt/rootapp/.*$
%global __provides_exclude_from ^/opt/rootapp/.*$

Name:           rootapp
Version:        19.2.5
Release:        0
Summary:        A new Discord alternative, designed for gaming communities and large online groups

License:        Proprietary
URL:            https://www.rootapp.com
Source0:        https://installer.rootapp.com/installer/Linux/X64/Root.AppImage
# sha256: d50d01eda97876ccb965470c982947b56ac649fa497825449efe4952b06d2526

ExclusiveArch:  x86_64

BuildRequires:  binutils
BuildRequires:  squashfs
BuildRequires:  hicolor-icon-theme
BuildRequires:  python3

Requires:       gtk3
Requires:       mozilla-nss
Requires:       alsa
Requires:       libnotify
Requires:       xdg-utils
Requires:       at-spi2-core
Requires:       hicolor-icon-theme
Requires:       Mesa-libEGL1
Requires:       vulkan-loader
Requires:       mozilla-nspr
Requires:       libpulse0
Requires:       libgbm1
Requires:       wl-clipboard
Requires:       libxkbcommon0
Requires:       libwayland-client0
Requires:       libwayland-cursor0
Requires:       libwayland-egl1
Requires:       libXtst6
Requires:       libXrandr2
Requires:       libX11-6
Requires:       libXScrnSaver1
Requires:       libXcursor1
Requires:       libXcomposite1
Requires:       libXdamage1
Requires:       libXrender1

Provides:       rootapp = %{version}-%{release}

%description
Root App is a new Discord alternative, designed for gaming communities and
large online groups.

%prep
%setup -c -T

OFFSET=$(LC_ALL=C readelf -h %{SOURCE0} | awk 'NR==13{e_shoff=$5} NR==18{e_shentsize=$5} NR==19{e_shnum=$5} END{print e_shoff+e_shentsize*e_shnum}')
unsquashfs -q -d squashfs-root -o "$OFFSET" %{SOURCE0}
chmod go-w squashfs-root

%build

%install
install -dm755 %{buildroot}/opt/rootapp
cp -ar squashfs-root/* %{buildroot}/opt/rootapp/

# Set SUID on chrome-sandbox if present (Electron sandbox)
if [ -f "%{buildroot}/opt/rootapp/chrome-sandbox" ]; then
    chmod 4755 %{buildroot}/opt/rootapp/chrome-sandbox
fi

install -dm755 %{buildroot}%{_bindir}
cat > %{buildroot}%{_bindir}/rootapp <<'WRAPPER_EOF'
#!/bin/sh
export APPDIR="/opt/rootapp"
exec /opt/rootapp/AppRun "$@"
WRAPPER_EOF
chmod 755 %{buildroot}%{_bindir}/rootapp

install -Dm644 squashfs-root/Root.png %{buildroot}%{_datadir}/pixmaps/rootapp.png
install -Dm644 squashfs-root/Root.png %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/rootapp.png

install -dm755 %{buildroot}%{_datadir}/applications/
cat > %{buildroot}%{_datadir}/applications/rootapp.desktop <<DESKTOP_EOF
[Desktop Entry]
Type=Application
Name=Root
Comment=Root App is a new Discord alternative, designed for gaming communities and large online groups
Exec=rootapp %U
Icon=rootapp
Terminal=false
StartupWMClass=Root
Categories=Network;InstantMessaging;
MimeType=x-scheme-handler/rootapp;
DESKTOP_EOF

%files
%{_bindir}/rootapp
/opt/rootapp/
%{_datadir}/applications/rootapp.desktop
%{_datadir}/icons/hicolor/*/apps/rootapp.png
%{_datadir}/pixmaps/rootapp.png

%changelog
