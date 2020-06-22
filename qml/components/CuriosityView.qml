/*
    Copyright (C) 2016-19 Sebastian J. Wolf
                     2020 Mirian Margiani

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

import QtQuick 2.0
import QtMultimedia 5.6
import Sailfish.Silica 1.0

Item {
    property bool isProcessing: false

    property int orientation: pageStack.currentOrientation
    property bool isLandscape: orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted
    property bool isPortrait: orientation === Orientation.Portrait || orientation === Orientation.PortraitInverted

    Component {
        id: viewfinderComponent

        Item {
            Connections {
                target: curiosity
                onTranslationSuccessful: {
                    isProcessing = false;
                    previewImage.visible = false;
                    pageStack.push(Qt.resolvedUrl("../pages/TextPage.qml"), {"original": curiosity.getTranslatedText(), "translation": text});
                }
                onTranslationError: {
                    isProcessing = false;
                    previewImage.visible = false;
                    titleNotification.show(errorMessage);
                }
                onOcrError: {
                    isProcessing = false;
                    previewImage.visible = false;
                    titleNotification.show(errorMessage);
                }
            }

            anchors.fill: parent

            Camera {
                id: camera
                deviceId: QtMultimedia.defaultCamera.deviceId
                imageCapture {
                    onImageSaved: {
                        console.log("Image captured");
                        curiosity.captureCompleted(path);
                        previewImage.source = path;
                        previewImage.visible = true;
                    }
                }
                onCameraStateChanged: {
                    if (cameraState == Camera.ActiveState) {
                        console.log("We are loaded!");
                    }
                }
            }

            Label {
                wrapMode: Text.Wrap
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - ( 2 * Theme.horizontalPageMargin )
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("No camera available")
                font.pixelSize: Theme.fontSizeSmall
                visible: camera.availability !== Camera.Available
            }

            VideoOutput {
                id: videoOutput
                width: parent.width
                height: parent.height
                anchors.top: parent.top
                anchors.left: parent.left
                source: camera
                fillMode: VideoOutput.PreserveAspectCrop
                visible: camera.availability === Camera.Available && !isProcessing
                rotation: (orientation === Orientation.Portrait ? 0 :
                              (orientation === Orientation.Landscape ? -90 :
                                  (orientation === Orientation.PortraitInverted ? 180 : -270)))
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        camera.searchAndLock();
                    }
                }

                function adjustOutputMargin() {
                    if (isLandscape) {
                        anchors.topMargin = - (( height - width ) / 2 );
                        anchors.leftMargin = navigationColumn.width / 2
                    } else {
                        anchors.topMargin = 0
                        anchors.leftMargin = 0;
                    }
                }

                onSourceRectChanged: {
                    console.log(parent.width + "," + parent.height);
                    console.log(sourceRect.width + "," + sourceRect.height);
                    var scalingFactor = 1;
                    if (isPortrait) {
                        // Maximize on width
                        if (sourceRect.width > sourceRect.height) {
                            scalingFactor = sourceRect.height / parent.width;
                        } else {
                            scalingFactor = sourceRect.width / parent.width;
                        }
                    } else {
                        // Maximize on height
                        if (sourceRect.width > sourceRect.height) {
                            scalingFactor = sourceRect.height / parent.height;
                        } else {
                            scalingFactor = sourceRect.width / parent.height;
                        }
                    }
                    console.log(scalingFactor);

                    width = sourceRect.width / scalingFactor;
                    height = sourceRect.height / scalingFactor;
                    adjustOutputMargin();
                }
                onRotationChanged: {
                    adjustOutputMargin();
                }
            }

            Slider {
                id: zoomSlider
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingMedium
                anchors.left: parent.left
                width: isPortrait ? videoOutput.width : parent.width
                minimumValue: 1
                maximumValue: 100
                visible: !isProcessing
                onValueChanged: {
                    camera.digitalZoom = value;
                }
            }

            IconButton {
                id: snapshotButton
                icon.source: "image://theme/icon-m-dot"
                anchors.left: parent.left
                anchors.leftMargin: isPortrait ? ( videoOutput.width / 2 ) - ( width / 2 ) : parent.width - width - Theme.horizontalPageMargin
                anchors.bottom: parent.bottom // isPortrait ? videoOutput.bottom : parent.bottom
                anchors.bottomMargin: Theme.horizontalPageMargin
                visible: !isProcessing
                onClicked: {
                    camera.imageCapture.captureToLocation(curiosity.getTemporaryDirectoryPath());
                    snapshotRectangle.visible = true;
                    snapshotRectangle.opacity = 1;
                    snapshotTimer.start();
                    isProcessing = true;
                    wunderfitzProcessingIndicator.informationText = qsTr("Processing image...");
                    curiosity.captureRequested(orientation, videoOutput.height, isLandscape ? navigationColumn.width : navigationRow.height );
                }
            }

            Image {
                id: previewImage
                anchors.fill: parent
                asynchronous: true
                visible: false
                fillMode: Image.PreserveAspectFit
            }

            Connections {
                target: curiosity
                onOcrProgress: {
                    wunderfitzProcessingIndicator.informationText = qsTr("Uploading image, %1\% completed...").arg(percentCompleted);
                }
                onOcrSuccessful: {
                    wunderfitzProcessingIndicator.informationText = qsTr("Translating text...");
                }
            }

            LoadingIndicator {
                id: wunderfitzProcessingIndicator
                visible: isProcessing
                Behavior on opacity { NumberAnimation {} }
                opacity: isProcessing ? 1 : 0
            }

            Rectangle {
                id: snapshotRectangle
                anchors.fill: parent
                color: "white"
                visible: false
                opacity: 0
                Behavior on opacity { NumberAnimation {} }
            }

            Timer {
                id: snapshotTimer
                repeat: false
                interval: 125
                onTriggered: {
                    snapshotRectangle.opacity = 0;
                    snapshotRectangle.visible = false;
                }
            }
        }
    }

    Timer {
        id: cameraLoaderTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (pageStack.currentPage.objectName !== mainPageName) {
                viewfinderLoader.active = false;
            } else {
                viewfinderLoader.active = (currentTabId === 1 && Qt.application.state === Qt.ApplicationActive);
            }
        }
    }

    Loader {
        id: viewfinderLoader
        active: currentTabId === 1 && Qt.application.state === Qt.ApplicationActive
        width: parent.width
        height: parent.height
        sourceComponent: viewfinderComponent
        onActiveChanged: {
            if (active) {
                console.log("Camera loaded");
            } else {
                console.log("Camera unloaded")
            }
        }
    }

    ComboBox {
        property var allLanguageCodes: [
            // order has to be the same as in the menu below
            "unk", "zh-Hans", "zh-Hant", "cs", "da", "nl", "en", "fi", "fr", "de",
            "el", "hu", "it", "ja", "ko", "nb", "pl", "pt", "ru", "es", "sv", "tr",
            "ar", "ro", "sr-Cyrl", "sr-Latn", "sk"
        ]

        Component.onCompleted: {
            var code = curiosity.getSourceLanguage();
            currentIndex = allLanguageCodes.indexOf(code);
        }

        anchors.bottom: targetLanguageBox.top
        anchors.horizontalCenter: parent.horizontalCenter
        label: qsTr("Source Language")
        visible: !isProcessing && viewfinderLoader.active
        menu: ContextMenu {
            Repeater {
                model: [
                    qsTr("Auto-Detect"), qsTr("Chinese-Simplified"), qsTr("Chinese-Traditional"), qsTr("Czech"),
                    qsTr("Danish"), qsTr("Dutch"), qsTr("English"), qsTr("Finnish"), qsTr("French"), qsTr("German"), qsTr("Greek"),
                    qsTr("Hungarian"), qsTr("Italian"), qsTr("Japanese"), qsTr("Korean"), qsTr("Norwegian"), qsTr("Polish"),
                    qsTr("Portuguese"), qsTr("Russian"), qsTr("Spanish"), qsTr("Swedish"), qsTr("Turkish"), qsTr("Arabic"),
                    qsTr("Romanian"), qsTr("Serbian-Cyrillic"), qsTr("Serbian-Latin"), qsTr("Slovak")
                ]
                delegate: MenuItem { text: modelData }
            }
        }
        onCurrentIndexChanged: {
            if (currentIndex >= allLanguageCodes.length) {
                console.log("error: requested source language index is out of range", currentIndex, allLanguageCodes);
                return;
            } else if (currentIndex < 0) {
                return;
            } else {
                curiosity.setSourceLanguage(allLanguageCodes[currentIndex]);
            }
        }
    }

    ComboBox {
        id: targetLanguageBox
        property var allLanguageCodes: [
            // order has to be the same as in the menu below
            "en", "af", "ar", "bg", "bn", "bs", "ca", "cs", "cy", "da", "de",
            "el", "es", "et", "fa", "fi", "fil", "fj", "fr", "he", "hi", "hr",
            "ht", "hu", "id", "is", "it", "ja", "ko", "lt", "lv", "mg", "ms",
            "mt", "mww", "nb", "nl", "otq", "pl", "pt", "ro", "ru", "sk", "sl",
            "sm", "sr-Cyrl", "sr-Latn", "sv", "sw", "ta", "th", "tlh", "to",
            "tr", "ty", "uk", "ur", "vi", "yua", "yue", "zh-Hans", "zh-Hant"
        ]

        Component.onCompleted: {
            var code = curiosity.getSourceLanguage();
            currentIndex = allLanguageCodes.indexOf(code);
        }

        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.iconSizeMedium + Theme.horizontalPageMargin + ( 2 * Theme.paddingLarge )
        anchors.horizontalCenter: parent.horizontalCenter
        label: qsTr("Target Language")
        visible: !isProcessing && viewfinderLoader.active
        menu: ContextMenu {
            Repeater {
                model: [
                    qsTr("English"), qsTr("Afrikaans"), qsTr("Arabic"), qsTr("Bulgarian"), qsTr("Bangla"),
                    qsTr("Bosnian"), qsTr("Catalan"), qsTr("Czech"), qsTr("Welsh"), qsTr("Danish"),
                    qsTr("German"), qsTr("Greek"), qsTr("Spanish"), qsTr("Estonian"), qsTr("Persian"),
                    qsTr("Finnish"), qsTr("Filipino"), qsTr("Fijian"), qsTr("French"), qsTr("Hebrew"),
                    qsTr("Hindi"), qsTr("Croatian"), qsTr("Haitian Creole"), qsTr("Hungarian"), qsTr("Indonesian"),
                    qsTr("Icelandic"), qsTr("Italian"), qsTr("Japanese"), qsTr("Korean"), qsTr("Lithuanian"),
                    qsTr("Latvian"), qsTr("Malagasy"), qsTr("Malay"), qsTr("Maltese"), qsTr("Hmong Daw"),
                    qsTr("Norwegian"), qsTr("Dutch"), qsTr("Querétaro Otomi"), qsTr("Polish"), qsTr("Portuguese"),
                    qsTr("Romanian"), qsTr("Russian"), qsTr("Slovak"), qsTr("Slovenian"), qsTr("Samoan"),
                    qsTr("Serbian-Cyrillic"), qsTr("Serbian-Latin"), qsTr("Swedish"), qsTr("Kiswahili"), qsTr("Tamil"),
                    qsTr("Thai"), qsTr("Klingon"), qsTr("Tongan"), qsTr("Turkish"), qsTr("Tahitian"), qsTr("Ukrainian"),
                    qsTr("Urdu"), qsTr("Vietnamese"), qsTr("Yucatec Maya"), qsTr("Cantonese-Traditional"),
                    qsTr("Chinese-Simplified"), qsTr("Chinese-Traditional")
                ]
                delegate: MenuItem { text: modelData }
            }
        }
        onCurrentIndexChanged: {
            if (currentIndex >= allLanguageCodes.length) {
                console.log("error: requested target language index is out of range", currentIndex, allLanguageCodes);
                return;
            } else if (currentIndex < 0) {
                return;
            } else {
                curiosity.setTargetLanguage(allLanguageCodes[currentIndex]);
            }
        }
    }

    Rectangle {
        id: cloudWarningBackground
        anchors.fill: parent
        color: Theme.overlayBackgroundColor
        opacity: Theme.opacityOverlay
        visible: cloudWarningFlickable.visible || settingsWarningFlickable.visible
    }

    SilicaFlickable {
        id: cloudWarningFlickable
        contentHeight: warningColumn.height
        anchors.fill: parent
        visible: !curiosity.getUseCloud()

        Column {
            id: warningColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: warningHeader
                title: qsTr("Cloud and Beta Warning")
            }

            Image {
                id: warningImage
                source: "image://theme/icon-l-attention"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                fillMode: Image.PreserveAspectFit
                width: Theme.iconSizeLarge
                height: Theme.iconSizeLarge
            }

            Text {
                id: textContentCloud
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                linkColor: Theme.highlightColor
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                text: qsTr("The Curiosity feature - taking a picture and automatically translating all recognized text on it - uses other people's computers (aka \"Cloud\") to work. So, your picture is uploaded to another server, analyzed and the information is sent back to this app. So, be cautious if you take pictures of private or confidential data! The Cloud provider is Microsoft Azure. (You see the irony of having Microsoft services running on Sailfish OS ;) ?) By using this service you accept")

                onLinkActivated: Qt.openUrlExternally(link);
            }

            Text {
                text: qsTr("<a href=\"https://azure.microsoft.com/support/legal/\">The Microsoft Azure terms of service and privacy statement</a>")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width - 2 * Theme.horizontalPageMargin
                font.pixelSize: Theme.fontSizeSmall
                linkColor: Theme.highlightColor
                wrapMode: Text.Wrap

                onLinkActivated: Qt.openUrlExternally(link);
            }

            Text {
                id: textContentBeta
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                linkColor: Theme.highlightColor
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                text: qsTr("Moreover, the Curiosity feature is beta! This means that there is no guarantee that it works as you wish or that it will continue working forever in this or a future version of Wunderfitz. It may cease to work without any prior warning...")
            }

            Button {
                text: qsTr("Accept")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: {
                    curiosity.setUseCloud(true);
                    cloudWarningBackground.visible = false;
                    cloudWarningFlickable.visible = false;
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width  - ( 2 * Theme.horizontalPageMargin )
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            VerticalScrollDecorator {}
        }

    }

    SilicaFlickable {
        id: settingsWarningFlickable
        contentHeight: settingsWarningColumn.height
        anchors.fill: parent
        visible: !cloudWarningFlickable.visible && ( curiosity.getTranslatorTextKey() === "" || curiosity.getComputerVisionKey() === "" )
        onVisibleChanged: {
            cloudWarningBackground.visible = cloudWarningFlickable.visible || settingsWarningFlickable.visible
        }

        Column {
            id: settingsWarningColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: settingsWarningHeader
                title: qsTr("Azure API Keys not set")
            }

            Image {
                id: settingsWarningImage
                source: "image://theme/icon-l-attention"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                fillMode: Image.PreserveAspectFit
                width: Theme.iconSizeLarge
                height: Theme.iconSizeLarge
            }

            Text {
                id: textSettingsWarning
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                linkColor: Theme.highlightColor
                wrapMode: Text.Wrap
                textFormat: Text.StyledText
                text: qsTr("The Curiosity feature - taking a picture and automatically translating all recognized text on it - needs Microsoft Azure API keys to work. Please obtain API keys for the <a href=\"https://azure.microsoft.com/en-gb/services/cognitive-services/computer-vision/\">Computer Vision</a> and the <a href=\"https://azure.microsoft.com/en-gb/services/cognitive-services/translator-text-api/\">Translator Text</a> API, enter them on the settings page and have fun!")

                onLinkActivated: Qt.openUrlExternally(link);
            }

            Button {
                text: qsTr("Open Settings")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../pages/SettingsPage.qml"));
                }
            }

            Button {
                text: qsTr("Reload")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: {
                    settingsWarningFlickable.visible = !cloudWarningFlickable.visible && ( curiosity.getTranslatorTextKey() === "" || curiosity.getComputerVisionKey() === "" )
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width  - ( 2 * Theme.horizontalPageMargin )
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            VerticalScrollDecorator {}
        }
    }
}
