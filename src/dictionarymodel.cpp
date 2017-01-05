#include "dictionarymodel.h"

#include <QDebug>
#include <QDir>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QString>
#include <QStringList>

DictionaryModel::DictionaryModel()
{
    DictionaryMetadata* heinzelnisseMetadata = new DictionaryMetadata();
    heinzelnisseMetadata->setLanguages("DE-NO (Heinzelnisse)");
    heinzelnisseMetadata->setTimestamp("2016-11-05 16:19");
    selectedDictionary = heinzelnisseMetadata;
    selectedIndex = 0;
    availableDictionaries.append(heinzelnisseMetadata);

    QStringList nameFilter("*.db");
    QString databaseDirectory = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/harbour-wunderfitz";
    QDir downloadDirectory(databaseDirectory);
    QStringList databaseFiles = downloadDirectory.entryList(nameFilter);
    QStringListIterator databaseFilesIterator(databaseFiles);
    while (databaseFilesIterator.hasNext()) {
        QString fileName = databaseFilesIterator.next();
        QString databaseFilePath = databaseDirectory + "/" + fileName;
        QSqlDatabase database = QSqlDatabase::addDatabase("QSQLITE", "connection" + fileName.section(".", 0, 0));
        database.setDatabaseName(databaseFilePath);
        if (database.open()) {
            qDebug() << "SQLite database " + databaseFilePath + " successfully opened";
            DictionaryMetadata* dictionaryMetadata = new DictionaryMetadata();
            dictionaryMetadata->setLanguages(readLanguages(database) + " (Dict.cc)");
            dictionaryMetadata->setTimestamp(readTimestamp(database));
            availableDictionaries.append(dictionaryMetadata);
            database.close();
        } else {
            qDebug() << "Error opening SQLite database " + databaseFilePath;
        }
    }
}

QVariant DictionaryModel::data(const QModelIndex &index, int role) const {
    if(!index.isValid()) {
        return QVariant();
    }
    if(role == Qt::DisplayRole) {
        QMap<QString,QVariant> resultMap;
        DictionaryMetadata* dictionaryMetadata = availableDictionaries.value(index.row());
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

void DictionaryModel::selectDictionary(int dictionaryIndex)
{
    if (dictionaryIndex >= 0 && availableDictionaries.size() > dictionaryIndex) {
        selectedIndex = dictionaryIndex;
        selectedDictionary = availableDictionaries.value(dictionaryIndex);
        qDebug() << "New dictionary selected: " + selectedDictionary->getLanguages();
        emit dictionaryChanged();
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

int DictionaryModel::rowCount(const QModelIndex&) const {
    return availableDictionaries.size();
}
