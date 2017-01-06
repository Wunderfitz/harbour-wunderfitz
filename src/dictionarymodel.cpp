#include "dictionarymodel.h"

const QString DictionaryModel::settingDictionaryId = QString("dictionary/id");
const QString DictionaryModel::settingRemainingHints = QString("ui/remainingHints");
const QString DictionaryModel::heinzelnisseId = QString("heinzelnisse");
const QString DictionaryModel::heinzelnisseLanguages = QString("DE-NO (Heinzelnisse)");
const QString DictionaryModel::heinzelnisseTimestamp = QString("2016-11-05 16:19");

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
    connect(myModel, SIGNAL(importFinished()), this, SLOT(handleImportFinished()));
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

QString DictionaryModel::getSelectedDictionaryName()
{
    return selectedDictionary->getLanguages();
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

void DictionaryModel::handleImportFinished()
{
    beginResetModel();
    initializeDatabases();
    endResetModel();
    emit dictionaryChanged();
}

int DictionaryModel::rowCount(const QModelIndex&) const {
    return availableDictionaries.size();
}
