#include "dictccimportermodel.h"
#include "dictccimportworker.h"

#include <QDebug>

DictCCImporterModel::DictCCImporterModel()
{
    statusText = QString("");
    working = false;
    importedDictionaries = QList<DictionaryMetadata*>();
}

QVariant DictCCImporterModel::data(const QModelIndex &index, int role) const {
    if(!index.isValid()) {
        return QVariant();
    }
    if(role == Qt::DisplayRole) {
        QMap<QString,QVariant> resultMap;
        DictionaryMetadata* dictionaryMetadata = importedDictionaries.value(index.row());
        resultMap.insert("id", QVariant(dictionaryMetadata->getId()));
        resultMap.insert("languages", QVariant(dictionaryMetadata->getLanguages()));
        resultMap.insert("timestamp", QVariant(dictionaryMetadata->getTimestamp()));
        return QVariant(resultMap);
    }
    return QVariant();
}

int DictCCImporterModel::rowCount(const QModelIndex&) const {
    return importedDictionaries.size();
}

void DictCCImporterModel::importDictionaries()
{
    qDeleteAll(importedDictionaries);
    importedDictionaries.clear();
    DictCCImportWorker *workerThread = new DictCCImportWorker();
    connect(workerThread, SIGNAL(importFinished()), this, SLOT(handleImportFinished()));
    connect(workerThread, SIGNAL(statusChanged(QString)), this, SLOT(handleStatusChanged(QString)));
    connect(workerThread, SIGNAL(dictionaryFound(QString,QString)), this, SLOT(handleDictionaryFound(QString,QString)));
    working = true;
    workerThread->start();
}

QString DictCCImporterModel::getStatusText()
{
    return statusText;
}

bool DictCCImporterModel::isWorking()
{
    return working;
}

void DictCCImporterModel::handleImportFinished()
{
    statusText = "Extraction completed";
    qDebug() << statusText;
    working = false;
    emit statusChanged();
    emit importFinished();
}

void DictCCImporterModel::handleStatusChanged(const QString &statusText)
{
    this->statusText = statusText;
    emit statusChanged();
}

void DictCCImporterModel::handleDictionaryFound(const QString &languages, const QString &timestamp)
{
    beginResetModel();
    DictionaryMetadata* importedDictionary = new DictionaryMetadata();
    importedDictionary->setId(languages);
    importedDictionary->setLanguages(languages);
    importedDictionary->setTimestamp(timestamp);
    importedDictionaries.append(importedDictionary);
    endResetModel();
}

