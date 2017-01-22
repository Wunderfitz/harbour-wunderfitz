#ifndef DICTCCIMPORTERMODEL_H
#define DICTCCIMPORTERMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QMap>
#include "dictionarymetadata.h"

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
    void handleDictionaryFound(const QString &languages, const QString &timestamp);
signals:
    void statusChanged();
    void importFinished();
    void dictionaryFound(const QString &languages, const QString &timestamp);

private:
    QString statusText;
    QList<DictionaryMetadata*> importedDictionaries;
    bool working;

};

#endif // DICTCCIMPORTERMODEL_H
