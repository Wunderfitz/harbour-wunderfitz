#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QList>
#include <QString>
#include "heinzelnisseelement.h"
#include "databasemanager.h"

class DatabaseManager {

public:
    DatabaseManager();
    bool isOpen() const;
    QList<HeinzelnisseElement> getResults(const QString &query);
private:
    QSqlDatabase database;
    HeinzelnisseElement getElementFromQuery(const QSqlQuery &query) const;
    void addQueryResults(QSqlQuery &query, QList<HeinzelnisseElement> &results) const;

};

#endif // DATABASEMANAGER_H
