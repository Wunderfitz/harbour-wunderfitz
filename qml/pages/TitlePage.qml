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

import QtQuick 2.0
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import "../components"

Page {
    id: titlePage
    allowedOrientations: Orientation.All

    property int activeTabId: 0;
    property bool interactionHintDisplayed : dictionaryModel.isInteractionHintDisplayed()

    function toggleBusyIndicator() {
        busyIndicator.running = heinzelnisseModel.isSearchInProgress()
        busyIndicatorColumn.opacity = heinzelnisseModel.isSearchInProgress() ? 1 : 0
        listView.opacity = heinzelnisseModel.isSearchInProgress() ? 0 : 1
        noResultsColumn.opacity = heinzelnisseModel.isEmpty() ? 1 : 0
    }

    function getNavigationRowSize() {
        return Theme.iconSizeMedium + Theme.fontSizeMedium + Theme.paddingMedium;
    }

    function openTab(tabId) {

        activeTabId = tabId;

        switch (tabId) {
        case 0:
            dictionariesButtonPortrait.isActive = true;
            dictionariesButtonLandscape.isActive = true;
            wunderfitzButtonPortrait.isActive = false;
            wunderfitzButtonLandscape.isActive = false;
            break;
        case 1:
            dictionariesButtonPortrait.isActive = false;
            dictionariesButtonLandscape.isActive = false;
            wunderfitzButtonPortrait.isActive = true;
            wunderfitzButtonLandscape.isActive = true;
            break;
        default:
            console.log("Some strange navigation happened!")
        }
    }

    function handleDictionariesClicked() {
        if (titlePage.activeTabId === 0) {
            homeListView.scrollToTop();
        } else {
            viewsSlideshow.opacity = 0;
            slideshowVisibleTimer.goToTab(0);
            openTab(0);
        }
    }

    function handleWunderfitzClicked() {
        if (titlePage.activeTabId === 1) {
            mentionsListView.scrollToTop();
        } else {
            viewsSlideshow.opacity = 0;
            slideshowVisibleTimer.goToTab(1);
            openTab(1);
        }
    }

    Component.onCompleted: {
        openTab(0);
    }

    AppNotification {
        id: titleNotification
    }

    Timer {
        id: searchTimer
        interval: 800
        running: false
        repeat: false
        onTriggered: {
            if (searchField.text === "") {
                searchField.focus = true;
            }
            heinzelnisseModel.search(searchField.text)
        }
    }

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: parent.height
        contentWidth: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTr("About Wunderfitz")
                onClicked: pageStack.push(aboutPage)
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("../pages/SettingsPage.qml"));
            }

            MenuItem {
                visible: titlePage.activeTabId === 0
                text: qsTr("Dictionaries")
                onClicked: pageStack.push(dictionariesPage)
            }
        }


        Column {
            id: overviewColumn
            Behavior on opacity { NumberAnimation {} }
            width: parent.width
            height: parent.height

            Row {
                id: overviewRow
                width: parent.width
                height: parent.height - ( titlePage.isLandscape ? 0 : getNavigationRowSize() )
                spacing: Theme.paddingSmall

                VisualItemModel {
                    id: viewsModel

                    Item {
                        id: dictionariesView
                        width: viewsSlideshow.width
                        height: viewsSlideshow.height

                        Timer {
                            interval: 4000
                            running: titlePage.interactionHintDisplayed
                            repeat: false
                            onTriggered: {
                                interactionHint.opacity = 0
                                interactionHintLabel.opacity = 0
                                searchColumn.opacity = 1
                            }
                        }

                        TouchInteractionHint {
                            id: interactionHint
                            running: titlePage.interactionHintDisplayed
                            interactionMode: TouchInteraction.Pull
                            direction: TouchInteraction.Down
                            Behavior on opacity { NumberAnimation {} }
                            opacity: titlePage.interactionHintDisplayed
                        }

                        InteractionHintLabel {
                            id: interactionHintLabel
                            text: qsTr("Pull down the menu to import and change your dictionaries")
                            invert: true
                            Behavior on opacity { NumberAnimation {} }
                            opacity: titlePage.interactionHintDisplayed
                        }

                        Column {
                            x: listView.x
                            y: listView.y
                            height: titlePage.height - header.height - searchField.height - ( 2 * Theme.paddingLarge ) - ( titlePage.isLandscape ? 0 : getNavigationRowSize() )
                            width: parent.width

                            id: busyIndicatorColumn
                            Behavior on opacity { NumberAnimation {} }
                            opacity: heinzelnisseModel.isSearchInProgress() ? 1 : 0

                            BusyIndicator {
                                id: busyIndicator
                                anchors.horizontalCenter: parent.horizontalCenter
                                running: heinzelnisseModel.isSearchInProgress()
                                size: BusyIndicatorSize.Medium
                            }

                            Label {
                                id: busyIndicatorLabel
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: qsTr("Searching...")
                                color: Theme.highlightColor
                            }

                            Connections {
                                target: heinzelnisseModel
                                onSearchStatusChanged: {
                                    toggleBusyIndicator()
                                }
                            }
                        }

                        Column {
                            x: listView.x
                            y: listView.y
                            height: titlePage.height - header.height - searchField.height - ( 2 * Theme.paddingLarge ) - ( titlePage.isLandscape ? 0 : getNavigationRowSize() )
                            width: parent.width

                            id: noResultsColumn
                            Behavior on opacity { NumberAnimation {} }
                            opacity: heinzelnisseModel.isEmpty() ? 1 : 0

                            Label {
                                id: noResultsLabel
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: qsTr("No results found")
                                color: Theme.secondaryColor
                            }
                        }

                        Column {
                            id: searchColumn

                            Behavior on opacity { NumberAnimation {} }
                            opacity: titlePage.interactionHintDisplayed ? 0 : 1

                            width: parent.width

                            SilicaFlickable {
                                id: header
                                width: parent.width
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: headerDictionaryBox.height + Theme.paddingMedium

                                ComboBox {
                                    id: headerDictionaryBox
                                    y: Theme.paddingSmall
                                    currentIndex: dictionaryModel.getSelectedDictionaryIndex()
                                    label: qsTr("Active Dictionary:")
                                    width: parent.width
                                    menu: ContextMenu {
                                        Repeater {
                                            model: dictionaryModel
                                            delegate: MenuItem {
                                                text: display.languages
                                            }
                                        }
                                        onActivated: {
                                            dictionaryModel.selectDictionary(index);
                                        }
                                    }

                                    Connections {
                                        // If dictionary is changed from DictionariesPage, we have to update index and search.
                                        target: dictionaryModel
                                        onDictionaryChanged: {
                                            headerDictionaryBox.currentIndex = dictionaryModel.getSelectedDictionaryIndex()
                                            heinzelnisseModel.search(searchField.text)
                                        }
                                    }
                                }

                                Separator {
                                    id: headerSeparator
                                    anchors.top: headerDictionaryBox.bottom
                                    width: parent.width
                                    color: Theme.primaryColor
                                    horizontalAlignment: Qt.AlignHCenter
                                }

                            }

                            SearchField {
                                id: searchField
                                width: parent.width
                                placeholderText: qsTr("Search in dictionary...")
                                focus: true

                                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                                EnterKey.onClicked: focus = false

                                inputMethodHints: Qt.ImhNone

                                onTextChanged: {
                                    searchTimer.stop()
                                    searchTimer.start()
                                }
                            }

                            SilicaListView {

                                id: listView

                                height: titlePage.height - header.height - searchField.height - ( titlePage.isLandscape ? 0 : getNavigationRowSize() )
                                width: parent.width
                                anchors.left: parent.left
                                anchors.right: parent.right

                                Behavior on opacity { NumberAnimation {} }
                                opacity: heinzelnisseModel.isSearchInProgress() ? 0 : 1

                                clip: true

                                model: heinzelnisseModel

                                delegate: ListItem {
                                    contentHeight: wordRow.height + Theme.paddingMedium
                                    contentWidth: parent.width

                                    menu: ContextMenu {
                                        MenuItem {
                                            text: qsTr("Copy to clipboard")
                                            onClicked: {
                                                Clipboard.text = display.clipboardText
                                            }
                                        }
                                        MenuItem {
                                            text: qsTr("Search for '%1'").arg(display.wordLeft)
                                            onClicked: {
                                                searchField.text = display.wordLeft
                                            }
                                        }
                                        MenuItem {
                                            text: qsTr("Search for '%1'").arg(display.wordRight)
                                            onClicked: {
                                                searchField.text = display.wordRight
                                            }
                                        }
                                    }

                                    Row {
                                        id: wordRow
                                        width: parent.width
                                        spacing: Theme.paddingMedium
                                        anchors.verticalCenter: parent.verticalCenter
                                        Column {
                                            id: columnLeft
                                            width: parent.width / 2 - ( 2 * Theme.paddingMedium )
                                            Label {
                                                color: Theme.primaryColor
                                                width: parent.width
                                                font.pixelSize: Theme.fontSizeSmall
                                                x: Theme.horizontalPageMargin
                                                wrapMode: Text.Wrap
                                                truncationMode: TruncationMode.Fade
                                                text: display.wordLeft + " " + display.genderLeft
                                            }

                                            Label {
                                                color: Theme.primaryColor
                                                width: parent.width
                                                font.pixelSize: Theme.fontSizeExtraSmall
                                                x: Theme.horizontalPageMargin
                                                wrapMode: Text.Wrap
                                                truncationMode: TruncationMode.Fade
                                                text: display.otherLeft
                                            }
                                        }
                                        Column {
                                            id: columnRight
                                            width: parent.width / 2 - ( 2 * Theme.paddingMedium )
                                            Label {
                                                width: parent.width
                                                color: Theme.highlightColor
                                                font.pixelSize: Theme.fontSizeSmall
                                                x: Theme.horizontalPageMargin
                                                wrapMode: Text.Wrap
                                                truncationMode: TruncationMode.Fade
                                                text: display.wordRight + " " + display.genderRight
                                            }
                                            Label {
                                                width: parent.width
                                                color: Theme.highlightColor
                                                font.pixelSize: Theme.fontSizeExtraSmall
                                                x: Theme.horizontalPageMargin
                                                wrapMode: Text.Wrap
                                                truncationMode: TruncationMode.Fade
                                                text: display.otherRight
                                            }
                                        }
                                    }

                                }

                                VerticalScrollDecorator {}

                            }

                        }


                    }

                    Item {
                        id: wunderfitzView
                        width: viewsSlideshow.width
                        height: viewsSlideshow.height

                        property bool isProcessing: false;

                        Component {
                            id: viewfinderComponent

                            Item {

                                Connections {
                                    target: curiosity
                                    onTranslationSuccessful: {
                                        wunderfitzView.isProcessing = false;
                                        previewImage.visible = false;
                                        pageStack.push(Qt.resolvedUrl("../pages/TextPage.qml"), {"original": curiosity.getTranslatedText(), "translation": text});
                                    }
                                    onTranslationError: {
                                        wunderfitzView.isProcessing = false;
                                        previewImage.visible = false;
                                        titleNotification.show(errorMessage);
                                    }
                                    onOcrError: {
                                        wunderfitzView.isProcessing = false;
                                        previewImage.visible = false;
                                        titleNotification.show(errorMessage);
                                    }
                                }

                                anchors.fill: parent

                                Camera {
                                    id: camera
                                    deviceId: QtMultimedia.defaultCamera.deviceId
                                    imageCapture.onImageSaved: {
                                        console.log("Image captured");
                                        curiosity.captureCompleted(path);
                                        previewImage.source = path;
                                        previewImage.visible = true;
                                    }
                                    onError: {
                                        wunderfitzView.isProcessing = false;
                                        titleNotification.show("Error occurred: " + errorString);
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
                                    anchors {
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                }

                                VideoOutput {
                                    id: videoOutput
                                    width: parent.width
                                    height: parent.height
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    source: camera
                                    fillMode: VideoOutput.PreserveAspectCrop
                                    visible: camera.availability === Camera.Available && !wunderfitzView.isProcessing
                                    rotation: ( titlePage.orientation === Orientation.Portrait ? 0 : ( titlePage.orientation === Orientation.Landscape ? -90 : ( titlePage.orientation === Orientation.PortraitInverted ? 180 : -270 ) ) )
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            camera.searchAndLock();
                                        }
                                    }
                                    function adjustOutputMargin() {
                                        if (titlePage.isLandscape) {
                                            anchors.topMargin = - (( height - width ) / 2 );
                                            anchors.leftMargin = navigationColumn.width / 2
                                        } else {
                                            anchors.topMargin = - navigationRow.height
                                            anchors.leftMargin = 0;
                                        }
                                    }

                                    onSourceRectChanged: {
                                        console.log(parent.width + "," + parent.height);
                                        console.log(sourceRect.width + "," + sourceRect.height);
                                        var scalingFactor = 1;
                                        if (titlePage.isPortrait) {
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
                                    width: titlePage.isPortrait ? videoOutput.width : parent.width
                                    minimumValue: 1
                                    maximumValue: 100
                                    visible: !wunderfitzView.isProcessing
                                    onValueChanged: {
                                        camera.digitalZoom = value;
                                    }
                                }

                                IconButton {
                                    id: snapshotButton
                                    icon.source: "image://theme/icon-m-dot"
                                    anchors.left: parent.left
                                    anchors.leftMargin: titlePage.isPortrait ? ( videoOutput.width / 2 ) - ( width / 2 ) : parent.width - width - Theme.horizontalPageMargin
                                    anchors.bottom: parent.bottom // titlePage.isPortrait ? videoOutput.bottom : parent.bottom
                                    anchors.bottomMargin: Theme.horizontalPageMargin
                                    visible: !wunderfitzView.isProcessing
                                    onClicked: {
                                        camera.imageCapture.captureToLocation(curiosity.getTemporaryDirectoryPath());
                                        snapshotRectangle.visible = true;
                                        snapshotRectangle.opacity = 1;
                                        snapshotTimer.start();
                                        wunderfitzView.isProcessing = true;
                                        wunderfitzProcessingIndicator.informationText = qsTr("Processing image...");
                                        curiosity.captureRequested(titlePage.orientation, videoOutput.height, titlePage.isLandscape ? navigationColumn.width : navigationRow.height );
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
                                    visible: wunderfitzView.isProcessing
                                    Behavior on opacity { NumberAnimation {} }
                                    opacity: wunderfitzView.isProcessing ? 1 : 0
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
                                if (pageStack.currentPage !== titlePage) {
                                    viewfinderLoader.active = false;
                                } else {
                                    viewfinderLoader.active = ( titlePage.activeTabId === 1 && Qt.application.state === Qt.ApplicationActive);
                                }
                            }
                        }

                        Loader {
                            id: viewfinderLoader
                            active: titlePage.activeTabId === 1 && Qt.application.state === Qt.ApplicationActive
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
                            Component.onCompleted: {
                                var languageCode = curiosity.getSourceLanguage();
                                switch (languageCode) {
                                    case "unk": sourceLanguageBox.currentIndex = 0; break;
                                    case "zh-Hans": sourceLanguageBox.currentIndex = 1; break;
                                    case "zh-Hant": sourceLanguageBox.currentIndex = 2; break;
                                    case "cs": sourceLanguageBox.currentIndex = 3; break;
                                    case "da": sourceLanguageBox.currentIndex = 4; break;
                                    case "nl": sourceLanguageBox.currentIndex = 5; break;
                                    case "en": sourceLanguageBox.currentIndex = 6; break;
                                    case "fi": sourceLanguageBox.currentIndex = 7; break;
                                    case "fr": sourceLanguageBox.currentIndex = 8; break;
                                    case "de": sourceLanguageBox.currentIndex = 9; break;
                                    case "el": sourceLanguageBox.currentIndex = 10; break;
                                    case "hu": sourceLanguageBox.currentIndex = 11; break;
                                    case "it": sourceLanguageBox.currentIndex = 12; break;
                                    case "ja": sourceLanguageBox.currentIndex = 13; break;
                                    case "ko": sourceLanguageBox.currentIndex = 14; break;
                                    case "nb": sourceLanguageBox.currentIndex = 15; break;
                                    case "pl": sourceLanguageBox.currentIndex = 16; break;
                                    case "pt": sourceLanguageBox.currentIndex = 17; break;
                                    case "ru": sourceLanguageBox.currentIndex = 18; break;
                                    case "es": sourceLanguageBox.currentIndex = 19; break;
                                    case "sv": sourceLanguageBox.currentIndex = 20; break;
                                    case "tr": sourceLanguageBox.currentIndex = 21; break;
                                    case "ar": sourceLanguageBox.currentIndex = 22; break;
                                    case "ro": sourceLanguageBox.currentIndex = 23; break;
                                    case "sr-Cyrl": sourceLanguageBox.currentIndex = 24; break;
                                    case "sr-Latn": sourceLanguageBox.currentIndex = 25; break;
                                    case "sk": sourceLanguageBox.currentIndex = 26; break;
                                }
                            }

                            id: sourceLanguageBox
                            anchors.bottom: targetLanguageBox.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            label: qsTr("Source Language")
                            visible: !wunderfitzView.isProcessing && viewfinderLoader.active
                            menu: ContextMenu {
                                MenuItem { text: qsTr("Auto-Detect") }
                                MenuItem { text: qsTr("Chinese-Simplified") }
                                MenuItem { text: qsTr("Chinese-Traditional") }
                                MenuItem { text: qsTr("Czech") }
                                MenuItem { text: qsTr("Danish") }
                                MenuItem { text: qsTr("Dutch") }
                                MenuItem { text: qsTr("English") }
                                MenuItem { text: qsTr("Finnish") }
                                MenuItem { text: qsTr("French") }
                                MenuItem { text: qsTr("German") }
                                MenuItem { text: qsTr("Greek") }
                                MenuItem { text: qsTr("Hungarian") }
                                MenuItem { text: qsTr("Italian") }
                                MenuItem { text: qsTr("Japanese") }
                                MenuItem { text: qsTr("Korean") }
                                MenuItem { text: qsTr("Norwegian") }
                                MenuItem { text: qsTr("Polish") }
                                MenuItem { text: qsTr("Portuguese") }
                                MenuItem { text: qsTr("Russian") }
                                MenuItem { text: qsTr("Spanish") }
                                MenuItem { text: qsTr("Swedish") }
                                MenuItem { text: qsTr("Turkish") }
                                MenuItem { text: qsTr("Arabic") }
                                MenuItem { text: qsTr("Romanian") }
                                MenuItem { text: qsTr("Serbian-Cyrillic") }
                                MenuItem { text: qsTr("Serbian-Latin") }
                                MenuItem { text: qsTr("Slovak") }
                            }
                            onCurrentIndexChanged: {
                                switch (sourceLanguageBox.currentIndex) {
                                    case 0: curiosity.setSourceLanguage("unk"); break;
                                    case 1: curiosity.setSourceLanguage("zh-Hans"); break;
                                    case 2: curiosity.setSourceLanguage("zh-Hant"); break;
                                    case 3: curiosity.setSourceLanguage("cs"); break;
                                    case 4: curiosity.setSourceLanguage("da"); break;
                                    case 5: curiosity.setSourceLanguage("nl"); break;
                                    case 6: curiosity.setSourceLanguage("en"); break;
                                    case 7: curiosity.setSourceLanguage("fi"); break;
                                    case 8: curiosity.setSourceLanguage("fr"); break;
                                    case 9: curiosity.setSourceLanguage("de"); break;
                                    case 10: curiosity.setSourceLanguage("el"); break;
                                    case 11: curiosity.setSourceLanguage("hu"); break;
                                    case 12: curiosity.setSourceLanguage("it"); break;
                                    case 13: curiosity.setSourceLanguage("ja"); break;
                                    case 14: curiosity.setSourceLanguage("ko"); break;
                                    case 15: curiosity.setSourceLanguage("nb"); break;
                                    case 16: curiosity.setSourceLanguage("pl"); break;
                                    case 17: curiosity.setSourceLanguage("pt"); break;
                                    case 18: curiosity.setSourceLanguage("ru"); break;
                                    case 19: curiosity.setSourceLanguage("es"); break;
                                    case 20: curiosity.setSourceLanguage("sv"); break;
                                    case 21: curiosity.setSourceLanguage("tr"); break;
                                    case 22: curiosity.setSourceLanguage("ar"); break;
                                    case 23: curiosity.setSourceLanguage("ro"); break;
                                    case 24: curiosity.setSourceLanguage("sr-Cyrl"); break;
                                    case 25: curiosity.setSourceLanguage("sr-Latn"); break;
                                    case 26: curiosity.setSourceLanguage("sk"); break;
                                }
                            }
                        }


                        ComboBox {
                            Component.onCompleted: {
                                var languageCode = curiosity.getTargetLanguage();
                                switch (languageCode) {
                                    case "en": targetLanguageBox.currentIndex = 0; break;
                                    case "af": targetLanguageBox.currentIndex = 1; break;
                                    case "ar": targetLanguageBox.currentIndex = 2; break;
                                    case "bg": targetLanguageBox.currentIndex = 3; break;
                                    case "bn": targetLanguageBox.currentIndex = 4; break;
                                    case "bs": targetLanguageBox.currentIndex = 5; break;
                                    case "ca": targetLanguageBox.currentIndex = 6; break;
                                    case "cs": targetLanguageBox.currentIndex = 7; break;
                                    case "cy": targetLanguageBox.currentIndex = 8; break;
                                    case "da": targetLanguageBox.currentIndex = 9; break;
                                    case "de": targetLanguageBox.currentIndex = 10; break;
                                    case "el": targetLanguageBox.currentIndex = 11; break;
                                    case "es": targetLanguageBox.currentIndex = 12; break;
                                    case "et": targetLanguageBox.currentIndex = 13; break;
                                    case "fa": targetLanguageBox.currentIndex = 14; break;
                                    case "fi": targetLanguageBox.currentIndex = 15; break;
                                    case "fil": targetLanguageBox.currentIndex = 16; break;
                                    case "fj": targetLanguageBox.currentIndex = 17; break;
                                    case "fr": targetLanguageBox.currentIndex = 18; break;
                                    case "he": targetLanguageBox.currentIndex = 19; break;
                                    case "hi": targetLanguageBox.currentIndex = 20; break;
                                    case "hr": targetLanguageBox.currentIndex = 21; break;
                                    case "ht": targetLanguageBox.currentIndex = 22; break;
                                    case "hu": targetLanguageBox.currentIndex = 23; break;
                                    case "id": targetLanguageBox.currentIndex = 24; break;
                                    case "is": targetLanguageBox.currentIndex = 25; break;
                                    case "it": targetLanguageBox.currentIndex = 26; break;
                                    case "ja": targetLanguageBox.currentIndex = 27; break;
                                    case "ko": targetLanguageBox.currentIndex = 28; break;
                                    case "lt": targetLanguageBox.currentIndex = 29; break;
                                    case "lv": targetLanguageBox.currentIndex = 30; break;
                                    case "mg": targetLanguageBox.currentIndex = 31; break;
                                    case "ms": targetLanguageBox.currentIndex = 32; break;
                                    case "mt": targetLanguageBox.currentIndex = 33; break;
                                    case "mww": targetLanguageBox.currentIndex = 34; break;
                                    case "nb": targetLanguageBox.currentIndex = 35; break;
                                    case "nl": targetLanguageBox.currentIndex = 36; break;
                                    case "otq": targetLanguageBox.currentIndex = 37; break;
                                    case "pl": targetLanguageBox.currentIndex = 38; break;
                                    case "pt": targetLanguageBox.currentIndex = 39; break;
                                    case "ro": targetLanguageBox.currentIndex = 40; break;
                                    case "ru": targetLanguageBox.currentIndex = 41; break;
                                    case "sk": targetLanguageBox.currentIndex = 42; break;
                                    case "sl": targetLanguageBox.currentIndex = 43; break;
                                    case "sm": targetLanguageBox.currentIndex = 44; break;
                                    case "sr-Cyrl": targetLanguageBox.currentIndex = 45; break;
                                    case "sr-Latn": targetLanguageBox.currentIndex = 46; break;
                                    case "sv": targetLanguageBox.currentIndex = 47; break;
                                    case "sw": targetLanguageBox.currentIndex = 48; break;
                                    case "ta": targetLanguageBox.currentIndex = 49; break;
                                    case "th": targetLanguageBox.currentIndex = 50; break;
                                    case "tlh": targetLanguageBox.currentIndex = 51; break;
                                    case "to": targetLanguageBox.currentIndex = 52; break;
                                    case "tr": targetLanguageBox.currentIndex = 53; break;
                                    case "ty": targetLanguageBox.currentIndex = 54; break;
                                    case "uk": targetLanguageBox.currentIndex = 55; break;
                                    case "ur": targetLanguageBox.currentIndex = 56; break;
                                    case "vi": targetLanguageBox.currentIndex = 57; break;
                                    case "yua": targetLanguageBox.currentIndex = 58; break;
                                    case "yue": targetLanguageBox.currentIndex = 59; break;
                                    case "zh-Hans": targetLanguageBox.currentIndex = 60; break;
                                    case "zh-Hant": targetLanguageBox.currentIndex = 61; break;
                                }
                            }

                            id: targetLanguageBox
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Theme.iconSizeMedium + Theme.horizontalPageMargin + ( 2 * Theme.paddingLarge )
                            anchors.horizontalCenter: parent.horizontalCenter
                            label: qsTr("Target Language")
                            visible: !wunderfitzView.isProcessing && viewfinderLoader.active
                            menu: ContextMenu {
                                MenuItem { text: qsTr("English") }
                                MenuItem { text: qsTr("Afrikaans") }
                                MenuItem { text: qsTr("Arabic") }
                                MenuItem { text: qsTr("Bulgarian") }
                                MenuItem { text: qsTr("Bangla") }
                                MenuItem { text: qsTr("Bosnian") }
                                MenuItem { text: qsTr("Catalan") }
                                MenuItem { text: qsTr("Czech") }
                                MenuItem { text: qsTr("Welsh") }
                                MenuItem { text: qsTr("Danish") }
                                MenuItem { text: qsTr("German") }
                                MenuItem { text: qsTr("Greek") }
                                MenuItem { text: qsTr("Spanish") }
                                MenuItem { text: qsTr("Estonian") }
                                MenuItem { text: qsTr("Persian") }
                                MenuItem { text: qsTr("Finnish") }
                                MenuItem { text: qsTr("Filipino") }
                                MenuItem { text: qsTr("Fijian") }
                                MenuItem { text: qsTr("French") }
                                MenuItem { text: qsTr("Hebrew") }
                                MenuItem { text: qsTr("Hindi") }
                                MenuItem { text: qsTr("Croatian") }
                                MenuItem { text: qsTr("Haitian Creole") }
                                MenuItem { text: qsTr("Hungarian") }
                                MenuItem { text: qsTr("Indonesian") }
                                MenuItem { text: qsTr("Icelandic") }
                                MenuItem { text: qsTr("Italian") }
                                MenuItem { text: qsTr("Japanese") }
                                MenuItem { text: qsTr("Korean") }
                                MenuItem { text: qsTr("Lithuanian") }
                                MenuItem { text: qsTr("Latvian") }
                                MenuItem { text: qsTr("Malagasy") }
                                MenuItem { text: qsTr("Malay") }
                                MenuItem { text: qsTr("Maltese") }
                                MenuItem { text: qsTr("Hmong Daw") }
                                MenuItem { text: qsTr("Norwegian") }
                                MenuItem { text: qsTr("Dutch") }
                                MenuItem { text: qsTr("Querétaro Otomi") }
                                MenuItem { text: qsTr("Polish") }
                                MenuItem { text: qsTr("Portuguese") }
                                MenuItem { text: qsTr("Romanian") }
                                MenuItem { text: qsTr("Russian") }
                                MenuItem { text: qsTr("Slovak") }
                                MenuItem { text: qsTr("Slovenian") }
                                MenuItem { text: qsTr("Samoan") }
                                MenuItem { text: qsTr("Serbian-Cyrillic") }
                                MenuItem { text: qsTr("Serbian-Latin") }
                                MenuItem { text: qsTr("Swedish") }
                                MenuItem { text: qsTr("Kiswahili") }
                                MenuItem { text: qsTr("Tamil") }
                                MenuItem { text: qsTr("Thai") }
                                MenuItem { text: qsTr("Klingon") }
                                MenuItem { text: qsTr("Tongan") }
                                MenuItem { text: qsTr("Turkish") }
                                MenuItem { text: qsTr("Tahitian") }
                                MenuItem { text: qsTr("Ukrainian") }
                                MenuItem { text: qsTr("Urdu") }
                                MenuItem { text: qsTr("Vietnamese") }
                                MenuItem { text: qsTr("Yucatec Maya") }
                                MenuItem { text: qsTr("Cantonese-Traditional") }
                                MenuItem { text: qsTr("Chinese-Simplified") }
                                MenuItem { text: qsTr("Chinese-Traditional") }
                            }
                            onCurrentIndexChanged: {
                                switch (targetLanguageBox.currentIndex) {
                                    case 0: curiosity.setTargetLanguage("en"); break;
                                    case 1: curiosity.setTargetLanguage("af"); break;
                                    case 2: curiosity.setTargetLanguage("ar"); break;
                                    case 3: curiosity.setTargetLanguage("bg"); break;
                                    case 4: curiosity.setTargetLanguage("bn"); break;
                                    case 5: curiosity.setTargetLanguage("bs"); break;
                                    case 6: curiosity.setTargetLanguage("ca"); break;
                                    case 7: curiosity.setTargetLanguage("cs"); break;
                                    case 8: curiosity.setTargetLanguage("cy"); break;
                                    case 9: curiosity.setTargetLanguage("da"); break;
                                    case 10: curiosity.setTargetLanguage("de"); break;
                                    case 11: curiosity.setTargetLanguage("el"); break;
                                    case 12: curiosity.setTargetLanguage("es"); break;
                                    case 13: curiosity.setTargetLanguage("et"); break;
                                    case 14: curiosity.setTargetLanguage("fa"); break;
                                    case 15: curiosity.setTargetLanguage("fi"); break;
                                    case 16: curiosity.setTargetLanguage("fil"); break;
                                    case 17: curiosity.setTargetLanguage("fj"); break;
                                    case 18: curiosity.setTargetLanguage("fr"); break;
                                    case 19: curiosity.setTargetLanguage("he"); break;
                                    case 20: curiosity.setTargetLanguage("hi"); break;
                                    case 21: curiosity.setTargetLanguage("hr"); break;
                                    case 22: curiosity.setTargetLanguage("ht"); break;
                                    case 23: curiosity.setTargetLanguage("hu"); break;
                                    case 24: curiosity.setTargetLanguage("id"); break;
                                    case 25: curiosity.setTargetLanguage("is"); break;
                                    case 26: curiosity.setTargetLanguage("it"); break;
                                    case 27: curiosity.setTargetLanguage("ja"); break;
                                    case 28: curiosity.setTargetLanguage("lt"); break;
                                    case 29: curiosity.setTargetLanguage("lv"); break;
                                    case 30: curiosity.setTargetLanguage("ko"); break;
                                    case 31: curiosity.setTargetLanguage("mg"); break;
                                    case 32: curiosity.setTargetLanguage("ms"); break;
                                    case 33: curiosity.setTargetLanguage("mt"); break;
                                    case 34: curiosity.setTargetLanguage("mww"); break;
                                    case 35: curiosity.setTargetLanguage("nb"); break;
                                    case 36: curiosity.setTargetLanguage("nl"); break;
                                    case 37: curiosity.setTargetLanguage("otq"); break;
                                    case 38: curiosity.setTargetLanguage("pl"); break;
                                    case 39: curiosity.setTargetLanguage("pt"); break;
                                    case 40: curiosity.setTargetLanguage("ro"); break;
                                    case 41: curiosity.setTargetLanguage("ru"); break;
                                    case 42: curiosity.setTargetLanguage("sk"); break;
                                    case 43: curiosity.setTargetLanguage("sl"); break;
                                    case 44: curiosity.setTargetLanguage("sm"); break;
                                    case 45: curiosity.setTargetLanguage("sr-Cyrl"); break;
                                    case 46: curiosity.setTargetLanguage("sr-Latn"); break;
                                    case 47: curiosity.setTargetLanguage("sv"); break;
                                    case 48: curiosity.setTargetLanguage("sw"); break;
                                    case 49: curiosity.setTargetLanguage("ta"); break;
                                    case 50: curiosity.setTargetLanguage("th"); break;
                                    case 51: curiosity.setTargetLanguage("tlh"); break;
                                    case 52: curiosity.setTargetLanguage("to"); break;
                                    case 53: curiosity.setTargetLanguage("tr"); break;
                                    case 54: curiosity.setTargetLanguage("ty"); break;
                                    case 55: curiosity.setTargetLanguage("uk"); break;
                                    case 56: curiosity.setTargetLanguage("ur"); break;
                                    case 57: curiosity.setTargetLanguage("vi"); break;
                                    case 58: curiosity.setTargetLanguage("yua"); break;
                                    case 59: curiosity.setTargetLanguage("yue"); break;
                                    case 60: curiosity.setTargetLanguage("zh-Hans"); break;
                                    case 61: curiosity.setTargetLanguage("zh-Hant"); break;
                                }
                            }
                        }

                        Rectangle {
                            id: cloudWarningBackground
                            anchors.fill: parent
                            color: "black"
                            opacity: 0.8
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
                }

                Timer {
                    id: slideshowVisibleTimer
                    property int tabId: 0
                    interval: 50
                    repeat: false
                    onTriggered: {
                        viewsSlideshow.positionViewAtIndex(tabId, PathView.SnapPosition);
                        viewsSlideshow.opacity = 1;
                    }
                    function goToTab(newTabId) {
                        tabId = newTabId;
                        start();
                    }
                }

                SlideshowView {
                    id: viewsSlideshow
                    width: parent.width - ( titlePage.isLandscape ? getNavigationRowSize() + ( 2 * Theme.horizontalPageMargin ) : 0 )
                    height: parent.height
                    itemWidth: width
                    clip: true
                    model: viewsModel
                    onCurrentIndexChanged: {
                        openTab(currentIndex);
                    }
                    Behavior on opacity { NumberAnimation {} }
                    onOpacityChanged: {
                        if (opacity === 0) {
                            slideshowVisibleTimer.start();
                        }
                    }
                }

                Item {
                    id: navigationColumn
                    width: titlePage.isLandscape ? getNavigationRowSize() + ( 2 * Theme.horizontalPageMargin ) : 0
                    height: parent.height
                    visible: titlePage.isLandscape
                    property bool squeezed: height < ( ( Theme.iconSizeMedium + Theme.fontSizeTiny ) * 2 ) ? true : false

                    Separator {
                        id: navigatorColumnSeparator
                        width: parent.height
                        color: Theme.primaryColor
                        horizontalAlignment: Qt.AlignHCenter
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall
                        transform: Rotation { angle: 90 }
                    }

                    Column {

                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingSmall
                        anchors.top: parent.top

                        height: parent.height
                        width: parent.width

                        Item {
                            id: dictionariesButtonColumnLandscape
                            height: parent.height / 2
                            width: parent.width - Theme.paddingMedium
                            DictionaryButton {
                                id: dictionariesButtonLandscape
                                visible: (isActive || !navigationColumn.squeezed)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Item {
                            id: wunderfitzButtonColumnLandscape
                            height: parent.height / 2
                            width: parent.width - Theme.paddingMedium
                            WunderfitzButton {
                                id: wunderfitzButtonLandscape
                                visible: (isActive || !navigationColumn.squeezed)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                    }

                }

            }

            Column {
                id: navigationRow
                width: parent.width
                height: titlePage.isPortrait ? getNavigationRowSize() : 0
                visible: titlePage.isPortrait
                Column {
                    id: navigationRowSeparatorColumn
                    width: parent.width
                    height: Theme.paddingMedium
                    Separator {
                        id: navigationRowSeparator
                        width: parent.width
                        color: Theme.primaryColor
                        horizontalAlignment: Qt.AlignHCenter
                    }
                }

                Row {
                    y: Theme.paddingSmall
                    width: parent.width
                    Item {
                        id: dictionariesButtonColumn
                        width: parent.width / 2
                        height: parent.height - Theme.paddingMedium
                        DictionaryButton {
                            id: dictionariesButtonPortrait
                            anchors.top: parent.top
                        }
                    }

                    Item {
                        id: notificationsButtonColumn
                        width: parent.width / 2
                        height: parent.height - navigationRowSeparator.height
                        WunderfitzButton {
                            id: wunderfitzButtonPortrait
                            anchors.top: parent.top
                        }
                    }
                }
            }

        }

    }
}


