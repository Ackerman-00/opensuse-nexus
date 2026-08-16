%global debug_package %{nil}

Name:           ly
Version:        1.4.1
Release:        0
Summary:        The Ly display manager
License:        WTFPLv2
Group:          System/GUI/Login
URL:            https://codeberg.org/fairyglade/ly
Source0:        https://codeberg.org/fairyglade/ly/archive/v%{version}.tar.gz
Source1:        %{name}-zig-cache.tar.gz

# zig0.16 provides /usr/bin/zig = 0.16.0 (ly's minimum_zig_version),
# available in both openSUSE Tumbleweed and Slowroll OSS repos.
BuildRequires:  filesystem login_defs
BuildRequires:  pam-devel
BuildRequires:  libxcb-devel
BuildRequires:  zig0.16

Recommends:     brightnessctl

%description
Ly is a lightweight TUI (ncurses-like) display manager for Linux and BSD,
designed with portability in mind and doesn't require systemd to run.

%prep
%setup -q -n %{name}
tar -xf "%{_sourcedir}"/%{name}-zig-cache.tar.gz -C "%{_builddir}"

%build
zig build            --global-cache-dir "%{_builddir}"/%{name}-zig-cache -Dinit_system=systemd -Dcpu=baseline -Doptimize=ReleaseSmall -Dprefix_directory="/usr"

%install
zig build installexe --global-cache-dir "%{_builddir}"/%{name}-zig-cache -Dinit_system=systemd -Dcpu=baseline -Doptimize=ReleaseSmall -Dprefix_directory="/usr" -Ddest_directory="%{buildroot}"

if [[ ! -f "/etc/login.defs" && -f "/usr/etc/login.defs" ]]; then
  sed -i 's/\/etc\/login\.defs/\/usr\/etc\/login\.defs/g' "%{buildroot}%{_sysconfdir}"/ly/config.ini
fi

%files
%{_bindir}/ly
%dir %{_sysconfdir}/ly
%{_sysconfdir}/ly/*.sh
%{_sysconfdir}/ly/*.dur
%{_sysconfdir}/ly/*.example
%config(noreplace,missingok) %{_sysconfdir}/ly/config.ini
%dir %{_sysconfdir}/ly/*/
%{_sysconfdir}/ly/*/*
%{_sysconfdir}/pam.d/ly
%{_sysconfdir}/pam.d/ly-autologin
%{_prefix}/lib/systemd/system/ly-kmsconvt@.service
%{_prefix}/lib/systemd/system/ly@.service

%changelog