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
#include <Secrets/createcollectionrequest.h>
#include <Secrets/storesecretrequest.h>
#include <Secrets/storedsecretrequest.h>

#include "cloudapi.h"

Curiosity::Curiosity(QObject *parent) : QObject(parent)
{
    this->networkAccessManager = new QNetworkAccessManager(this);
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
    this->translatedText = "";
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

bool Curiosity::getUseCloud()
{
    return settings.value(SETTINGS_USE_CLOUD, false).toBool();
}

void Curiosity::setUseCloud(const bool &useCloud)
{
    qDebug() << "[Curiosity] Set use cloud" << useCloud;
    settings.setValue(SETTINGS_USE_CLOUD, useCloud);
}

QString Curiosity::getTranslatedText()
{
    return this->translatedText;
}

void Curiosity::setComputerVisionKey(const QString &computerVisionKey)
{
    qDebug() << "[Curiosity] Set computer vision key";
    secretsWriteKey(QLatin1String(SECRETS_SECRET_CV_KEY), computerVisionKey);
}

QString Curiosity::getComputerVisionKey()
{
    if (settings.contains(SETTINGS_COMPUTER_VISION_KEY)) {
        QString legacyValue = settings.value(SETTINGS_COMPUTER_VISION_KEY).toString();
        if (!legacyValue.isEmpty()) {
            if (secretsWriteKey(QLatin1String(SECRETS_SECRET_CV_KEY), legacyValue)) {
                settings.remove(SETTINGS_COMPUTER_VISION_KEY);
                qDebug() << "[Curiosity] Migrated computer vision key to Secrets";
            } else {
                qWarning() << "[Curiosity] Migration of computer vision key failed; retaining QSettings value";
                return legacyValue;
            }
        } else {
            settings.remove(SETTINGS_COMPUTER_VISION_KEY);
        }
    }
    return secretsReadKey(QLatin1String(SECRETS_SECRET_CV_KEY));
}

void Curiosity::setComputerVisionEndpoint(const QString &computerVisionEndpoint)
{
    qDebug() << "[Curiosity] Set computer vision endpoint" << computerVisionEndpoint;
    settings.setValue(SETTINGS_COMPUTER_VISION_ENDPOINT, computerVisionEndpoint);
}

QString Curiosity::getComputerVisionEndpoint()
{
    return settings.value(SETTINGS_COMPUTER_VISION_ENDPOINT, DEFAULT_COMPUTER_VISION_ENDPOINT).toString();
}

void Curiosity::setTranslatorTextKey(const QString &translatorTextKey)
{
    qDebug() << "[Curiosity] Set translator text key";
    secretsWriteKey(QLatin1String(SECRETS_SECRET_TR_KEY), translatorTextKey);
}

QString Curiosity::getTranslatorTextKey()
{
    if (settings.contains(SETTINGS_TRANSLATOR_TEXT_KEY)) {
        QString legacyValue = settings.value(SETTINGS_TRANSLATOR_TEXT_KEY).toString();
        if (!legacyValue.isEmpty()) {
            if (secretsWriteKey(QLatin1String(SECRETS_SECRET_TR_KEY), legacyValue)) {
                settings.remove(SETTINGS_TRANSLATOR_TEXT_KEY);
                qDebug() << "[Curiosity] Migrated translator text key to Secrets";
            } else {
                qWarning() << "[Curiosity] Migration of translator text key failed; retaining QSettings value";
                return legacyValue;
            }
        } else {
            settings.remove(SETTINGS_TRANSLATOR_TEXT_KEY);
        }
    }
    return secretsReadKey(QLatin1String(SECRETS_SECRET_TR_KEY));
}

void Curiosity::setTranslatorTextEndpoint(const QString &translatorTextEndpoint)
{
    qDebug() << "[Curiosity] Set translator text endpoint" << translatorTextEndpoint;
    settings.setValue(SETTINGS_TRANSLATOR_TEXT_ENDPOINT, translatorTextEndpoint);
}

QString Curiosity::getTranslatorTextEndpoint()
{
    return settings.value(SETTINGS_TRANSLATOR_TEXT_ENDPOINT, DEFAULT_TRANSLATOR_TEXT_ENDPOINT).toString();
}

void Curiosity::setTranslatorTextRegion(const QString &translatorTextRegion)
{
    qDebug() << "[Curiosity] Set translator text region" << translatorTextRegion;
    settings.setValue(SETTINGS_TRANSLATOR_TEXT_REGION, translatorTextRegion);
}

QString Curiosity::getTranslatorTextRegion()
{
    return settings.value(SETTINGS_TRANSLATOR_TEXT_REGION, DEFAULT_TRANSLATOR_TEXT_REGION).toString();
}

bool Curiosity::secretsWriteKey(const QString &secretName, const QString &value)
{
    Sailfish::Secrets::CreateCollectionRequest createRequest;
    createRequest.setManager(&secretManager);
    createRequest.setCollectionName(QLatin1String(SECRETS_COLLECTION_NAME));
    createRequest.setStoragePluginName(Sailfish::Secrets::SecretManager::DefaultEncryptedStoragePluginName);
    createRequest.setEncryptionPluginName(Sailfish::Secrets::SecretManager::DefaultEncryptionPluginName);
    createRequest.setAccessControlMode(Sailfish::Secrets::SecretManager::OwnerOnlyMode);
    createRequest.setCollectionLockType(Sailfish::Secrets::CreateCollectionRequest::DeviceLock);
    createRequest.setDeviceLockUnlockSemantic(Sailfish::Secrets::SecretManager::DeviceLockKeepUnlocked);
    createRequest.startRequest();
    createRequest.waitForFinished();

    Sailfish::Secrets::Result createResult = createRequest.result();
    if (createResult.code() == Sailfish::Secrets::Result::Failed
            && createResult.errorCode() != Sailfish::Secrets::Result::CollectionAlreadyExistsError) {
        qWarning() << "[Curiosity] Failed to create secrets collection:" << createResult.errorMessage();
        return false;
    }

    Sailfish::Secrets::Secret::Identifier id(
        secretName,
        QLatin1String(SECRETS_COLLECTION_NAME),
        Sailfish::Secrets::SecretManager::DefaultEncryptedStoragePluginName);
    Sailfish::Secrets::Secret secret(id);
    secret.setData(value.toUtf8());

    Sailfish::Secrets::StoreSecretRequest storeRequest;
    storeRequest.setManager(&secretManager);
    storeRequest.setSecretStorageType(Sailfish::Secrets::StoreSecretRequest::CollectionSecret);
    storeRequest.setSecret(secret);
    storeRequest.startRequest();
    storeRequest.waitForFinished();

    Sailfish::Secrets::Result storeResult = storeRequest.result();
    if (storeResult.code() == Sailfish::Secrets::Result::Failed) {
        qWarning() << "[Curiosity] Failed to store secret" << secretName << ":" << storeResult.errorMessage();
        return false;
    }
    return true;
}

QString Curiosity::secretsReadKey(const QString &secretName)
{
    Sailfish::Secrets::Secret::Identifier id(
        secretName,
        QLatin1String(SECRETS_COLLECTION_NAME),
        Sailfish::Secrets::SecretManager::DefaultEncryptedStoragePluginName);

    Sailfish::Secrets::StoredSecretRequest readRequest;
    readRequest.setManager(&secretManager);
    readRequest.setIdentifier(id);
    readRequest.startRequest();
    readRequest.waitForFinished();

    if (readRequest.result().code() == Sailfish::Secrets::Result::Failed) {
        return QString();
    }
    return QString::fromUtf8(readRequest.secret().data());
}

CloudApi *Curiosity::getCloudApi()
{
    return this->cloudApi;
}

void Curiosity::handleOcrProcessingSuccessful(const QString &fileName, const QJsonObject &result)
{
    qDebug() << "[Curiosity] Processing OCR result..." << fileName;
    QJsonObject readResult = result.value("readResult").toObject();
    QJsonArray blockArray = readResult.value("blocks").toArray();
    QString completeText;
    foreach (const QJsonValue &block, blockArray) {
        QJsonArray lineArray = block.toObject().value("lines").toArray();
        foreach (const QJsonValue &line, lineArray) {
            if (!completeText.isEmpty()) {
                completeText.append(" ");
            }
            completeText.append(line.toObject().value("text").toString());
        }
    }
    qDebug() << completeText;
    this->translatedText = completeText;
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

    // Maximum dimensions 4000x4000
    if (finalImage.width() >= 4000) {
        finalImage = finalImage.scaledToWidth(3999);
    }
    if (finalImage.height() >= 4000) {
        finalImage = finalImage.scaledToHeight(3999);
    }
    finalImage.save(this->capturePath);
    cloudApi->opticalCharacterRecognition(this->capturePath, this->getSourceLanguage());
}
