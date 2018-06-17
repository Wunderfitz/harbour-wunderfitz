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

Curiosity::Curiosity(QObject *parent) : QObject(parent)
{
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
    finalImage.save(this->capturePath);
}
