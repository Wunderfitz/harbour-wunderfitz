#include <QDebug>
#include "heinzelnissemodel.h"

HeinzelnisseModel::HeinzelnisseModel(QObject *parent) : QAbstractListModel(parent)
{
    databaseManager = new DatabaseManager( NULL );
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
    emit searchStatusChanged();
}
