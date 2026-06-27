Name:           zen-browser
Version:        1.21.4b
Release:        0
Summary:        Minimal browser focused on privacy and calm browsing
License:        MPL-2.0
URL:            https://github.com/zen-browser/desktop
Source0:        %{url}/releases/download/%{version}/zen.linux-x86_64.tar.xz
Source1:        zen-browser.sh
Source2:        zen-browser.desktop
Source3:        policies.json
ExclusiveArch:  x86_64

BuildRequires:  coreutils
BuildRequires:  desktop-file-utils
BuildRequires:  hicolor-icon-theme
BuildRequires:  fdupes
BuildRequires:  mozilla-nss
BuildRequires:  mozilla-nss-certs
BuildRequires:  mozilla-nspr
BuildRequires:  hunspell
BuildRequires:  hyphen
BuildRequires:  chrpath
BuildRequires:  execstack
Requires:       mozilla-nss
Requires:       mozilla-nss-certs
Requires:       mozilla-nspr
Requires:       hunspell
Requires:       hyphen

%description
Zen Browser is a free, open-source web browser based on Mozilla Firefox.It emphasizes privacy, customization, and a modern, distraction-free interface.

Key features:
- Vertical tab sidebar with compact mode
- Workspace management for organizing tabs
- Split view for multitasking
- Firefox Sync support
- Privacy-focused with no tracking
- Compatible with Firefox extensions

%prep
%setup -q -n zen

%build

%install
install -d %{buildroot}%{_bindir}
install -d %{buildroot}%{_datadir}/applications
install -d %{buildroot}%{_libdir}/zen-browser

cp -a * %{buildroot}%{_libdir}/zen-browser/
rm -f %{buildroot}%{_libdir}/zen-browser/removed-files

install -m0755 %{_sourcedir}/zen-browser.sh %{buildroot}%{_bindir}/zen-browser

desktop-file-install --dir=%{buildroot}%{_datadir}/applications %{SOURCE2}

for size in 16x16 32x32 48x48 64x64 128x128; do
    install -Dm644 %{buildroot}%{_libdir}/zen-browser/browser/chrome/icons/default/default${size/x*}.png \
        %{buildroot}%{_datadir}/icons/hicolor/${size}/apps/zen-browser.png
done

install -d %{buildroot}%{_libdir}/zen-browser/distribution
install -m644 %{_sourcedir}/policies.json %{buildroot}%{_libdir}/zen-browser/distribution/policies.json

ln -sf /usr/share/hunspell %{buildroot}%{_libdir}/zen-browser/dictionaries
ln -sf /usr/share/hyphen %{buildroot}%{_libdir}/zen-browser/hyphenation

for lib in libnspr4.so libplc4.so libplds4.so \
        libnss3.so libnssutil3.so libsmime3.so libssl3.so \
        libfreeblpriv3.so libsoftokn3.so libnssckbi.so; do
    rm -f %{buildroot}%{_libdir}/zen-browser/$lib
    ln -sf %{_libdir}/$lib %{buildroot}%{_libdir}/zen-browser/$lib
done

# Safeguard: Only execute stack clearance if upstream shipped libonnxruntime.so
if [ -f "%{buildroot}%{_libdir}/zen-browser/libonnxruntime.so" ]; then
    execstack -c %{buildroot}%{_libdir}/zen-browser/libonnxruntime.so
    chrpath -d %{buildroot}%{_libdir}/zen-browser/libonnxruntime.so
fi

%fdupes %{buildroot}%{_libdir}/zen-browser

%check

%files
%{_bindir}/zen-browser
%{_libdir}/zen-browser
%{_datadir}/applications/zen-browser.desktop
%{_datadir}/icons/hicolor/*/apps/zen-browser.png

%changelog
