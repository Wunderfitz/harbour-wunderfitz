#include <QDebug>
#include <QList>
#include <QString>
#include <QSqlError>
#include <QtAlgorithms>
#include "heinzelnisseelement.h"
#include "databasemanager.h"
#include "dictionarymodel.h"

DatabaseManager::DatabaseManager() {

    resultList = new QList<HeinzelnisseElement*>();

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

    qDeleteAll(*resultList);
    resultList->clear();

    if (database.open()) {
        QSqlQuery query(database);

        if (this->dictionaryId == DictionaryModel::heinzelnisseId) {
            query.prepare("select * from heinzelnisse where heinzelnisse match (:queryString) order by de_word limit 200");
        } else {
            query.prepare("select * from entries where entries match (:queryString) order by left_word limit 200");
        }

        query.bindValue(":queryString", queryString);
        addQueryResults(query);
    } else {
        qDebug() << "Unable to perform a query on database";
    }
}

void DatabaseManager::populateElementFromQuery(const QSqlQuery &query, HeinzelnisseElement* &heinzelnisseElement) const {
    if (this->dictionaryId == DictionaryModel::heinzelnisseId) {
        heinzelnisseElement->setIndex(query.value(0).toInt());
        heinzelnisseElement->setWordLeft(query.value(5).toString());
        heinzelnisseElement->setGenderLeft(query.value(6).toString());
        heinzelnisseElement->setOptionalLeft(query.value(7).toString());
        heinzelnisseElement->setOtherLeft(query.value(8).toString());
        heinzelnisseElement->setWordRight(query.value(1).toString());
        heinzelnisseElement->setGenderRight(query.value(2).toString());
        heinzelnisseElement->setOptionalRight(query.value(3).toString());
        heinzelnisseElement->setOtherRight(query.value(4).toString());
        heinzelnisseElement->setCategory(query.value(9).toString());
        heinzelnisseElement->setGrade(query.value(10).toString());
    } else {
        heinzelnisseElement->setIndex(query.value(0).toInt());
        heinzelnisseElement->setWordLeft(query.value(1).toString());
        heinzelnisseElement->setGenderLeft("");
        heinzelnisseElement->setOptionalLeft("");
        heinzelnisseElement->setOtherLeft("");
        heinzelnisseElement->setWordRight(query.value(2).toString());
        heinzelnisseElement->setGenderRight("");
        heinzelnisseElement->setOptionalRight("");
        heinzelnisseElement->setOtherRight("");
        heinzelnisseElement->setCategory(query.value(3).toString());
        heinzelnisseElement->setGrade("");
    }
}

void DatabaseManager::addQueryResults(QSqlQuery &query) {
    query.exec();
    while (query.next()) {
        HeinzelnisseElement* nextElement = new HeinzelnisseElement();
        populateElementFromQuery(query, nextElement);
        resultList->append(nextElement);
    }
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

bool DatabaseManager::elementAlreadyThere(HeinzelnisseElement* &heinzelnisseElement) {
    bool alreadyThere = false;
    for (int i = 0; i < resultList->count(); i++ ) {
        if (*resultList->value(i) == *heinzelnisseElement) {
            return true;
        }
    }
    return alreadyThere;
}

