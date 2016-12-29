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
    Q_INVOKABLE QString getStatusText();
    Q_INVOKABLE bool isWorking();
public slots:
    void handleImportFinished();
    void handleStatusChanged(const QString &statusText);
signals:
    void statusChanged();
    void importFinished();

private:
    QString statusText;
    bool working;

};

#endif // DICTCCIMPORTERMODEL_H
