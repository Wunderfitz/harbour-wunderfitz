TEMPLATE = lib
CONFIG += qt warn_on
QT -= gui
CONFIG += unversioned_libname unversioned_soname
TARGET = quazip

DEFINES += QUAZIP_BUILD
CONFIG(staticlib): DEFINES += QUAZIP_STATIC

# Input
include(quazip.pri)

target.path=/usr/share/harbour-wunderfitz/lib
INSTALLS += target
