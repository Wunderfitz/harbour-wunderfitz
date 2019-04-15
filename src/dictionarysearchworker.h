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

#ifndef DICTIONARYSEARCHWORKER_H
#define DICTIONARYSEARCHWORKER_H

#include <QList>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QString>
#include <QThread>
#include "heinzelnisseelement.h"

class DictionarySearchWorker : public QThread
{
    Q_OBJECT
    void run() Q_DECL_OVERRIDE {
        performSearch();
    }

public:
    DictionarySearchWorker(QList<HeinzelnisseElement*>* resultList);
    void setQueryParameters(QSqlDatabase &database, QString &dictionaryId, const QString &queryString);
signals:
    void searchCompleted(const QString &queryString);
private:
    QSqlDatabase database;
    QString dictionaryId;
    QList<HeinzelnisseElement*>* resultList;
    QString queryString;

    void performSearch();
    void populateElementFromQuery(const QSqlQuery &query, HeinzelnisseElement* &heinzelnisseElement) const;
    void addQueryResults(QSqlQuery &query, const QString &queryString);
    bool isWordMatch(HeinzelnisseElement* &heinzelnisseElement, const QString &queryString);
    bool isDirectMatch(HeinzelnisseElement* &heinzelnisseElement, const QString &queryString);
    bool isIndirectMatch(HeinzelnisseElement* &heinzelnisseElement, const QString &queryString);
    void appendRawList(QList<HeinzelnisseElement*> &rawList);
};

#endif // DICTIONARYSEARCHWORKER_H
