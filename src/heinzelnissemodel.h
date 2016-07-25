#ifndef HEINZELNISSEMODEL_H
#define HEINZELNISSEMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "databasemanager.h"
#include "heinzelnisseelement.h"

class HeinzelnisseModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit HeinzelnisseModel(QObject *parent = 0);

    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

private:
    DatabaseManager databaseManager;
    QList<HeinzelnisseElement*>* resultList;

};

#endif // HEINZELNISSEMODEL_H
