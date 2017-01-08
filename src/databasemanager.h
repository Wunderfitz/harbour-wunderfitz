#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QList>
#include <QString>
#include "heinzelnisseelement.h"
#include "databasemanager.h"
#include "dictionarysearchworker.h"

class DatabaseManager : public QObject {

    Q_OBJECT
public:
    DatabaseManager(QObject* parent);
    ~DatabaseManager();
    bool isOpen() const;
    void updateResults(const QString &query);
    QList<HeinzelnisseElement*>* getResultList();
    void setDictionaryId(const QString &dictionaryId);
    void stopSearch();

signals:
    void searchCompleted(const QString &queryString);

public slots:
    void handleSearchCompleted(const QString &queryString);

private:
    QSqlDatabase database;
    QList<HeinzelnisseElement*>* resultList;
    DictionarySearchWorker* searchWorker;
    QString dictionaryId;

};

#endif // DATABASEMANAGER_H
