#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QVector>
#include <QString>
#include "heinzelnisseelement.h"
#include "databasemanager.h"

class DatabaseManager
{
public:
    DatabaseManager();
    bool isOpen() const;
    QVector<HeinzelnisseElement> getResults(const QString &query);
private:
    QSqlDatabase database;
    HeinzelnisseElement getElementFromQuery(const QSqlQuery &query) const;

};

#endif // DATABASEMANAGER_H
