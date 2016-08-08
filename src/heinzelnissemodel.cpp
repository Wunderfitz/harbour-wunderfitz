#include <QDebug>
#include "heinzelnissemodel.h"

HeinzelnisseModel::HeinzelnisseModel(QObject *parent) : QAbstractListModel(parent)
{
    // Initializations (and Test Code ;))
    if (databaseManager.isOpen()) {
        qDebug() << "Database successfully initialized!";
        resultList = databaseManager.getResultList();
    } else {
        qDebug() << "Unable to initialize database!";
    }
}

QVariant HeinzelnisseModel::data(const QModelIndex &index, int role) const {
    if(!index.isValid()) {
        return QVariant();
    }
    if(role == Qt::DisplayRole) {
        HeinzelnisseElement* resultElement = resultList->value(index.row());
        QMap<QString,QVariant> resultMap;
        resultMap.insert("norwegisch", QVariant(resultElement->getWordNorwegian()));
        resultMap.insert("deutsch", QVariant(resultElement->getWordGerman()));
        return QVariant(resultMap);
    }
    return QVariant();
}

int HeinzelnisseModel::rowCount(const QModelIndex&) const {
    return resultList->size();
}

void HeinzelnisseModel::search(const QString &query) {
    beginResetModel();
    databaseManager.updateResults(query);
    endResetModel();
}
