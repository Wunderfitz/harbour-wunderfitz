#ifndef HEINZELNISSEELEMENT_H
#define HEINZELNISSEELEMENT_H

#include <QString>

class HeinzelnisseElement
{
public:
    HeinzelnisseElement();
    QString getWordNorwegian() const;
    void setWordNorwegian(const QString &value);

    QString getGenderNorwegian() const;
    void setGenderNorwegian(const QString &value);

    QString getOptionalNorwegian() const;
    void setOptionalNorwegian(const QString &value);

    QString getOtherNorwegian() const;
    void setOtherNorwegian(const QString &value);

    QString getWordGerman() const;
    void setWordGerman(const QString &value);

    QString getGenderGerman() const;
    void setGenderGerman(const QString &value);

    QString getOptionalGerman() const;
    void setOptionalGerman(const QString &value);

    QString getOtherGerman() const;
    void setOtherGerman(const QString &value);

    QString getCategory() const;
    void setCategory(const QString &value);

    QString getGrade() const;
    void setGrade(const QString &value);

private:
    QString wordNorwegian;
    QString genderNorwegian;
    QString optionalNorwegian;
    QString otherNorwegian;
    QString wordGerman;
    QString genderGerman;
    QString optionalGerman;
    QString otherGerman;
    QString category;
    QString grade;

};

#endif // HEINZELNISSEELEMENT_H
