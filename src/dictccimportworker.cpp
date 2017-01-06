#include "dictccimportworker.h"
#include <JlCompress.h>
#include <QDebug>
#include <QDir>
#include <QRegExp>
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QStringList>
#include <QStringListIterator>

void DictCCImportWorker::importDictionaries()
{
    emit statusChanged("Checking for new dictionaries...");
    QString downloadDirectoryString = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    QString tempDirectoryString = getTempDirectory();
    qDebug() << "Reading from directory: " << downloadDirectoryString;
    qDebug() << "Extracting temporarily to directory: " << tempDirectoryString;
    QStringList nameFilter("*.zip");
    QDir downloadDirectory(downloadDirectoryString);
    QStringList zipFiles = downloadDirectory.entryList(nameFilter);
    QStringListIterator zipFilesIterator(zipFiles);
    QRegExp dictCCMatcher("\\w+\\-\\d+\\-\\w+\\.zip");
    while (zipFilesIterator.hasNext()) {
        QString zipArchiveFileName = zipFilesIterator.next();
        QString zipArchiveFullPath = downloadDirectoryString + "/" + zipArchiveFileName;
        if (dictCCMatcher.indexIn(zipArchiveFileName, 0) != -1) {
            qDebug() << downloadDirectoryString + "/" + zipArchiveFileName + " successfully validated!";
            QString zipArchiveExtractionDir = getDirectory(tempDirectoryString + "/" + zipArchiveFileName);
            qDebug() << "Extracting archive " + zipArchiveFullPath + " to " + zipArchiveExtractionDir;
            QStringList extractedFiles = JlCompress::extractDir(zipArchiveFullPath, zipArchiveExtractionDir);
            QStringListIterator extractedFilesIterator(extractedFiles);
            while (extractedFilesIterator.hasNext()) {
                QString extractedFileName = extractedFilesIterator.next();
                qDebug() << "Extracted file: " + extractedFileName;
                readFile(extractedFileName);
            }
        }
    }
}

void DictCCImportWorker::readFile(QString &completeFileName)
{
    QFile inputFile(completeFileName);
    if (inputFile.open(QIODevice::ReadOnly))
    {
       QTextStream inputStream(&inputFile);
       inputStream.setCodec("UTF-8");
       QMap<QString,QString> dictionaryMetadata = getMetadata(inputStream);
       if (dictionaryMetadata.contains("languages") && dictionaryMetadata.contains("timestamp")) {
           emit statusChanged("Dict.cc dictionary found: " + dictionaryMetadata.value("languages") + " - " + dictionaryMetadata.value("timestamp"));
           writeDictionary(inputStream, dictionaryMetadata);
       }
       inputFile.close();
    } else
    {
        qDebug() << "Unable to open extracted file " + completeFileName;
    }
}



QMap<QString,QString> DictCCImportWorker::getMetadata(QTextStream &inputStream) {
    QMap<QString,QString> metadata;
    if (!inputStream.atEnd()) {
        QString firstLine = inputStream.readLine();
        QRegExp languagesMatcher("([A-Z]{2}\\-[A-Z]{2})");
        if (firstLine.contains("dict.cc") && languagesMatcher.indexIn(firstLine) != -1) {
            qDebug() << "Dictionary languages identified: " + languagesMatcher.cap(1);
            metadata.insert("languages", languagesMatcher.cap(1));
        }
        if (!inputStream.atEnd()) {
            QString secondLine = inputStream.readLine();
            QRegExp dateTimeMatcher("(\\d{4}\\-\\d{2}\\-\\d{2}\\s\\d{2}\\:\\d{2})");
            if (dateTimeMatcher.indexIn(secondLine) != -1) {
                qDebug() << "Dictionary timestamp identified: " + dateTimeMatcher.cap(1);
                metadata.insert("timestamp", dateTimeMatcher.cap(1));
            }
        }
    }
    return metadata;
}

