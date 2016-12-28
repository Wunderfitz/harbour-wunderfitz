#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QScopedPointer>
#include <QQuickView>
#include <QtQml>
#include <QQmlContext>
#include <QGuiApplication>
#include "databasemanager.h"
#include "dictccimportermodel.h"
#include "heinzelnissemodel.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    qmlRegisterType<HeinzelnisseModel>("harbour.wunderfitz", 1, 0, "HeinzelnisseModel");
    qmlRegisterType<DictCCImporterModel>("harbour.wunderfitz", 1, 0, "DictCCImporterModel");

    view->setSource(SailfishApp::pathTo("qml/harbour-wunderfitz.qml"));
    view->show();
    return app->exec();
}

