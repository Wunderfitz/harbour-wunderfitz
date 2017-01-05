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
    void setDictionaryId(const QString &dictionaryId);
private:
    QSqlDatabase database;
    QList<HeinzelnisseElement*>* resultList;
    QString dictionaryId;

    void populateElementFromQuery(const QSqlQuery &query, HeinzelnisseElement* &heinzelnisseElement) const;
    void addQueryResults(QSqlQuery &query, const QString &queryString);
    bool elementAlreadyThere(HeinzelnisseElement* &heinzelnisseElement);
    bool isWordMatch(HeinzelnisseElement* &heinzelnisseElement, const QString &queryString);
    bool isDirectMatch(HeinzelnisseElement* &heinzelnisseElement, const QString &queryString);
    bool isIndirectMatch(HeinzelnisseElement* &heinzelnisseElement, const QString &queryString);
    void appendRawList(QList<HeinzelnisseElement*> &rawList);

};

#endif // DATABASEMANAGER_H
