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

#include "cloudapi.h"

CloudApi::CloudApi(QObject *parent) : QObject(parent)
{
    this->networkAccessManager = new QNetworkAccessManager(this);
}

void CloudApi::opticalCharacterRecognition(const QString &imagePath, const QString &sourceLanguage)
{
    qDebug() << "CloudApi::opticalCharacterRecognition" << imagePath << sourceLanguage;

    QUrl url = QUrl(QString(API_OCR));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
    request.setRawHeader(QByteArray("Ocp-Apim-Subscription-Key"), QByteArray(AZURE_COMPUTER_VISION_KEY));
    QUrlQuery urlQuery = QUrlQuery();
    urlQuery.addQueryItem("language", sourceLanguage);
    urlQuery.addQueryItem("detectOrientation", "true");
    url.setQuery(urlQuery);

    QFile *file = new QFile(imagePath);
    file->open(QIODevice::ReadOnly);
    QByteArray rawImage = file->readAll();
    file->close();
    file->deleteLater();

    QNetworkReply *reply = networkAccessManager->post(request, rawImage);
    reply->setObjectName(imagePath);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleOcrUploadError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleOcrUploadFinished()));
    connect(reply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(handleOcrUploadProgress(qint64,qint64)));
}

void CloudApi::translate(const QString &text, const QString &targetLanguage)
{
    qDebug() << "CloudApi::translate" << text << targetLanguage;

    QUrl url = QUrl(QString(API_TRANSLATE));
    QUrlQuery urlQuery = QUrlQuery();
    urlQuery.addQueryItem("api-version", "3.0");
    urlQuery.addQueryItem("to", targetLanguage);
    url.setQuery(urlQuery);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader(QByteArray("Ocp-Apim-Subscription-Key"), QByteArray(AZURE_TRANSLATOR_TEXT_KEY));

    QJsonObject jsonText;
    jsonText.insert("Text", text);
    QJsonArray jsonArray;
    jsonArray.append(jsonText);

    QJsonDocument requestDocument(jsonArray);
    qDebug() << requestDocument.toJson();
    QByteArray jsonAsByteArray = requestDocument.toJson();

    QNetworkReply *reply = networkAccessManager->post(request, jsonAsByteArray);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleTranslateError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleTranslateFinished()));
}

void CloudApi::handleOcrUploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    qDebug() << "CloudApi::handleOcrUploadProgress" << bytesSent << bytesTotal;
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    emit ocrUploadStatus(reply->objectName(), bytesSent, bytesTotal);
}

void CloudApi::handleOcrUploadError(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    qWarning() << "CloudApi::handleOcrUploadError:" << (int)error << reply->errorString() << reply->readAll();
    emit ocrUploadError(reply->objectName(), reply->errorString());
}

void CloudApi::handleOcrUploadFinished()
{
    qDebug() << "CloudApi::handleOcrUploadFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QJsonDocument jsonDocument = QJsonDocument::fromJson(reply->readAll());
    if (jsonDocument.isObject()) {
        emit ocrUploadSuccessful(reply->objectName(), jsonDocument.object());
    } else {
        emit ocrUploadError(reply->objectName(), "Wunderfitz couldn't understand Azure's response!");
    }
}

void CloudApi::handleTranslateError(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    qWarning() << "CloudApi::handleTranslateError:" << (int)error << reply->errorString() << reply->readAll();
    emit translateError(reply->errorString());
}

void CloudApi::handleTranslateFinished()
{
    qDebug() << "CloudApi::handleTranslateFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QJsonDocument jsonDocument = QJsonDocument::fromJson(reply->readAll());
    qDebug() << jsonDocument.toJson();
    if (jsonDocument.isArray()) {
        emit translateSuccessful(jsonDocument.array());
    } else {
        emit translateError("Wunderfitz couldn't understand Azure's response!");
    }
}