void DictCCImportWorker::writeDictionary(QTextStream &inputStream, QMap<QString, QString> &metadata)
{
    QString databaseDirectory = getDirectory(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/harbour-wunderfitz");
    QString databaseFilePath = databaseDirectory + "/" + metadata.value("languages") + ".db";
    QSqlDatabase database = QSqlDatabase::addDatabase("QSQLITE", "connection" + metadata.value("languages"));
    database.setDatabaseName(databaseFilePath);
    if (database.open()) {
        qDebug() << "SQLite database " + databaseFilePath + " successfully opened";
        writeMetadata(metadata, database);
        writeDictionaryEntries(inputStream, metadata, database);
        database.close();
    } else {
        qDebug() << "Error opening SQLite database " + databaseFilePath;
    }
}

void DictCCImportWorker::writeMetadata(QMap<QString, QString> &metadata, QSqlDatabase &database)
{
    QSqlQuery databaseQuery(database);
    QStringList existingTables = database.tables();
    if (!existingTables.contains("metadata")) {
        databaseQuery.prepare("create table metadata (key text primary key, value text)");
        if (databaseQuery.exec()) {
            qDebug() << "Metadata table successfully created!";
        } else {
            qDebug() << "Error creating metadata table!";
        }
    } else {
        qDebug() << "Metadata table already existing";
    }
    databaseQuery.prepare("insert or replace into metadata values((:key),(:value))");
    databaseQuery.bindValue(":key", "languages");
    databaseQuery.bindValue(":value", metadata.value("languages"));
    if (databaseQuery.exec()) {
        qDebug() << "Languages successfully stored in metadata table";
    }
    databaseQuery.bindValue(":key", "timestamp");
    databaseQuery.bindValue(":value", metadata.value("timestamp"));
    if (databaseQuery.exec()) {
        qDebug() << "Timestamp successfully stored in metadata table";
    }
}

void DictCCImportWorker::writeDictionaryEntries(QTextStream &inputStream, QMap<QString,QString> &metadata, QSqlDatabase &database)
{
    QSqlQuery databaseQuery(database);
    QStringList existingTables = database.tables();
    if (existingTables.contains("entries")) {
        databaseQuery.prepare("drop table entries");
        if (!databaseQuery.exec()) {
            qDebug() << "Error removing entries table.";
            return;
        }
    }

    databaseQuery.prepare("create virtual table entries using fts4(id integer primary key, left_word text, left_gender text, left_other text, right_word text, right_gender text, right_other text, category text, tokenize=porter)");
    if (databaseQuery.exec()) {
        qDebug() << "Entries table successfully created!";
    } else {
        qDebug() << "Error creating entries table!";
        return;
    }

    QStringList rawEntries;
    int lineCount = 0;
    while(!inputStream.atEnd())
    {
        QString newLine = inputStream.readLine();
        if (!newLine.startsWith("#")) {
            rawEntries.append(newLine);
            lineCount++;
        }
    }
    QStringListIterator rawEntriesIterator(rawEntries);
    int currentLineNumber = 0;
    int successfullyWrittenEntries = 0;
    emit statusChanged(metadata.value("languages") + " dictionary: Importing " + QString::number(lineCount) + " entries.");

    databaseQuery.prepare("begin transaction");
    databaseQuery.exec();

    databaseQuery.prepare("insert into entries values((:id),(:left_word),(:left_gender),(:left_other),(:right_word),(:right_gender),(:right_other),(:category))");
    while (rawEntriesIterator.hasNext()) {
        currentLineNumber++;
        div_t divisionResult = div(currentLineNumber * 100, lineCount);
        div_t everyHundredResult = div(currentLineNumber, 100);
        QStringList currentResult = rawEntriesIterator.next().split("\t");
        if (currentResult.count() == 3) {
            databaseQuery.bindValue(":id", currentLineNumber);
            DictCCWord leftWord = getDictCCWord(currentResult.value(0));
            databaseQuery.bindValue(":left_word", leftWord.getWord());
            databaseQuery.bindValue(":left_gender", leftWord.getGender());
            databaseQuery.bindValue(":left_other", leftWord.getOptional());
            DictCCWord rightWord = getDictCCWord(currentResult.value(1));
            databaseQuery.bindValue(":right_word", rightWord.getWord());
            databaseQuery.bindValue(":right_gender", rightWord.getGender());
            databaseQuery.bindValue(":right_other", rightWord.getOptional());
            databaseQuery.bindValue(":category", currentResult.value(2));
            if (databaseQuery.exec()) {
                successfullyWrittenEntries++;
            } else {
                qDebug() << databaseQuery.lastError().text();
            }
        }
        if (everyHundredResult.rem == 0) {
            emit statusChanged(QString::number(currentLineNumber) + " of " + QString::number(lineCount) + " entries imported.\n" + QString::number(divisionResult.quot) + "% completed");
        }
    }

    databaseQuery.prepare("end transaction");
    databaseQuery.exec();

    qDebug() << metadata.value("languages") + ": " + QString::number(successfullyWrittenEntries) + " entries imported.";
    emit statusChanged(metadata.value("languages") + " dictionary with " + QString::number(successfullyWrittenEntries) + " entries successfully imported.");

}

DictCCWord DictCCImportWorker::getDictCCWord(QString rawWord)
{
    DictCCWord dictCCWord;
    QString realWord = rawWord;
    QRegExp genderMatcher("(\\{.+\\})");
    if (genderMatcher.indexIn(realWord) != -1) {
        QString genderString = genderMatcher.cap(1);
        genderString = genderString.replace("{", "(");
        genderString = genderString.replace("}", ")");
        dictCCWord.setGender(genderString);
        realWord = realWord.remove(genderMatcher);
    }
    QRegExp optionalMatcher("(\\[.+\\])");
    if (optionalMatcher.indexIn(realWord) != -1) {
        dictCCWord.setOptional(optionalMatcher.cap(1));
        realWord = realWord.remove(optionalMatcher);
    }
    dictCCWord.setWord(realWord.trimmed());
    return dictCCWord;
}

QString DictCCImportWorker::getTempDirectory()
{
    QString tempDirectoryString = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/harbour-wunderfitz";
    return getDirectory(tempDirectoryString);
}

QString DictCCImportWorker::getDirectory(const QString &directoryString)
{
    QString myDirectoryString = directoryString;
    QDir myDirectory(directoryString);
    if (!myDirectory.exists()) {
        qDebug() << "Creating directory " + directoryString;
        if (myDirectory.mkdir(directoryString)) {
            qDebug() << "Directory " + directoryString + " successfully created!";
        } else {
            qDebug() << "Error creating directory " + directoryString + "!";
            myDirectoryString = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
        }
    }
    return myDirectoryString;
}
