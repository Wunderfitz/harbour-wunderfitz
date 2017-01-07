#ifndef HEINZELNISSEELEMENT_H
#define HEINZELNISSEELEMENT_H

#include <QString>
#include <QDebug>
#include <QObject>

class HeinzelnisseElement : public QObject {

    Q_OBJECT

public:
    HeinzelnisseElement(QObject* parent = 0);
    QString getWordLeft() const;
    void setWordLeft(const QString &value);

    QString getGenderLeft() const;
    void setGenderLeft(const QString &value);

    QString getOptionalLeft() const;
    void setOptionalLeft(const QString &value);

    QString getOtherLeft() const;
    void setOtherLeft(const QString &value);

    QString getWordRight() const;
    void setWordRight(const QString &value);

    QString getGenderRight() const;
    void setGenderRight(const QString &value);

    QString getOptionalRight() const;
    void setOptionalRight(const QString &value);

    QString getOtherRight() const;
    void setOtherRight(const QString &value);

    QString getCategory() const;
    void setCategory(const QString &value);

    QString getGrade() const;
    void setGrade(const QString &value);

    int getIndex() const;
    void setIndex(int value);

    inline bool operator ==(const HeinzelnisseElement &otherHeinzelnisseElement) const {
        return (index == otherHeinzelnisseElement.getIndex());
    }

    QString getClipboardText() const;
    void setClipboardText(const QString &value);

private:
    int index;
    QString wordLeft;
    QString genderLeft;
    QString optionalLeft;
    QString otherLeft;
    QString wordRight;
    QString genderRight;
    QString optionalRight;
    QString otherRight;
    QString category;
    QString grade;
    QString clipboardText;

};

#endif // HEINZELNISSEELEMENT_H
