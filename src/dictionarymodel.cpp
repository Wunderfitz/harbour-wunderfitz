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

#include "dictionarymodel.h"

const QString DictionaryModel::settingDictionaryId = QString("dictionary/id");
const QString DictionaryModel::settingRemainingHints = QString("ui/remainingHints");
const QString DictionaryModel::heinzelnisseId = QString("heinzelnisse");
const QString DictionaryModel::heinzelnisseLanguages = QString("DE-NO (Heinzelnisse)");
const QString DictionaryModel::heinzelnisseTimestamp = QString("2017-01-07 12:48");

#include <QDebug>
#include <QDir>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QString>
#include <QStringList>

DictionaryModel::DictionaryModel()
{
    initializeDatabases();
    DictCCImporterModel* myModel (&dictCCImporterModel);
    connect(myModel, SIGNAL(importFinished()), this, SLOT(handleModelChanged()));
    connect(this, SIGNAL(dictionaryChanged()), this, SIGNAL(selectedDictionaryIndexChanged()));
    connect(this, SIGNAL(dictionaryChanged()), this, SIGNAL(selectedDictionaryIdChanged()));
    connect(this, SIGNAL(dictionaryChanged()), this, SIGNAL(selectedDictionaryNameChanged()));
}

QVariant DictionaryModel::data(const QModelIndex &index, int role) const {
    if(!index.isValid()) {
        return QVariant();
    }
    if(role == Qt::DisplayRole) {
        QMap<QString,QVariant> resultMap;
        DictionaryMetadata* dictionaryMetadata = availableDictionaries.value(index.row());
        resultMap.insert("id", QVariant(dictionaryMetadata->getId()));
        resultMap.insert("languages", QVariant(dictionaryMetadata->getLanguages()));
        resultMap.insert("timestamp", QVariant(dictionaryMetadata->getTimestamp()));
        return QVariant(resultMap);
    }
    return QVariant();
}

QString DictionaryModel::readLanguages(QSqlDatabase &database)
{
    QSqlQuery databaseQuery(database);
    databaseQuery.prepare("select value from metadata where key = 'languages'");
    databaseQuery.exec();
    if (databaseQuery.next()) {
        QString languages = databaseQuery.value(0).toString();
        qDebug() << "Languages: " + languages;
        return languages;
    } else {
        qDebug() << "Error reading languages metadata from database - " + databaseQuery.lastError().text();
        return QString();
    }
}

QString DictionaryModel::readTimestamp(QSqlDatabase &database)
{
    QSqlQuery databaseQuery(database);
    databaseQuery.prepare("select value from metadata where key = 'timestamp'");
    databaseQuery.exec();
    if (databaseQuery.next()) {
        QString timestamp = databaseQuery.value(0).toString();
        qDebug() << "Timestamp: " + timestamp;
        return timestamp;
    } else {
        qDebug() << "Error reading timestamp metadata from database - " + databaseQuery.lastError().text();
        return QString();
    }
}

