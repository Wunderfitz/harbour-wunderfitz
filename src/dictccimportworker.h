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

#ifndef DICTCCIMPORTWORKER_H
#define DICTCCIMPORTWORKER_H

#include <QMap>
#include <QThread>
#include <QSqlDatabase>
#include <QString>
#include <QTextStream>
#include "dictccword.h"

class DictCCImportWorker : public QThread
{
    Q_OBJECT
    void run() Q_DECL_OVERRIDE {
        importDictionaries();
    }
public:
    DictCCImportWorker();
signals:
        void importFinished();
        void dictionaryFound(const QString &languages, const QString &timestamp);
        void statusChanged(const QString &statusText);
private:

    void importDictionaries();
    void readFile(QString &completeFileName);
    QMap<QString,QString> getMetadata(QTextStream &inputStream);
    void writeDictionary(QTextStream &inputStream, QMap<QString,QString> &metadata);
    bool isAlreadyImported(QMap<QString,QString> &metadata, QSqlDatabase &database);
    void writeMetadata(QMap<QString,QString> &metadata, QSqlDatabase &database);
    void writeDictionaryEntries(QTextStream &inputStream, QMap<QString,QString> &metadata, QSqlDatabase &database);
    int currentMetadataVersion;
    DictCCWord getDictCCWord(QString rawWord);
    QString getTempDirectory();
    QString getDirectory(const QString &directoryString);
};

#endif // DICTCCIMPORTWORKER_H
