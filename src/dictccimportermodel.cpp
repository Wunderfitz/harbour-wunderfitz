/*
    Copyright (C) 2016-19 Sebastian J. Wolf

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
    if (importedDictionaries.size() > 0) {
        statusText = "Import completed. New or updated dictionaries: " + QString::number(importedDictionaries.size());
    } else {
        statusText = "Import completed. No new or updated dictionaries found.";
    }

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
    qDebug() << "Import completed for " + languages + ", timestamp: " + timestamp;
    beginResetModel();
    DictionaryMetadata* importedDictionary = new DictionaryMetadata();
    importedDictionary->setId(languages);
    importedDictionary->setLanguages(languages);
    importedDictionary->setTimestamp(timestamp);
    importedDictionaries.append(importedDictionary);
    endResetModel();
    emit dictionaryFound(languages, timestamp);
}

