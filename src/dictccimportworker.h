#ifndef DICTCCIMPORTWORKER_H
#define DICTCCIMPORTWORKER_H

#include <QThread>
#include <QString>

class DictCCImportWorker : public QThread
{
    Q_OBJECT
    void run() Q_DECL_OVERRIDE {
        QString result;
        importDictionaries();
        emit resultReady(result);
    }
signals:
        void resultReady(const QString &s);
private:

    void importDictionaries();
    QString getTempDirectory();
    QString getTempDirectory(const QString &directoryString);
};

#endif // DICTCCIMPORTWORKER_H
