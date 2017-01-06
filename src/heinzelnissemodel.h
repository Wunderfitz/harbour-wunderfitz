#ifndef HEINZELNISSEMODEL_H
#define HEINZELNISSEMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include "databasemanager.h"
#include "heinzelnisseelement.h"

class HeinzelnisseModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit HeinzelnisseModel(QObject *parent = 0);

    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE QString getLastQuery();

    void setDictionaryId(const QString &dictionaryId);

private:
    DatabaseManager databaseManager;
    QList<HeinzelnisseElement*>* resultList;
    QString lastQuery;

    QString getResult(const int index);
};

#endif // HEINZELNISSEMODEL_H
