CONFIG += sailfishapp
LIBS += -lz -lquazip -L../quazip/quazip

QT += sql

DEPENDPATH += . ../quazip/quazip
INCLUDEPATH += . ../quazip/quazip
QMAKE_LFLAGS += -Wl,-rpath,\\$${LITERAL_DOLLAR}$${LITERAL_DOLLAR}ORIGIN/../share/harbour-wunderfitz/lib

INSTALLS += target
target.path = /usr/bin/

TARGET = harbour-wunderfitz
TEMPLATE = app

SOURCES += harbour-wunderfitz.cpp \
    databasemanager.cpp \
    heinzelnisseelement.cpp \
    heinzelnissemodel.cpp

HEADERS += \
    heinzelnisseelement.h \
    databasemanager.h \
    heinzelnissemodel.h

