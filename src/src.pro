CONFIG += sailfishapp
LIBS += -lz -lquazip -L../quazip/quazip

QT += sql core

include(wagnis/wagnis.pri)

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
    heinzelnissemodel.cpp \
    dictccimportermodel.cpp \
    dictccimportworker.cpp \
    dictionarymodel.cpp \
    dictionarymetadata.cpp \
    dictccword.cpp \
    dictionarysearchworker.cpp \
    curiosity.cpp \
    cloudapi.cpp

HEADERS += \
    heinzelnisseelement.h \
    databasemanager.h \
    heinzelnissemodel.h \
    dictccimportermodel.h \
    dictccimportworker.h \
    dictionarymodel.h \
    dictionarymetadata.h \
    dictccword.h \
    dictionarysearchworker.h \
    curiosity.h \
    cloudapi.h \
    cloudcredentials.h

