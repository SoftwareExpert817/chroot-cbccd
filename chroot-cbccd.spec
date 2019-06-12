# Copyright (C) 2000-2010 CholByok
# For copyright information look at
# http://www.cbcc.com/doc/cholbyok-license.txt
#

Name:         chroot-cbccd
Summary:      CholByok Command Center Chroot
Version:      1.0.0
Release:      cb
License:      GPL v2 or later
Group:        Productivity/Networking
Provides:     CholByok
Requires:     json-c
Source:       %{name}-%{version}.tar.gz
BuildRoot:    %{_tmppath}/%{name}-%{version}-build

%description
CholByok Command Center Chroot.

%prep
%setup -n %{name}-%{version}

%build
%makeinstall

%install
%define chroot /var/storage/chroot-cbccd

install -d $RPM_BUILD_ROOT/%{chroot}
install -d $RPM_BUILD_ROOT/%{chroot}/bin
install -d $RPM_BUILD_ROOT/%{chroot}/dev
install -d $RPM_BUILD_ROOT/%{chroot}/etc
install -d $RPM_BUILD_ROOT/%{chroot}/lib
install -d $RPM_BUILD_ROOT/%{chroot}/sbin
install -d $RPM_BUILD_ROOT/%{chroot}/usr
install -d $RPM_BUILD_ROOT/%{chroot}/var

install -d -m 1777 $RPM_BUILD_ROOT/%{chroot}/tmp
install -d -m 555  $RPM_BUILD_ROOT/%{chroot}/proc

mv $RPM_BUILD_ROOT/usr $RPM_BUILD_ROOT/%{chroot}

install -D -m644 misc/etc/cbccca.crt $RPM_BUILD_ROOT/%{chroot}/etc/cbccd/cbccca.crt
install -D -m644 misc/etc/cbccserver.crt $RPM_BUILD_ROOT/%{chroot}/etc/cbccd/cbccserver.crt
install -D -m644 misc/etc/cbccserver.key $RPM_BUILD_ROOT/%{chroot}/etc/cbccd/cbccserver.key

install -d $RPM_BUILD_ROOT/%{chroot}/usr/share
install -d $RPM_BUILD_ROOT/%{chroot}/usr/share/misc
install -d $RPM_BUILD_ROOT/%{chroot}/var/run
install -d $RPM_BUILD_ROOT/%{chroot}/var/run/postgresql
install -d $RPM_BUILD_ROOT/%{chroot}/var/log
install -d $RPM_BUILD_ROOT/%{chroot}/var/storage/sessions/backup
install -d $RPM_BUILD_ROOT/%{chroot}/var/storage/sessions/rrd-images

ln -s %{chroot} $RPM_BUILD_ROOT/var/chroot-cbccd

install -D -m644 misc/chrootspec/cbccd $RPM_BUILD_ROOT/etc/chrootspec/cbccd
install -D -m644 misc/selfmonng.d/cbccd.check $RPM_BUILD_ROOT/etc/selfmonng.d/cbccd.check

install -D -m755 misc/mdw/cbccd $RPM_BUILD_ROOT/var/mdw/scripts/cbccd
install -D -m755 misc/pgsql/cbcc_db_init.sh $RPM_BUILD_ROOT/var/storage/pgsql92/init/cbcc_db_init.sh
install -D -m644 misc/pgsql/cbcc_db_init.sql $RPM_BUILD_ROOT/var/storage/pgsql92/init/cbcc_db_init.sql

install -d $RPM_BUILD_ROOT/etc/init.d/rc3.d
ln -s /var/mdw/scripts/cbccd $RPM_BUILD_ROOT/etc/init.d/rc3.d/K25cbccd
ln -s /var/mdw/scripts/cbccd $RPM_BUILD_ROOT/etc/init.d/rc3.d/S90cbccd

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{chroot}
/var/chroot-cbccd
%config /etc/chrootspec/cbccd
/etc/init.d/rc3.d/K25cbccd
/etc/init.d/rc3.d/S90cbccd
/etc/selfmonng.d/cbccd.check
/var/mdw/scripts/cbccd
/var/storage/pgsql92/init
%dev(c, 1, 3) %attr(666, root, root) %{chroot}/dev/null
%dev(c, 1, 8) %attr(666, root, root) %{chroot}/dev/random
%dev(c, 1, 9) %attr(666, root, root) %{chroot}/dev/urandom

%post
/usr/local/bin/buildchroot.sh cbccd
touch /var/storage/%{name}/etc/ld.so.conf
/sbin/ldconfig -r /var/storage/chroot-cbccd

%changelog
