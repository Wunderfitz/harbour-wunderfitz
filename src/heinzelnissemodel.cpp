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
        resultMap.insert("wordNorwegian", QVariant(resultElement->getWordNorwegian()));
        resultMap.insert("wordGerman", QVariant(resultElement->getWordGerman()));
        QString empty = "";
        QString genderNorwegian = resultElement->getGenderNorwegian();
        QString genderGerman = resultElement->getGenderGerman();
        if (genderNorwegian == empty) {
            resultMap.insert("genderNorwegian", QVariant(empty));
        } else {
            resultMap.insert("genderNorwegian", QVariant(" (" + genderNorwegian + ")"));
        }
        if (genderGerman == empty) {
            resultMap.insert("genderGerman", QVariant(empty));
        } else {
            resultMap.insert("genderGerman", QVariant(" (" + genderGerman + ")"));
        }
        resultMap.insert("optionalNorwegian", QVariant(resultElement->getOptionalNorwegian()));
        resultMap.insert("optionalGerman", QVariant(resultElement->getOptionalGerman()));
        resultMap.insert("otherNorwegian", QVariant(resultElement->getOtherNorwegian()));
        resultMap.insert("otherGerman", QVariant(resultElement->getOtherGerman()));
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
