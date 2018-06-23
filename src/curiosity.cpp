/*
    Copyright (C) 2016-18 Sebastian J. Wolf

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

#include "curiosity.h"
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QDirIterator>
#include <QStandardPaths>
#include <QList>
#include <QImageReader>
#include <QImage>
#include <QMatrix>
#include <QRect>
#include <QJsonObject>

const char SETTINGS_SOURCE_LANGUAGE[] = "settings/sourceLanguage";
const char SETTINGS_TARGET_LANGUAGE[] = "settings/targetLanguage";

Curiosity::Curiosity(QObject *parent) : QObject(parent)
{
    this->networkAccessManager = new QNetworkAccessManager(this);
    wagnis = new Wagnis(this->networkAccessManager, "harbour-wunderfitz", "1.1", this);
    QString tempDirectoryString = getTemporaryDirectoryPath();
    QDir myDirectory(tempDirectoryString);
    if (!myDirectory.exists()) {
        qDebug() << "[Curiosity] Creating temporary directory";
        if (myDirectory.mkdir(tempDirectoryString)) {
            qDebug() << "[Curiosity] Directory " + tempDirectoryString + " successfully created!";
        } else {
            qDebug() << "[Curiosity] Error creating directory " + tempDirectoryString + "!";
        }
    } else {
        qDebug() << "[Curiosity] Cleaning temporary files...";
        removeTemporaryFiles();
    }
    this->cloudApi = new CloudApi(this->networkAccessManager, this);

    connect(cloudApi, SIGNAL(ocrUploadSuccessful(QString,QJsonObject)), this, SLOT(handleOcrProcessingSuccessful(QString,QJsonObject)));
    connect(cloudApi, SIGNAL(ocrUploadError(QString,QString)), this, SLOT(handleOcrProcessingError(QString,QString)));
    connect(cloudApi, SIGNAL(ocrUploadStatus(QString,qint64,qint64)), this, SLOT(handleOcrProcessingStatus(QString,qint64,qint64)));
    connect(cloudApi, SIGNAL(translateSuccessful(QJsonArray)), this, SLOT(handleTranslationSuccessful(QJsonArray)));
    connect(cloudApi, SIGNAL(translateError(QString)), this, SLOT(handleTranslationError(QString)));
}

QString Curiosity::getTemporaryDirectoryPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/harbour-wunderfitz";
}

void Curiosity::removeTemporaryFiles()
{
    QDirIterator temporaryDirectoryIterator(getTemporaryDirectoryPath(), QDir::Files, QDirIterator::Subdirectories);
    while (temporaryDirectoryIterator.hasNext()) {
        QString weRemoveThisOne = temporaryDirectoryIterator.next();
        qDebug() << "[Curiosity] Removing " << weRemoveThisOne;
        QFile::remove(weRemoveThisOne);
    }
}

void Curiosity::captureRequested(const int &orientation, const int &viewfinderDimension, const int &offset)
{
    qDebug() << "[Curiosity] Capture requested" << orientation << viewfinderDimension << offset;
    this->captureOrientation = orientation;
    this->captureViewfinderDimension = viewfinderDimension;
    this->captureOffset = offset;
}

void Curiosity::captureCompleted(const QString &path)
{
    qDebug() << "[Curiosity] Capture completed" << path;
    this->capturePath = path;
    this->processCapture();
}

QString Curiosity::getSourceLanguage()
{
    return settings.value(SETTINGS_SOURCE_LANGUAGE, "unk").toString();
}

void Curiosity::setSourceLanguage(const QString &sourceLanguage)
{
    qDebug() << "[Curiosity] Set source language" << sourceLanguage;
    settings.setValue(SETTINGS_SOURCE_LANGUAGE, sourceLanguage);
}

QString Curiosity::getTargetLanguage()
{
    return settings.value(SETTINGS_TARGET_LANGUAGE, "en").toString();
}

void Curiosity::setTargetLanguage(const QString &targetLanguage)
{
    qDebug() << "[Curiosity] Set target language" << targetLanguage;
    settings.setValue(SETTINGS_TARGET_LANGUAGE, targetLanguage);
}

CloudApi *Curiosity::getCloudApi()
{
    return this->cloudApi;
}

Wagnis *Curiosity::getWagnis()
{
    return this->wagnis;
}

void Curiosity::handleOcrProcessingSuccessful(const QString &fileName, const QJsonObject &result)
{
    qDebug() << "[Curiosity] Processing OCR result..." << fileName;
    QJsonArray regionArray = result.value("regions").toArray();
    QString completeText;
    foreach (const QJsonValue &region, regionArray) {
        QJsonArray lineArray = region.toObject().value("lines").toArray();
        foreach (const QJsonValue &line, lineArray) {
            QJsonArray wordArray = line.toObject().value("words").toArray();
            foreach (const QJsonValue &word, wordArray) {
                if (!completeText.isEmpty()) {
                    completeText.append(" ");
                }
                completeText.append(word.toObject().value("text").toString());
            }
        }
    }
    qDebug() << completeText;
    emit ocrSuccessful();
    cloudApi->translate(completeText, this->getTargetLanguage());
}

void Curiosity::handleOcrProcessingError(const QString &fileName, const QString &errorMessage)
{
    qDebug() << "[Curiosity] OCR processing error..." << fileName << errorMessage;
    emit ocrError(errorMessage);
}

void Curiosity::handleOcrProcessingStatus(const QString &fileName, qint64 bytesSent, qint64 bytesTotal)
{
    qDebug() << "[Curiosity] OCR processing status update" << fileName << bytesSent << bytesTotal;
    if (bytesTotal == 0) {
        return;
    }
    int percentCompleted = 100 * bytesSent / bytesTotal;
    emit ocrProgress(percentCompleted);
}

void Curiosity::handleTranslationSuccessful(const QJsonArray &result)
{
    qDebug() << "[Curiosity] Processing translation result...";
    emit translationSuccessful(result.at(0).toObject().value("translations").toArray().at(0).toObject().value("text").toString());
}

void Curiosity::handleTranslationError(const QString &errorMessage)
{
    qDebug() << "[Curiosity] Translation error..." << errorMessage;
    emit translationError(errorMessage);
}

void Curiosity::processCapture()
{
    if (!wagnis->hasFeature("contribution") && wagnis->getRemainingTime() == 0) {
        emit ocrError("You haven't completed the registration process!");
        return;
    }
    qDebug() << "[Curiosity] Processing capture...";
    QImageReader imageReader;
    imageReader.setFileName(this->capturePath);
    QImage myImage = imageReader.read();
    QMatrix transformationMatrix;
    switch (this->captureOrientation) {
    case 1:
        // Portrait
        transformationMatrix.rotate(90);
        break;
    case 2:
        // Landscape
        transformationMatrix.rotate(0);
        break;
    case 4:
        // Portait Inverted
        transformationMatrix.rotate(270);
        break;
    case 8:
        // Landscape Inverted
        transformationMatrix.rotate(180);
        break;
    default:
        break;
    }
    myImage = myImage.transformed(transformationMatrix);
    QRect imageDimensions = myImage.rect();
    QImage finalImage;
    if (this->captureOrientation == 2 || this->captureOrientation == 8) {
        float offsetRatio = myImage.width() / this->captureViewfinderDimension;
        imageDimensions.setLeft(this->captureOffset * offsetRatio);
    } else {
        float offsetRatio = myImage.height() / this->captureViewfinderDimension;
        imageDimensions.setTop(this->captureOffset * offsetRatio);
    }
    qDebug() << imageDimensions;
    finalImage = myImage.copy(imageDimensions);
    finalImage.save(this->capturePath);

    cloudApi->opticalCharacterRecognition(this->capturePath, this->getSourceLanguage());
}
