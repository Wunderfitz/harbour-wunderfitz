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

#ifndef CLOUDAPI_H
#define CLOUDAPI_H

#include <QObject>
#include <QUrl>
#include <QUrlQuery>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QVariantMap>
#include <QFile>
#include <QSettings>

const char API_COMPUTER_VISION_ENDPOINT_PATH[] = "/vision/v1.0/ocr";
const char API_TRANSLATOR_TEXT_ENDPOINT_PATH[] = "/translate";

class Curiosity;

class CloudApi : public QObject
{
    Q_OBJECT
public:
    explicit CloudApi(QNetworkAccessManager *manager, Curiosity *parent = 0);

    Q_INVOKABLE void opticalCharacterRecognition(const QString &imagePath, const QString &sourceLanguage);
    Q_INVOKABLE void translate(const QString &text, const QString &targetLanguage);

signals:
    void ocrUploadSuccessful(const QString &fileName, const QJsonObject &result);
    void ocrUploadError(const QString &fileName, const QString &errorMessage);
    void ocrUploadStatus(const QString &fileName, qint64 bytesSent, qint64 bytesTotal);
    void translateSuccessful(const QJsonArray &result);
    void translateError(const QString &errorMessage);

public slots:
    void handleOcrUploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void handleOcrUploadError(QNetworkReply::NetworkError error);
    void handleOcrUploadFinished();
    void handleTranslateError(QNetworkReply::NetworkError error);
    void handleTranslateFinished();

private:

    QNetworkAccessManager *networkAccessManager;
    QSettings settings;

    Curiosity *curiosity;
};

#endif // CLOUDAPI_H
