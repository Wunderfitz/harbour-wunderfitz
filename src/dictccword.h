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

#ifndef DICTCCWORD_H
#define DICTCCWORD_H

#include <QString>

class DictCCWord
{
public:
    DictCCWord();
    QString getWord() const;
    void setWord(const QString &value);

    QString getGender() const;
    void setGender(const QString &value);

    QString getOptional() const;
    void setOptional(const QString &value);

private:
    QString word;
    QString gender;
    QString optional;
};

#endif // DICTCCWORD_H
