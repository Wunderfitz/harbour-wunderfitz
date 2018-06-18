TEMPLATE = subdirs

quazip_lib.file = quazip/quazip/wunderfitz-quazip.pro
quazip_lib.target = quazip-lib

app_src.subdir = src
app_src.target = app-src
app_src.depends = quazip-lib

SUBDIRS = quazip_lib app_src

OTHER_FILES += rpm/harbour-wunderfitz.changes.in \
    rpm/harbour-wunderfitz.spec \
    rpm/harbour-wunderfitz.yaml \
    translations/*.ts \
    harbour-wunderfitz.desktop \
    qml/components/*.qml \
    qml/pages/*.qml \
    qml/*.qml
    db/heinzelliste.db

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-wunderfitz-de.ts \
     translations/harbour-wunderfitz-nl.ts \
     translations/harbour-wunderfitz-sv.ts \
     translations/harbour-wunderfitz-es.ts

database.files = db
database.path = /usr/share/$${TARGET}

gui.files = qml
gui.path = /usr/share/$${TARGET}

images.files = images
images.path = /usr/share/$${TARGET}

ICONPATH = /usr/share/icons/hicolor

86.png.path = $${ICONPATH}/86x86/apps/
86.png.files += icons/86x86/harbour-wunderfitz.png

108.png.path = $${ICONPATH}/108x108/apps/
108.png.files += icons/108x108/harbour-wunderfitz.png

128.png.path = $${ICONPATH}/128x128/apps/
128.png.files += icons/128x128/harbour-wunderfitz.png

256.png.path = $${ICONPATH}/256x256/apps/
256.png.files += icons/256x256/harbour-wunderfitz.png

wunderfitz.desktop.path = /usr/share/applications/
wunderfitz.desktop.files = harbour-wunderfitz.desktop

INSTALLS += 86.png 108.png 128.png 256.png \
            wunderfitz.desktop database gui images

DISTFILES += \
    icons/108x108/harbour-wunderfitz.png \
    icons/128x128/harbour-wunderfitz.png \
    icons/256x256/harbour-wunderfitz.png \
    icons/86x86/harbour-wunderfitz.png \
    images/background.png \
    images/wunderfitz.png \
    qml/*.qml \
    pml/pages/*.qml \
    LICENSE \
    README.md \
    qml/components/WunderfitzButton.qml \
    qml/pages/TextPage.qml

