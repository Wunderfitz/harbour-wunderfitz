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

#include "dictccword.h"

DictCCWord::DictCCWord()
{

}

QString DictCCWord::getWord() const
{
    return word;
}

void DictCCWord::setWord(const QString &value)
{
    word = value;
}

QString DictCCWord::getGender() const
{
    return gender;
}

void DictCCWord::setGender(const QString &value)
{
    gender = value;
}

QString DictCCWord::getOptional() const
{
    return optional;
}

void DictCCWord::setOptional(const QString &value)
{
    optional = value;
}
