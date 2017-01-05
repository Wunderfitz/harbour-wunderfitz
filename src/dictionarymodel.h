#ifndef DICTIONARYMODEL_H
#define DICTIONARYMODEL_H

#include "dictionarymetadata.h"

#include <QAbstractListModel>
#include <QSqlDatabase>

class DictionaryModel : public QAbstractListModel
{
    Q_OBJECT
public:
    DictionaryModel();

    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void selectDictionary(int dictionaryIndex);
    Q_INVOKABLE QString getSelectedDictionaryName();
    Q_INVOKABLE int getSelectedDictionaryIndex();

signals:
    void dictionaryChanged();

private:
    QString readLanguages(QSqlDatabase &database);
    QString readTimestamp(QSqlDatabase &database);
    QList<DictionaryMetadata*> availableDictionaries;
    int selectedIndex;
    DictionaryMetadata* selectedDictionary;

};

#endif // DICTIONARYMODEL_H
