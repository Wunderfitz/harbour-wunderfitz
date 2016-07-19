#include <QDebug>
#include <QVector>
#include <QString>
#include "heinzelnisseelement.h"
#include "databasemanager.h"

DatabaseManager::DatabaseManager()
{
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

bool DatabaseManager::isOpen() const
{
    return database.isOpen();
}

QVector<HeinzelnisseElement> DatabaseManager::getResults(const QString &queryString) {
    QVector<HeinzelnisseElement> results;

    QSqlQuery query;

    query.prepare("select * from heinzelnisse where de_word match (:queryString) order by de_word");
    query.bindValue(":queryString", queryString);
    query.exec();
    while (query.next()) {
        results.append(getElementFromQuery(query));
    }

    query.prepare("select * from heinzelnisse where no_word match (:queryString) order by no_word");
    query.bindValue(":queryString", queryString);
    query.exec();
    while (query.next()) {
        results.append(getElementFromQuery(query));
    }

    return results;
}

HeinzelnisseElement DatabaseManager::getElementFromQuery(const QSqlQuery &query) const {
    HeinzelnisseElement heinzelnisseElement;
    heinzelnisseElement.setWordNorwegian(query.value(1).toString());
    heinzelnisseElement.setGenderNorwegian(query.value(2).toString());
    heinzelnisseElement.setOptionalNorwegian(query.value(3).toString());
    heinzelnisseElement.setOtherNorwegian(query.value(4).toString());
    heinzelnisseElement.setWordGerman(query.value(5).toString());
    heinzelnisseElement.setGenderGerman(query.value(6).toString());
    heinzelnisseElement.setOptionalGerman(query.value(7).toString());
    heinzelnisseElement.setOtherGerman(query.value(8).toString());
    heinzelnisseElement.setCategory(query.value(9).toString());
    heinzelnisseElement.setGrade(query.value(10).toString());
    return heinzelnisseElement;
}
