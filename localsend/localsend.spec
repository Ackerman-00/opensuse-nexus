%global debug_package %{nil}

# Prevent RPM from trying to auto-generate dependencies from the bundled Flutter libraries
%global __requires_exclude_from ^/opt/localsend_app/.*$
%global __provides_exclude_from ^/opt/localsend_app/.*$

Name:           localsend
Version:        1.18.1
Release:        0
Summary:        An open source cross-platform alternative to AirDrop
License:        GPL-3.0
Group:          Productivity/Networking/Other
URL:            https://github.com/localsend/localsend
# Use the upstream DEB as our raw source payload
Source0:        %{url}/releases/download/v1.18.1/LocalSend-1.18.1-linux-x86-64.deb
Source1:        localsend-rpmlintrc

ExclusiveArch:  x86_64

# Required to unpack the upstream DEB natively
BuildRequires:  binutils
BuildRequires:  tar
BuildRequires:  zstd

# Explicit dependencies mapped from the upstream DEB to openSUSE
# (libappindicator3-1 | libayatana-appindicator3-1 -> libayatana-appindicator3-1,
#  libayatana-ido3-0.4-0 -> libayatana-ido3-0_4-0, xdg-user-dirs, libc6 -> glibc)
Requires:       libayatana-appindicator3.so.1()(64bit)
Requires:       libayatana-ido3-0.4.so.0()(64bit)
Requires:       xdg-user-dirs

%description
LocalSend is a free, open-source app that enables secure communication
between devices using a REST API and HTTPS encryption. Unlike other
messaging apps that rely on external servers, LocalSend doesn't require
an internet connection or third-party servers, making it a fast and
reliable solution for local communication.
This version natively extracts the upstream DEB payload.

%prep
%setup -c -T
# Rip open the upstream DEB natively (data.tar may be .xz or .zst)
ar x %{SOURCE0}
if [ -f data.tar.xz ]; then
  tar xf data.tar.xz
elif [ -f data.tar.zst ]; then
  tar --zstd -xf data.tar.zst
else
  echo "ERROR: unexpected data.tar compression in upstream DEB" >&2
  exit 1
fi

%build
# No compilation required for pre-built binaries

%install
rm -rf %{buildroot}

# 1. Install the main application folder and standard desktop entries
install -d -m 0755 %{buildroot}%{_datadir}
cp -a usr/share/* %{buildroot}%{_datadir}/

# 2. Install the Flutter app payload (1.18.0+ ships it under /opt)
install -d -m 0755 %{buildroot}/opt
cp -a opt/localsend_app %{buildroot}/opt/

# 3. Create the launcher wrapper (upstream DEB ships no /usr/bin entry)
install -d -m 0755 %{buildroot}%{_bindir}
cat <<-'EOF' > %{buildroot}%{_bindir}/localsend_app
#!/bin/sh
exec /opt/localsend_app/localsend_app "$@"
EOF
chmod 0755 %{buildroot}%{_bindir}/localsend_app

%files
%defattr(-,root,root)
%{_bindir}/localsend_app
%{_datadir}/applications/localsend_app.desktop
%dir %{_datadir}/icons/hicolor
%dir %{_datadir}/icons/hicolor/*
%dir %{_datadir}/icons/hicolor/*/apps
%{_datadir}/icons/hicolor/*/apps/localsend_app.png
/opt/localsend_app/

%changelog
