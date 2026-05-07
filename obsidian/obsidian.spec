%global app_id md.obsidian.Obsidian
%global debug_package %{nil}

Name:           obsidian
Version:        1.12.7
Release:        0
# Shortened to pass the 79-character RPMLINT limit
Summary:        A powerful knowledge base for plain text Markdown files

# OpenSUSE requires this exact string for proprietary software
License:        SUSE-NonFree
Group:          Productivity/Text/Editors
URL:            https://obsidian.md/
ExclusiveArch:  x86_64 aarch64

# These tarballs are dynamically downloaded by update.sh
Source0:        obsidian-%{version}.tar.gz
Source1:        obsidian-%{version}-arm64.tar.gz

# The custom wrapper script to launch native Electron
Source2:        obsidian.sh

BuildRequires:  desktop-file-utils
BuildRequires:  fdupes

# Native System Dependencies
Requires:       electron
Requires:       bash

# Prevent automatic dependency generation for the bundled ASAR/Node files
AutoReqProv:    no

%description
Obsidian is a powerful knowledge base that works on top of a local folder 
of plain text Markdown files. The human brain is non-linear: we jump from 
idea to idea, all the time. Your second brain should work the same.

%prep
# Extract using -b to prevent double-directory nesting depending on arch
%ifarch x86_64
%setup -q -T -b 0 -n %{name}-%{version}
%endif

%ifarch aarch64
%setup -q -T -b 1 -n %{name}-%{version}
%endif

%build
# Nothing to compile.

%install
# 1. Install ONLY the core Obsidian application resources
install -dm755 %{buildroot}%{_libdir}/%{name}
cp -r resources %{buildroot}%{_libdir}/%{name}/

# 2. Install the custom launcher script
install -Dm755 %{SOURCE2} %{buildroot}%{_bindir}/%{name}

# 3. Dynamically Generate the Desktop Entry
install -dm755 %{buildroot}%{_datadir}/applications
cat > %{buildroot}%{_datadir}/applications/%{app_id}.desktop << EOF
[Desktop Entry]
Name=Obsidian
Exec=/usr/bin/obsidian %U
Terminal=false
Type=Application
Icon=%{app_id}
StartupWMClass=obsidian
Comment=Obsidian
MimeType=x-scheme-handler/obsidian;
Categories=Office;TextEditor;
EOF

# 4. Install the Icon safely using a dynamic finder to avoid filename crashes
ICON_FILE=$(find . -name "*.png" | head -n 1)
install -Dm644 "$ICON_FILE" %{buildroot}%{_datadir}/pixmaps/%{app_id}.png

find %{buildroot}%{_libdir}/%{name} -type f \( -name "*.js" -o -name "*.json" -o -name "*.mm" \) -exec chmod a-x {} +

# OpenSUSE optimization: hardlink duplicate files in resources
%fdupes %{buildroot}%{_libdir}/%{name}

%check
desktop-file-validate %{buildroot}%{_datadir}/applications/%{app_id}.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/applications/%{app_id}.desktop
%{_datadir}/pixmaps/%{app_id}.png
%dir %{_libdir}/%{name}
%{_libdir}/%{name}/*

%changelog
