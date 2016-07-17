TARGET = harbour-wunderfitz

CONFIG += sailfishapp

SOURCES += src/harbour-wunderfitz.cpp \
    src/databasemanager.cpp

OTHER_FILES += rpm/harbour-wunderfitz.changes.in \
    rpm/harbour-wunderfitz.spec \
    rpm/harbour-wunderfitz.yaml \
    translations/*.ts \
    harbour-wunderfitz.desktop \
    qml/pages/TitlePage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/CoverPage.qml \
    db/heinzelliste.db

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-wunderfitz-de.ts

QT += sql

HEADERS += \
    src/databasemanager.h

database.files = db
database.path = /usr/share/$${TARGET}
INSTALLS += database
