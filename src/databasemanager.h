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
    ~DatabaseManager();
    bool isOpen() const;
    void updateResults(const QString &query);
    QList<HeinzelnisseElement*>* getResultList();
private:
    QSqlDatabase database;
    QList<HeinzelnisseElement*>* resultList;
    void populateElementFromQuery(const QSqlQuery &query, HeinzelnisseElement* &heinzelnisseElement) const;
    void addQueryResults(QSqlQuery &query);
    bool elementAlreadyThere(HeinzelnisseElement* &heinzelnisseElement);

};

#endif // DATABASEMANAGER_H
