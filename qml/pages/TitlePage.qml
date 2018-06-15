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

    Timer {
        id: searchTimer
        interval: 800
        running: false
        repeat: false
        onTriggered: {
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

                            PageHeader {
                                id: header
                                title: dictionaryModel.getSelectedDictionaryName()
                                Connections {
                                    target: dictionaryModel
                                    onDictionaryChanged: {
                                        header.title = dictionaryModel.getSelectedDictionaryName()
                                        heinzelnisseModel.search(searchField.text)
                                    }
                                }
                            }

                            SearchField {
                                id: searchField
                                width: parent.width
                                placeholderText: qsTr("Search in dictionary...")
                                focus: true

                                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                                EnterKey.onClicked: focus = false

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

                        Component {
                            id: viewfinderComponent

                            Item {

                                anchors.fill: parent

                                Camera {
                                    id: camera
                                    deviceId: QtMultimedia.defaultCamera.deviceId
                                    imageCapture {
                                        onImageSaved: {
                                            console.log("Image captured");
                                            snapshotRectangle.visible = true;
                                            snapshotRectangle.opacity = 1;
                                            snapshotTimer.start();
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
                                    visible: camera.availability === Camera.Available
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
                                        width = sourceRect.width
                                        height = sourceRect.height
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
                                    onValueChanged: {
                                        camera.digitalZoom = value;
                                    }
                                }

                                IconButton {
                                    id: snapshotButton
                                    icon.source: "image://theme/icon-m-dot"
                                    anchors.left: parent.left
                                    anchors.leftMargin: titlePage.isPortrait ? ( videoOutput.width / 2 ) - ( width / 2 ) : parent.width - width - Theme.horizontalPageMargin
                                    anchors.bottom: titlePage.isPortrait ? videoOutput.bottom : parent.bottom
                                    anchors.bottomMargin: Theme.horizontalPageMargin
                                    onClicked: {
                                        camera.imageCapture.capture();
                                    }
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

                        Loader {
                            id: viewfinderLoader
                            active: titlePage.activeTabId === 1
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


