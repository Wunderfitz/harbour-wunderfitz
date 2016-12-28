#ifndef DICTCCIMPORTERMODEL_H
#define DICTCCIMPORTERMODEL_H

#include <QAbstractListModel>

class DictCCImporterModel : public QAbstractListModel
{
    Q_OBJECT
public:
    DictCCImporterModel();

    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void importDictionaries();
public slots:
    void handleResults(const QString &results);

};

#endif // DICTCCIMPORTERMODEL_H
