#include <QDebug>
#include <QList>
#include <QString>
#include "heinzelnisseelement.h"
#include "databasemanager.h"

DatabaseManager::DatabaseManager() {

    resultList = new QList<HeinzelnisseElement*>();

    database = QSqlDatabase::addDatabase("QSQLITE");
    database.setDatabaseName("/usr/share/harbour-wunderfitz/db/heinzelliste.db");

    if (!database.open())
    {
       qDebug() << "Error: connection with database failed";
    }
    else
    {
       qDebug() << "Database: connection OK";
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

    QSqlQuery query;
    QString wildcardQueryString = queryString + "* -" + queryString;

    query.prepare("select * from heinzelnisse where de_word match (:queryString) order by de_word");
    query.bindValue(":queryString", queryString);
    addQueryResults(query);

    query.bindValue(":queryString", wildcardQueryString);
    query.exec();
    addQueryResults(query);

    query.prepare("select * from heinzelnisse where no_word match (:queryString) order by no_word");
    query.bindValue(":queryString", queryString);
    addQueryResults(query);

    query.bindValue(":queryString", wildcardQueryString);
    addQueryResults(query);
}

void DatabaseManager::populateElementFromQuery(const QSqlQuery &query, HeinzelnisseElement* &heinzelnisseElement) const {
    heinzelnisseElement->setIndex(query.value(0).toInt());
    heinzelnisseElement->setWordNorwegian(query.value(1).toString());
    heinzelnisseElement->setGenderNorwegian(query.value(2).toString());
    heinzelnisseElement->setOptionalNorwegian(query.value(3).toString());
    heinzelnisseElement->setOtherNorwegian(query.value(4).toString());
    heinzelnisseElement->setWordGerman(query.value(5).toString());
    heinzelnisseElement->setGenderGerman(query.value(6).toString());
    heinzelnisseElement->setOptionalGerman(query.value(7).toString());
    heinzelnisseElement->setOtherGerman(query.value(8).toString());
    heinzelnisseElement->setCategory(query.value(9).toString());
    heinzelnisseElement->setGrade(query.value(10).toString());
}

void DatabaseManager::addQueryResults(QSqlQuery &query) {
    query.exec();
    while (query.next()) {
        HeinzelnisseElement* nextElement = new HeinzelnisseElement();
        populateElementFromQuery(query, nextElement);
        if (!resultList->contains(nextElement)) {
            resultList->append(nextElement);
        }
    }
}

QList<HeinzelnisseElement*>* DatabaseManager::getResultList() {
    return resultList;
}


