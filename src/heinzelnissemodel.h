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

#ifndef HEINZELNISSEMODEL_H
#define HEINZELNISSEMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QTimer>
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
    Q_INVOKABLE bool isSearchInProgress();
    Q_INVOKABLE bool isEmpty();

    void setDictionaryId(const QString &dictionaryId);

public slots:
    void handleSearchCompleted(const QString &queryString);

signals:
    void searchStatusChanged();

private:
    DatabaseManager* databaseManager;
    QTimer* searchTimeout;
    QList<HeinzelnisseElement*>* resultList;
    QString lastQuery;
    bool searchInProgress;

    QString getResult(const int index);

private slots:
    void stopSearch();
};

#endif // HEINZELNISSEMODEL_H
