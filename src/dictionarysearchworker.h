#ifndef DICTIONARYSEARCHWORKER_H
#define DICTIONARYSEARCHWORKER_H

#include <QList>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QString>
#include <QThread>
#include "heinzelnisseelement.h"

class DictionarySearchWorker : public QThread
{
    Q_OBJECT
    void run() Q_DECL_OVERRIDE {
        performSearch();
    }

public:
    DictionarySearchWorker(QList<HeinzelnisseElement*>* resultList);
    void setQueryParameters(QSqlDatabase &database, QString &dictionaryId, const QString &queryString);
signals:
    void searchCompleted(const QString &queryString);
private:
    QSqlDatabase database;
    QString dictionaryId;
    QList<HeinzelnisseElement*>* resultList;
    QString queryString;

    void performSearch();
    void populateElementFromQuery(const QSqlQuery &query, HeinzelnisseElement* &heinzelnisseElement) const;
    void addQueryResults(QSqlQuery &query, const QString &queryString);
    bool isWordMatch(HeinzelnisseElement* &heinzelnisseElement, const QString &queryString);
    bool isDirectMatch(HeinzelnisseElement* &heinzelnisseElement, const QString &queryString);
    bool isIndirectMatch(HeinzelnisseElement* &heinzelnisseElement, const QString &queryString);
    void appendRawList(QList<HeinzelnisseElement*> &rawList);
};

#endif // DICTIONARYSEARCHWORKER_H
