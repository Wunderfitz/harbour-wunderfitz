#include <QDebug>
#include "heinzelnissemodel.h"

HeinzelnisseModel::HeinzelnisseModel(QObject *parent) : QAbstractListModel(parent)
{
    // Initializations (and Test Code ;))
    if (databaseManager.isOpen()) {
        qDebug() << "Good!";
        databaseManager.updateResults("haus");
        resultList = databaseManager.getResultList();
        QListIterator<HeinzelnisseElement*> resultsIterator(*resultList);
        while (resultsIterator.hasNext()) {
            HeinzelnisseElement* result = resultsIterator.next();
            qDebug() << result->getWordNorwegian() << " : " << result->getWordGerman();
        }
    } else {
        qDebug() << "Doh!";
    }
}

QVariant HeinzelnisseModel::data(const QModelIndex &index, int role) const {
    if(!index.isValid()) {
        return QVariant();
    }
    if(role == Qt::DisplayRole) {
        //return QVariant(*(resultList->value(index.row())));
    }
    return QVariant();
}

int HeinzelnisseModel::rowCount(const QModelIndex&) const {
    return resultList->size();
}
