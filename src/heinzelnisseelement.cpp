#include "heinzelnisseelement.h"

HeinzelnisseElement::HeinzelnisseElement(QObject* parent) : QObject(parent) {

}

QString HeinzelnisseElement::getWordLeft() const
{
    return wordLeft;
}

void HeinzelnisseElement::setWordLeft(const QString &value)
{
    wordLeft = value;
}

QString HeinzelnisseElement::getGenderLeft() const
{
    return genderLeft;
}

void HeinzelnisseElement::setGenderLeft(const QString &value)
{
    genderLeft = value;
}

QString HeinzelnisseElement::getOptionalLeft() const
{
    return optionalLeft;
}

void HeinzelnisseElement::setOptionalLeft(const QString &value)
{
    optionalLeft = value;
}

QString HeinzelnisseElement::getOtherLeft() const
{
    return otherLeft;
}

void HeinzelnisseElement::setOtherLeft(const QString &value)
{
    otherLeft = value;
}

QString HeinzelnisseElement::getWordRight() const
{
    return wordRight;
}

void HeinzelnisseElement::setWordRight(const QString &value)
{
    wordRight = value;
}

QString HeinzelnisseElement::getGenderRight() const
{
    return genderRight;
}

void HeinzelnisseElement::setGenderRight(const QString &value)
{
    genderRight = value;
}

QString HeinzelnisseElement::getOptionalRight() const
{
    return optionalRight;
}

void HeinzelnisseElement::setOptionalRight(const QString &value)
{
    optionalRight = value;
}

QString HeinzelnisseElement::getOtherRight() const
{
    return otherRight;
}

void HeinzelnisseElement::setOtherRight(const QString &value)
{
    otherRight = value;
}

QString HeinzelnisseElement::getCategory() const
{
    return category;
}

void HeinzelnisseElement::setCategory(const QString &value)
{
    category = value;
}

QString HeinzelnisseElement::getGrade() const
{
    return grade;
}

void HeinzelnisseElement::setGrade(const QString &value)
{
    grade = value;
}

int HeinzelnisseElement::getIndex() const
{
    return index;
}

void HeinzelnisseElement::setIndex(int value)
{
    index = value;
}

QString HeinzelnisseElement::getClipboardText() const
{
    return clipboardText;
}

void HeinzelnisseElement::setClipboardText(const QString &value)
{
    clipboardText = value;
}

