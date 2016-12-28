#include "dictccimportermodel.h"
#include "dictccimportworker.h"
#include <QDebug>
DictCCImporterModel::DictCCImporterModel()
{
}

QVariant DictCCImporterModel::data(const QModelIndex &index, int role) const {
    return QVariant();
}

int DictCCImporterModel::rowCount(const QModelIndex&) const {
    return 0;
}

void DictCCImporterModel::importDictionaries()
{
    DictCCImportWorker *workerThread = new DictCCImportWorker();
    connect(workerThread, &DictCCImportWorker::resultReady, this, &DictCCImporterModel::handleResults);
    //connect(workerThread, &DictCCImportWorker::finished, workerThread, &QObject::deleteLater);
    workerThread->start();
}

void DictCCImporterModel::handleResults(const QString &results)
{
    qDebug() << "Extraction completed";
}

