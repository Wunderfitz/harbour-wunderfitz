#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QDebug>
#include <sailfishapp.h>
#include "databasemanager.h"


int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    // This is test code - nothing to see, go away! ;)
    DatabaseManager databaseManager;
    if (databaseManager.isOpen()) {
        qDebug() << "Good!";
        QList<HeinzelnisseElement> results = databaseManager.getResults("haus");
        QListIterator<HeinzelnisseElement> resultsIterator(results);
        while (resultsIterator.hasNext()) {
            const HeinzelnisseElement result = resultsIterator.next();
            qDebug() << result.getWordNorwegian() << " : " << result.getWordGerman();
        }
    } else {
        qDebug() << "Doh!";
    }

    return SailfishApp::main(argc, argv);
}

