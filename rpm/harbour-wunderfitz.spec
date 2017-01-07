# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-wunderfitz

# >> macros
%define __provides_exclude_from ^%{_datadir}/.*$
%define __requires_exclude ^libquazip.*$
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    A mobile dictionary application, supporting dict.cc and Heinzelnisse
Version:    0.3
Release:    9
Group:      Qt/Qt
License:    LICENSE
URL:        http://www.wunderfitz.org/
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-wunderfitz.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   libz.so.1
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Wunderfitz is a mobile dictionary application, supporting the Heinzelnisse dictionary (Norwegian-German) and dict.cc export files.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/%{name}
%{_datadir}/%{name}/lib
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files
