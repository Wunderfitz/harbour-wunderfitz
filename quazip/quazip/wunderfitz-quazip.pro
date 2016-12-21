TEMPLATE = lib
CONFIG += qt warn_on
QT -= gui
!win32:VERSION = 1.0.0
TARGET = quazip

DEFINES += QUAZIP_BUILD
CONFIG(staticlib): DEFINES += QUAZIP_STATIC

# Input
include(quazip.pri)

target.path=/usr/share/harbour-wunderfitz/lib
INSTALLS += target
