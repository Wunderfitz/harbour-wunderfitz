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

#ifndef CURIOSITY_H
#define CURIOSITY_H

#include <QObject>
#include <QSettings>
#include <QNetworkAccessManager>

// Settings keys
const char SETTINGS_SOURCE_LANGUAGE[] = "settings/sourceLanguage";
const char SETTINGS_TARGET_LANGUAGE[] = "settings/targetLanguage";
const char SETTINGS_USE_CLOUD[] = "settings/useCloud";
const char SETTINGS_COMPUTER_VISION_KEY[] = "settings/computerVisionKey";
const char SETTINGS_COMPUTER_VISION_ENDPOINT[] = "settings/computerVisionEndpoint";
const char SETTINGS_TRANSLATOR_TEXT_KEY[] = "settings/translatorTextKey";
const char SETTINGS_TRANSLATOR_TEXT_ENDPOINT[] = "settings/translatorTextEndpoint";

// Settings defaults
const char DEFAULT_COMPUTER_VISION_ENDPOINT[] = "https://westeurope.api.cognitive.microsoft.com";
const char DEFAULT_TRANSLATOR_TEXT_ENDPOINT[] = "https://api.cognitive.microsofttranslator.com";

class CloudApi;

class Curiosity : public QObject
{
    Q_OBJECT
public:
    explicit Curiosity(QObject *parent = 0);
    Q_INVOKABLE QString getTemporaryDirectoryPath();
    Q_INVOKABLE void removeTemporaryFiles();
    Q_INVOKABLE void captureRequested(const int &orientation, const int &viewfinderDimension, const int &offset);
    Q_INVOKABLE void captureCompleted(const QString &path);
    Q_INVOKABLE QString getSourceLanguage();
    Q_INVOKABLE void setSourceLanguage(const QString &sourceLanguage);
    Q_INVOKABLE QString getTargetLanguage();
    Q_INVOKABLE void setTargetLanguage(const QString &targetLanguage);
    Q_INVOKABLE bool getUseCloud();
    Q_INVOKABLE void setUseCloud(const bool &useCloud);
    Q_INVOKABLE QString getTranslatedText();
    Q_INVOKABLE void setComputerVisionKey(const QString &computerVisionKey);
    Q_INVOKABLE QString getComputerVisionKey();
    Q_INVOKABLE void setComputerVisionEndpoint(const QString &computerVisionEndpoint);
    Q_INVOKABLE QString getComputerVisionEndpoint();
    Q_INVOKABLE void setTranslatorTextKey(const QString &translatorTextKey);
    Q_INVOKABLE QString getTranslatorTextKey();
    Q_INVOKABLE void setTranslatorTextEndpoint(const QString &translatorTextEndpoint);
    Q_INVOKABLE QString getTranslatorTextEndpoint();

    CloudApi *getCloudApi();

signals:
    void translationSuccessful(const QString &text);
    void translationError(const QString &errorMessage);
    void ocrProgress(const int &percentCompleted);
    void ocrError(const QString &errorMessage);
    void ocrSuccessful();

public slots:
    void handleTranslationSuccessful(const QJsonArray &result);
    void handleTranslationError(const QString &errorMessage);
    void handleOcrProcessingSuccessful(const QString &fileName, const QJsonObject &result);    
    void handleOcrProcessingError(const QString &fileName, const QString &errorMessage);
    void handleOcrProcessingStatus(const QString &fileName, qint64 bytesSent, qint64 bytesTotal);

private:
    int captureOrientation;
    int captureOffset;
    int captureViewfinderDimension;
    QString capturePath;
    QString translatedText;
    QSettings settings;
    CloudApi *cloudApi;

    QNetworkAccessManager *networkAccessManager;

    void processCapture();

};

#endif // CURIOSITY_H
