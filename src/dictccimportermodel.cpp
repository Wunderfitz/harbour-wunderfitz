#include "dictccimportermodel.h"
#include "dictccimportworker.h"
#include <QDebug>
DictCCImporterModel::DictCCImporterModel()
{
    statusText = QString("");
    working = false;
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
    connect(workerThread, SIGNAL(importFinished()), this, SLOT(handleImportFinished()));
    connect(workerThread, SIGNAL(statusChanged(QString)), this, SLOT(handleStatusChanged(QString)));
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

