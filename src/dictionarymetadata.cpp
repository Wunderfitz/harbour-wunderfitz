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
