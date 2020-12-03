/*
    Copyright (C) 2016-19 Sebastian J. Wolf
                     2020 Mirian Margiani

    This file is part of Wunderfitz.

    Wunderfitz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    Wunderfitz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Wunderfitz. If not, see <http://www.gnu.org/licenses/>.
*/
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
#include "requires_defines.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    QQmlContext *ctxt = view.data()->rootContext();
    DictionaryModel dictionaryModel;
    ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
    ctxt->setContextProperty("heinzelnisseModel", &dictionaryModel.heinzelnisseModel);
    ctxt->setContextProperty("dictCCImporterModel", &dictionaryModel.dictCCImporterModel);
    // ctxt->setContextProperty("versionNumber", QString("%1-%2").arg(APP_VERSION).arg(APP_RELEASE));
    ctxt->setContextProperty("versionNumber", QString(APP_VERSION));

    Curiosity curiosity;
    ctxt->setContextProperty("curiosity", &curiosity);
    CloudApi *cloudApi = curiosity.getCloudApi();
    ctxt->setContextProperty("cloudApi", cloudApi);

    view->setSource(SailfishApp::pathTo("qml/harbour-wunderfitz.qml"));
    view->show();
    return app->exec();
}
