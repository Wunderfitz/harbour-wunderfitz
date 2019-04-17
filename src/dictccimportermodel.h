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
