#include "dictionarymetadata.h"

DictionaryMetadata::DictionaryMetadata(QObject* parent) : QObject(parent) {

}

QString DictionaryMetadata::getLanguages() const
{
    return languages;
}

void DictionaryMetadata::setLanguages(const QString &value)
{
    languages = value;
}

QString DictionaryMetadata::getTimestamp() const
{
    return timestamp;
}

void DictionaryMetadata::setTimestamp(const QString &value)
{
    timestamp = value;
}

QString DictionaryMetadata::getId() const
{
    return id;
}

void DictionaryMetadata::setId(const QString &value)
{
    id = value;
}
