#ifndef DICTIONARYMODEL_H
#define DICTIONARYMODEL_H

#include "dictionarymetadata.h"
#include "heinzelnissemodel.h"
#include "dictccimportermodel.h"

#include <QAbstractListModel>
#include <QSettings>
#include <QSqlDatabase>

class DictionaryModel : public QAbstractListModel
{
    Q_OBJECT
public:

    static const QString settingDictionaryId;
    static const QString heinzelnisseId;
    static const QString heinzelnisseLanguages;
    static const QString heinzelnisseTimestamp;

    DictionaryModel();

    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    HeinzelnisseModel heinzelnisseModel;
    DictCCImporterModel dictCCImporterModel;

    Q_INVOKABLE void selectDictionary(int dictionaryIndex);
    Q_INVOKABLE QString getSelectedDictionaryName();
    Q_INVOKABLE int getSelectedDictionaryIndex();

public slots:
    void handleImportFinished();

signals:
    void dictionaryChanged();

private:
    QString readLanguages(QSqlDatabase &database);
    QString readTimestamp(QSqlDatabase &database);
    void initializeDatabases();

    QList<DictionaryMetadata*> availableDictionaries;
    int selectedIndex;
    DictionaryMetadata* selectedDictionary;
    QSettings settings;
};

#endif // DICTIONARYMODEL_H
