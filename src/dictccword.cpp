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
