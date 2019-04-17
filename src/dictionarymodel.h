/*
    Copyright (C) 2016-19 Sebastian J. Wolf

    This file is part of Wunderfitz.

    Wunderfitz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    Wunderfitz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Wunderfitz. If not, see <http://www.gnu.org/licenses/>.
*/

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
    static const QString settingRemainingHints;
    static const QString heinzelnisseId;
    static const QString heinzelnisseLanguages;
    static const QString heinzelnisseTimestamp;
    static const int currentMetadataVersion;

    DictionaryModel();

    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    HeinzelnisseModel heinzelnisseModel;
    DictCCImporterModel dictCCImporterModel;

    Q_INVOKABLE void selectDictionary(int dictionaryIndex);
    Q_INVOKABLE void deleteSelectedDictionary();
    Q_INVOKABLE QString getSelectedDictionaryName();
    Q_INVOKABLE QString getSelectedDictionaryId();
    Q_INVOKABLE int getSelectedDictionaryIndex();
    Q_INVOKABLE bool isInteractionHintDisplayed();

public slots:
    void handleModelChanged();

signals:
    void dictionaryChanged();
    void deletionNotSuccessful(const QString &dictionaryId);

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
