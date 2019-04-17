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

#ifndef DICTCCDICTIONARYMETADATA_H
#define DICTCCDICTIONARYMETADATA_H

#include<QObject>

class DictionaryMetadata : public QObject
{
    Q_OBJECT
public:

    DictionaryMetadata(QObject* parent = 0);
    QString getLanguages() const;
    void setLanguages(const QString &value);

    QString getTimestamp() const;
    void setTimestamp(const QString &value);

    QString getId() const;
    void setId(const QString &value);

private:
    QString id;
    QString languages;
    QString timestamp;
};

#endif // DICTCCDICTIONARYMETADATA_H
