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

#include <QDebug>
#include "heinzelnissemodel.h"

HeinzelnisseModel::HeinzelnisseModel(QObject *parent) : QAbstractListModel(parent)
{
    databaseManager = new DatabaseManager(this);
    // Initializations (and Test Code ;))
    if (databaseManager->isOpen()) {
        qDebug() << "Database successfully initialized!";
        resultList = databaseManager->getResultList();
    } else {
        qDebug() << "Unable to initialize database!";
    }
    lastQuery = "";
    searchInProgress = false;

    connect(databaseManager, SIGNAL(searchCompleted(QString)), this, SLOT(handleSearchCompleted(QString)));

    searchTimeout = new QTimer(this);
    connect(searchTimeout, SIGNAL(timeout()), this, SLOT(stopSearch()));
}

QVariant HeinzelnisseModel::data(const QModelIndex &index, int role) const {
    if(!index.isValid()) {
        return QVariant();
    }
    if(role == Qt::DisplayRole) {
        HeinzelnisseElement* resultElement = resultList->value(index.row());
        QMap<QString,QVariant> resultMap;
        resultMap.insert("wordLeft", QVariant(resultElement->getWordLeft()));
        resultMap.insert("wordRight", QVariant(resultElement->getWordRight()));
        resultMap.insert("genderLeft", QVariant(resultElement->getGenderLeft()));
        resultMap.insert("genderRight", QVariant(resultElement->getGenderRight()));
        resultMap.insert("optionalLeft", QVariant(resultElement->getOptionalLeft()));
        resultMap.insert("optionalRight", QVariant(resultElement->getOptionalRight()));
        resultMap.insert("otherLeft", QVariant(resultElement->getOtherLeft()));
        resultMap.insert("otherRight", QVariant(resultElement->getOtherRight()));
        resultMap.insert("clipboardText", QVariant(resultElement->getClipboardText()));
        return QVariant(resultMap);
    }
    return QVariant();
}

int HeinzelnisseModel::rowCount(const QModelIndex&) const {
    return resultList->size();
}

void HeinzelnisseModel::search(const QString &query) {
    searchInProgress = true;
    emit searchStatusChanged();
    searchTimeout->start(3000);
    databaseManager->updateResults(query);
}

QString HeinzelnisseModel::getResult(const int index) {
    if (resultList->size() <= index) {
        return QString("");
    } else {
        HeinzelnisseElement* result = resultList->value(index);
        return QString(result->getWordLeft() + " - " + result->getWordRight());
    }
}

void HeinzelnisseModel::stopSearch()
{
    qDebug() << "Search timeout...";
    databaseManager->stopSearch();
}

QString HeinzelnisseModel::getLastQuery() {
    if (lastQuery == "") {
        return QString("-");
    } else {
        return lastQuery;
    }
}

void HeinzelnisseModel::setDictionaryId(const QString &dictionaryId)
{
    databaseManager->setDictionaryId(dictionaryId);
}

bool HeinzelnisseModel::isSearchInProgress()
{
    return searchInProgress;
}

bool HeinzelnisseModel::isEmpty()
{
    if (!isSearchInProgress() && !lastQuery.isEmpty() && resultList->isEmpty()) {
        return true;
    }
    return false;
}

void HeinzelnisseModel::handleSearchCompleted(const QString &queryString)
{
    beginResetModel();
    lastQuery = queryString;
    endResetModel();
    searchInProgress = false;
    searchTimeout->stop();
    emit searchStatusChanged();
}
