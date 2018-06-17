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
#include "dictionarymodel.h"
#include "curiosity.h"
#include "cloudapi.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    QQmlContext *ctxt = view.data()->rootContext();
    DictionaryModel dictionaryModel;
    ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
    ctxt->setContextProperty("heinzelnisseModel", &dictionaryModel.heinzelnisseModel);
    ctxt->setContextProperty("dictCCImporterModel", &dictionaryModel.dictCCImporterModel);

    Curiosity curiosity;
    ctxt->setContextProperty("curiosity", &curiosity);
    CloudApi *cloudApi = curiosity.getCloudApi();
    ctxt->setContextProperty("cloudApi", cloudApi);

    view->setSource(SailfishApp::pathTo("qml/harbour-wunderfitz.qml"));
    view->show();
    return app->exec();
}
