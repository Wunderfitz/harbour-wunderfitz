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
