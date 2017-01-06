#include "dictionarysearchworker.h"
#include "dictionarymodel.h"

DictionarySearchWorker::DictionarySearchWorker(QList<HeinzelnisseElement*>* resultList)
{
    this->resultList = resultList;
}

void DictionarySearchWorker::setQueryParameters(QSqlDatabase &database, QString &dictionaryId, const QString &queryString)
{
    this->database = database;
    this->queryString = queryString;
    this->dictionaryId = dictionaryId;
}

void DictionarySearchWorker::performSearch()
{
    qDeleteAll(*resultList);
    resultList->clear();

    if (database.open()) {
        QSqlQuery query(database);

        if (this->dictionaryId == DictionaryModel::heinzelnisseId) {
            query.prepare("select * from heinzelnisse where heinzelnisse match (:queryString)");
        } else {
            query.prepare("select * from entries where entries match (:queryString)");
        }

        query.bindValue(":queryString", queryString + "*");
        addQueryResults(query, queryString);
    } else {
        qDebug() << "Unable to perform a query on database";
    }

    emit searchCompleted(queryString);
}

bool DictionarySearchWorker::isWordMatch(HeinzelnisseElement *&heinzelnisseElement, const QString &queryString)
{
    if (QString::compare(heinzelnisseElement->getWordLeft(), queryString, Qt::CaseInsensitive) == 0 ||
            QString::compare(heinzelnisseElement->getWordRight(), queryString, Qt::CaseInsensitive) == 0) {
        return true;
    }
    return false;
}

bool DictionarySearchWorker::isDirectMatch(HeinzelnisseElement *&heinzelnisseElement, const QString &queryString)
{
    if (heinzelnisseElement->getWordLeft().indexOf(queryString, 0, Qt::CaseInsensitive) == 0 ||
            heinzelnisseElement->getWordRight().indexOf(queryString, 0, Qt::CaseInsensitive) == 0) {
        return true;
    }
    return false;
}

bool DictionarySearchWorker::isIndirectMatch(HeinzelnisseElement *&heinzelnisseElement, const QString &queryString)
{
    if (heinzelnisseElement->getWordLeft().contains(queryString, Qt::CaseInsensitive) ||
            heinzelnisseElement->getWordRight().contains(queryString, Qt::CaseInsensitive)) {
        return true;
    }
    return false;
}

void DictionarySearchWorker::appendRawList(QList<HeinzelnisseElement *> &rawList)
{
    QListIterator<HeinzelnisseElement*> listIterator(rawList);
    while (listIterator.hasNext()) {
        resultList->append(listIterator.next());
    }
}

void DictionarySearchWorker::populateElementFromQuery(const QSqlQuery &query, HeinzelnisseElement* &heinzelnisseElement) const {
    if (this->dictionaryId == DictionaryModel::heinzelnisseId) {
        heinzelnisseElement->setIndex(query.value(0).toInt());
        heinzelnisseElement->setWordLeft(query.value(5).toString());
        heinzelnisseElement->setGenderLeft(query.value(6).toString());
        heinzelnisseElement->setOptionalLeft(query.value(7).toString());
        heinzelnisseElement->setOtherLeft(query.value(8).toString());
        heinzelnisseElement->setWordRight(query.value(1).toString());
        heinzelnisseElement->setGenderRight(query.value(2).toString());
        heinzelnisseElement->setOptionalRight(query.value(3).toString());
        heinzelnisseElement->setOtherRight(query.value(4).toString());
        heinzelnisseElement->setCategory(query.value(9).toString());
        heinzelnisseElement->setGrade(query.value(10).toString());
    } else {
        heinzelnisseElement->setIndex(query.value(0).toInt());
        heinzelnisseElement->setWordLeft(query.value(1).toString());
        heinzelnisseElement->setGenderLeft(query.value(2).toString());
        heinzelnisseElement->setOptionalLeft("");
        heinzelnisseElement->setOtherLeft(query.value(3).toString());
        heinzelnisseElement->setWordRight(query.value(4).toString());
        heinzelnisseElement->setGenderRight(query.value(5).toString());
        heinzelnisseElement->setOptionalRight("");
        heinzelnisseElement->setOtherRight(query.value(6).toString());
        heinzelnisseElement->setCategory(query.value(7).toString());
        heinzelnisseElement->setGrade("");
    }
}

void DictionarySearchWorker::addQueryResults(QSqlQuery &query, const QString &queryString) {
    query.exec();
    QList<HeinzelnisseElement*> wordMatches;
    QList<HeinzelnisseElement*> directMatches;
    QList<HeinzelnisseElement*> indirectMatches;
    QList<HeinzelnisseElement*> otherMatches;
    while (query.next()) {
        HeinzelnisseElement* nextElement = new HeinzelnisseElement();
        populateElementFromQuery(query, nextElement);
        if (isWordMatch(nextElement, queryString)) {
            wordMatches.append(nextElement);
            continue;
        }
        if (isDirectMatch(nextElement, queryString)) {
            directMatches.append(nextElement);
            continue;
        }
        if (isIndirectMatch(nextElement, queryString)) {
            indirectMatches.append(nextElement);
            continue;
        }
        otherMatches.append(nextElement);
    }
    appendRawList(wordMatches);
    appendRawList(directMatches);
    appendRawList(indirectMatches);
    appendRawList(otherMatches);
}
