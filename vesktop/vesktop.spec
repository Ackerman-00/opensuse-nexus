Name:           vesktop
Version:        1.6.5
Release:        0
Summary:        A custom Discord App
License:        GPL-3.0-only
Group:          Productivity/Networking/Talk/Clients
URL:            https://github.com/Vencord/Vesktop
Source0:        https://github.com/Vencord/Vesktop/releases/download/v1.6.5/vesktop-1.6.5.tar.gz
Source1:        vesktop.desktop
ExclusiveArch:  x86_64

%description
Vesktop is a custom Discord App aiming to give you better performance and improve linux support.

%prep
# Extract into a clean directory to prevent folder-name mismatches
%setup -q -c

%build

%install
mkdir -p -m0755 %{buildroot}%{_libexecdir}/%{name}
cp -r * %{buildroot}%{_libexecdir}/%{name}/

mkdir -p -m0755 %{buildroot}%{_datadir}/applications
cp %{SOURCE1} %{buildroot}%{_datadir}/applications/

# Create a symlink to /usr/bin so it can be launched from terminal
mkdir -p -m0755 %{buildroot}%{_bindir}
ln -s %{_libexecdir}/%{name}/vesktop %{buildroot}%{_bindir}/vesktop

export NO_BRP_CHECK_RPATH=true

%files
%defattr(-,root,root)
%{_bindir}/vesktop
%{_libexecdir}/%{name}
%{_datadir}/applications/*.desktop

%changelog
