/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: titlePage
    allowedOrientations: Orientation.All

    property bool interactionHintDisplayed : dictionaryModel.isInteractionHintDisplayed()

    function toggleBusyIndicator() {
        busyIndicator.running = heinzelnisseModel.isSearchInProgress()
        busyIndicatorColumn.opacity = heinzelnisseModel.isSearchInProgress() ? 1 : 0
        listView.opacity = heinzelnisseModel.isSearchInProgress() ? 0 : 1
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
        contentHeight: searchColumn.height

        PullDownMenu {
            MenuItem {
                text: qsTr("About Wunderfitz")
                onClicked: pageStack.push(aboutPage)
            }
            MenuItem {
                text: qsTr("Dictionaries")
                onClicked: pageStack.push(dictionariesPage)
            }
        }

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
            text: qsTr("Pull down to import and change your dictionaries")
            invert: true
            Behavior on opacity { NumberAnimation {} }
            opacity: titlePage.interactionHintDisplayed
        }

        Column {
            x: listView.x
            y: listView.y
            height: titlePage.height - header.height - searchField.height - ( 2 * Theme.paddingLarge )
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
            id: searchColumn

            Behavior on opacity { NumberAnimation {} }
            opacity: titlePage.interactionHintDisplayed ? 0 : 1

            width: titlePage.width
            spacing: Theme.paddingLarge

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
                x: Theme.paddingMedium
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

                height: titlePage.height - header.height - searchField.height - ( 2 * Theme.paddingLarge )
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
                                Clipboard.text = display.wordLeft + " " + display.genderLeft + " " + display.otherLeft + " - " + display.wordRight + " " + display.genderRight + " " + display.otherRight
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
}


