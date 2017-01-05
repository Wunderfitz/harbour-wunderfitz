/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: titlePage
    allowedOrientations: Orientation.All

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

        Column {
            id: searchColumn

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
                    heinzelnisseModel.search(searchField.text)
                }
            }

            SilicaListView {

                id: listView

                height: titlePage.height - header.height - searchField.height - ( 2 * Theme.paddingLarge )
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right

                clip: true

                model: heinzelnisseModel

                delegate: ListItem {
                    contentHeight: wordRow.height + Theme.paddingMedium
                    contentWidth: parent.width

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
                                text: display.wordLeft + display.genderLeft
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
                                text: display.wordRight + display.genderRight
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


