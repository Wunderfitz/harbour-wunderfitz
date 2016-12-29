#include "dictccimportworker.h"
#include <JlCompress.h>
#include <QDebug>
#include <QDir>
#include <QRegExp>
#include <QStandardPaths>
#include <QStringList>
#include <QStringListIterator>

void DictCCImportWorker::importDictionaries()
{
    emit statusChanged(QString("Checking for new dictionaries..."));
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
            QString zipArchiveExtractionDir = getTempDirectory(tempDirectoryString + "/" + zipArchiveFileName);
            qDebug() << "Extracting archive " + zipArchiveFullPath + " to " + zipArchiveExtractionDir;
            QStringList extractedFiles = JlCompress::extractDir(zipArchiveFullPath, zipArchiveExtractionDir);
            QStringListIterator extractedFilesIterator(extractedFiles);
            while (extractedFilesIterator.hasNext()) {
                qDebug() << "Extracted file: " + extractedFilesIterator.next();
            }
        }
    }
}

QString DictCCImportWorker::getTempDirectory()
{
    QString tempDirectoryString = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/harbour-wunderfitz";
    return getTempDirectory(tempDirectoryString);
}

QString DictCCImportWorker::getTempDirectory(const QString &directoryString)
{
    QString tempDirectoryString = directoryString;
    QDir tempDirectory(directoryString);
    if (!tempDirectory.exists()) {
        qDebug() << "Creating directory " + directoryString;
        if (tempDirectory.mkdir(directoryString)) {
            qDebug() << "Directory " + directoryString + " successfully created!";
        } else {
            qDebug() << "Error creating directory " + directoryString + "!";
            tempDirectoryString = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
        }
    }
    return tempDirectoryString;
}
