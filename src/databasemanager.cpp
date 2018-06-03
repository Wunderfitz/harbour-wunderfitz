#include <QDebug>
#include <QList>
#include <QListIterator>
#include <QString>
#include <QSqlError>
#include <QtAlgorithms>
#include "heinzelnisseelement.h"
#include "databasemanager.h"
#include "dictionarymodel.h"
#include "dictionarysearchworker.h"

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {

    resultList = new QList<HeinzelnisseElement*>();
    searchWorker = new DictionarySearchWorker(resultList);
    connect(searchWorker, SIGNAL(searchCompleted(QString)), this, SLOT(handleSearchCompleted(QString)));

    database = QSqlDatabase::addDatabase("QSQLITE");
    database.setDatabaseName("/usr/share/harbour-wunderfitz/db/heinzelliste.db");
    dictionaryId = DictionaryModel::heinzelnisseId;

    if (!database.open()) {
       qDebug() << "Error: connection with Heinzelnisse database failed";
    } else {
       qDebug() << "Heinzelnisse database: Connection OK";
    }
}

DatabaseManager::~DatabaseManager() {

    qDeleteAll(*resultList);
    resultList->clear();
    delete resultList;
}

bool DatabaseManager::isOpen() const
{
    return database.isOpen();
}

void DatabaseManager::updateResults(const QString &queryString) {

    stopSearch();
    searchWorker->setQueryParameters(database, dictionaryId, queryString);
    searchWorker->start();

}

QList<HeinzelnisseElement*>* DatabaseManager::getResultList() {
    return resultList;
}

void DatabaseManager::setDictionaryId(const QString &dictionaryId)
{
    this->dictionaryId = dictionaryId;
    if (this->dictionaryId == DictionaryModel::heinzelnisseId) {
        database = QSqlDatabase::database();
    } else {
        database = QSqlDatabase::database("connection" + dictionaryId);
    }
    if (database.open()) {
        qDebug() << "Successfully switched to dictionary " + dictionaryId;
    } else {
        qDebug() << "Unable to switch to dictionary " + dictionaryId;
    }
}

void DatabaseManager::stopSearch()
{
    while (searchWorker->isRunning()) {
        searchWorker->requestInterruption();
    }
}

void DatabaseManager::handleSearchCompleted(const QString &queryString)
{
    emit searchCompleted(queryString);
}

