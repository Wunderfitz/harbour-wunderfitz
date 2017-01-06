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
