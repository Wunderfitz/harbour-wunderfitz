#ifndef DICTCCIMPORTWORKER_H
#define DICTCCIMPORTWORKER_H

#include <QThread>
#include <QString>

class DictCCImportWorker : public QThread
{
    Q_OBJECT
    void run() Q_DECL_OVERRIDE {
        importDictionaries();
        emit importFinished();
    }
signals:
        void importFinished();
        void statusChanged(const QString &statusText);
private:

    void importDictionaries();
    QString getTempDirectory();
    QString getTempDirectory(const QString &directoryString);
};

#endif // DICTCCIMPORTWORKER_H