void DictionaryModel::initializeDatabases()
{
    qDeleteAll(availableDictionaries);
    availableDictionaries.clear();

    QString chosenDictionaryId = settings.value(settingDictionaryId).toString();

    int dictionaryIndex = 0;
    DictionaryMetadata* heinzelnisseMetadata = new DictionaryMetadata();
    heinzelnisseMetadata->setId(heinzelnisseId);
    heinzelnisseMetadata->setLanguages(heinzelnisseLanguages);
    heinzelnisseMetadata->setTimestamp(heinzelnisseTimestamp);
    selectedDictionary = heinzelnisseMetadata;
    selectedIndex = dictionaryIndex;
    availableDictionaries.append(heinzelnisseMetadata);

    QStringList nameFilter("*.db");
    QString databaseDirectory = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/harbour-wunderfitz";
    QDir downloadDirectory(databaseDirectory);
    QStringList databaseFiles = downloadDirectory.entryList(nameFilter);
    QStringListIterator databaseFilesIterator(databaseFiles);
    while (databaseFilesIterator.hasNext()) {
        dictionaryIndex++;
        QString fileName = databaseFilesIterator.next();
        QString databaseFilePath = databaseDirectory + "/" + fileName;
        QSqlDatabase database = QSqlDatabase::addDatabase("QSQLITE", "connection" + fileName.section(".", 0, 0));
        database.setDatabaseName(databaseFilePath);
        if (database.open()) {
            qDebug() << "SQLite database " + databaseFilePath + " successfully opened";
            DictionaryMetadata* dictionaryMetadata = new DictionaryMetadata();
            QString dictionaryId = readLanguages(database);
            dictionaryMetadata->setId(dictionaryId);
            dictionaryMetadata->setLanguages(dictionaryId + " (Dict.cc)");
            dictionaryMetadata->setTimestamp(readTimestamp(database));
            availableDictionaries.append(dictionaryMetadata);
            if (dictionaryId == chosenDictionaryId) {
                qDebug() << "Using user-defined dictionary " + dictionaryMetadata->getLanguages();
                selectedIndex = dictionaryIndex;
                selectedDictionary = dictionaryMetadata;
                heinzelnisseModel.setDictionaryId(dictionaryId);
            }
            database.close();
        } else {
            qDebug() << "Error opening SQLite database " + databaseFilePath;
        }
    }
}

void DictionaryModel::selectDictionary(int dictionaryIndex)
{
    if (dictionaryIndex >= 0 && availableDictionaries.size() > dictionaryIndex) {
        selectedIndex = dictionaryIndex;
        selectedDictionary = availableDictionaries.value(dictionaryIndex);
        settings.setValue(settingDictionaryId, selectedDictionary->getId());
        heinzelnisseModel.setDictionaryId(selectedDictionary->getId());
        emit dictionaryChanged();
        qDebug() << "New dictionary selected: " + selectedDictionary->getLanguages();
    }
}

void DictionaryModel::deleteSelectedDictionary()
{
    QString idToDelete = selectedDictionary->getId();
    int oldIndex = selectedIndex;
    int newIndex = selectedIndex;
    if (idToDelete != heinzelnisseId) {
        if (selectedIndex < ( availableDictionaries.size() - 1 )) {
            newIndex++;
        } else {
            newIndex--;
        }
        selectDictionary(newIndex);
        QSqlDatabase databaseToDelete = QSqlDatabase::database("connection" + idToDelete);
        databaseToDelete.close();
        QFile fileToDelete(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/harbour-wunderfitz" + "/" + idToDelete + ".db");
        if (fileToDelete.remove()) {
            qDebug() << "Dictionary deleted: " + idToDelete;
            selectedIndex = newIndex;
            handleModelChanged();
        } else {
            qDebug() << "Unable to delete dictionary: " + idToDelete;
            databaseToDelete.open();
            selectDictionary(oldIndex);
            emit deletionNotSuccessful(idToDelete);
        }

    }
}

QString DictionaryModel::getSelectedDictionaryName()
{
    return selectedDictionary->getLanguages();
}

QString DictionaryModel::getSelectedDictionaryId()
{
    return selectedDictionary->getId();
}

int DictionaryModel::getSelectedDictionaryIndex()
{
    return selectedIndex;
}

bool DictionaryModel::isInteractionHintDisplayed()
{
    if (settings.contains(settingRemainingHints)) {
        int remainingHints = settings.value(settingRemainingHints).toInt();
        if (remainingHints > 0) {
            remainingHints--;
            qDebug() << QString::number(remainingHints) + " remaining starts until interaction hint is disabled";
            settings.setValue(settingRemainingHints, remainingHints);
            return true;
        } else {
            qDebug() << "Interaction hint is disabled";
            return false;
        }
    } else {
        qDebug() << "2 remaining starts until interaction hint is disabled";
        settings.setValue(settingRemainingHints, 2);
        return true;
    }
}

void DictionaryModel::handleModelChanged()
{
    beginResetModel();
    initializeDatabases();
    endResetModel();
    emit dictionaryChanged();
}

int DictionaryModel::rowCount(const QModelIndex&) const {
    return availableDictionaries.size();
}
