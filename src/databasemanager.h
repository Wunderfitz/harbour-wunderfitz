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

#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QList>
#include <QString>
#include "heinzelnisseelement.h"
#include "databasemanager.h"
#include "dictionarysearchworker.h"

class DatabaseManager : public QObject {

    Q_OBJECT
public:
    DatabaseManager(QObject* parent);
    ~DatabaseManager();
    bool isOpen() const;
    void updateResults(const QString &query);
    QList<HeinzelnisseElement*>* getResultList();
    void setDictionaryId(const QString &dictionaryId);
    void stopSearch();

signals:
    void searchCompleted(const QString &queryString);

public slots:
    void handleSearchCompleted(const QString &queryString);

private:
    QSqlDatabase database;
    QList<HeinzelnisseElement*>* resultList;
    DictionarySearchWorker* searchWorker;
    QString dictionaryId;

};

#endif // DATABASEMANAGER_H
