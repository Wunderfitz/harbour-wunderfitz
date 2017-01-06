#include <QDebug>
#include <QList>
#include <QListIterator>
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
            query.prepare("select * from heinzelnisse where heinzelnisse match (:queryString)");
        } else {
            query.prepare("select * from entries where entries match (:queryString)");
        }

        query.bindValue(":queryString", queryString + "*");
        addQueryResults(query, queryString);
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
        heinzelnisseElement->setGenderLeft(query.value(2).toString());
        heinzelnisseElement->setOptionalLeft("");
        heinzelnisseElement->setOtherLeft(query.value(3).toString());
        heinzelnisseElement->setWordRight(query.value(4).toString());
        heinzelnisseElement->setGenderRight(query.value(5).toString());
        heinzelnisseElement->setOptionalRight("");
        heinzelnisseElement->setOtherRight(query.value(6).toString());
        heinzelnisseElement->setCategory(query.value(7).toString());
        heinzelnisseElement->setGrade("");
    }
}

void DatabaseManager::addQueryResults(QSqlQuery &query, const QString &queryString) {
    query.exec();
    QList<HeinzelnisseElement*> wordMatches;
    QList<HeinzelnisseElement*> directMatches;
    QList<HeinzelnisseElement*> indirectMatches;
    QList<HeinzelnisseElement*> otherMatches;
    while (query.next()) {
        HeinzelnisseElement* nextElement = new HeinzelnisseElement();
        populateElementFromQuery(query, nextElement);
        if (isWordMatch(nextElement, queryString)) {
            wordMatches.append(nextElement);
            continue;
        }
        if (isDirectMatch(nextElement, queryString)) {
            directMatches.append(nextElement);
            continue;
        }
        if (isIndirectMatch(nextElement, queryString)) {
            indirectMatches.append(nextElement);
            continue;
        }
        otherMatches.append(nextElement);
    }
    appendRawList(wordMatches);
    appendRawList(directMatches);
    appendRawList(indirectMatches);
    appendRawList(otherMatches);
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

bool DatabaseManager::isWordMatch(HeinzelnisseElement *&heinzelnisseElement, const QString &queryString)
{
    if (QString::compare(heinzelnisseElement->getWordLeft(), queryString, Qt::CaseInsensitive) == 0 ||
            QString::compare(heinzelnisseElement->getWordRight(), queryString, Qt::CaseInsensitive) == 0) {
        return true;
    }
    return false;
}

bool DatabaseManager::isDirectMatch(HeinzelnisseElement *&heinzelnisseElement, const QString &queryString)
{
    if (heinzelnisseElement->getWordLeft().indexOf(queryString, 0, Qt::CaseInsensitive) == 0 ||
            heinzelnisseElement->getWordRight().indexOf(queryString, 0, Qt::CaseInsensitive) == 0) {
        return true;
    }
    return false;
}

bool DatabaseManager::isIndirectMatch(HeinzelnisseElement *&heinzelnisseElement, const QString &queryString)
{
    if (heinzelnisseElement->getWordLeft().contains(queryString, Qt::CaseInsensitive) ||
            heinzelnisseElement->getWordRight().contains(queryString, Qt::CaseInsensitive)) {
        return true;
    }
    return false;
}

void DatabaseManager::appendRawList(QList<HeinzelnisseElement *> &rawList)
{
    QListIterator<HeinzelnisseElement*> listIterator(rawList);
    while (listIterator.hasNext()) {
        resultList->append(listIterator.next());
    }
}

