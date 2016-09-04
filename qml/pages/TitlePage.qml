/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: titlePage

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: searchColumn.height

        PullDownMenu {
            MenuItem {
                text: qsTr("About Wunderfitz")
                onClicked: pageStack.push(aboutPage)
            }
        }

        Column {
            id: searchColumn

            width: titlePage.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: header
                title: "Wunderfitz"
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
                anchors.left: parent.left
                anchors.right: parent.right

                clip: true

                model: heinzelnisseModel

                delegate: ListItem {
                    contentHeight: wordRow.height + Theme.paddingSmall

                    Row {
                        id: wordRow
                        width: parent.width
                        Column {
                            id: columnNorwegian
                            width: parent.width / 2 -  2 * Theme.paddingLarge
                            Label {
                                color: Theme.primaryColor
                                width: parent.width
                                font.pixelSize: Theme.fontSizeSmall
                                x: Theme.horizontalPageMargin
                                wrapMode: Text.Wrap
                                text: display.wordNorwegian + display.genderNorwegian
                            }
                            Label {
                                color: Theme.primaryColor
                                width: parent.width
                                font.pixelSize: Theme.fontSizeExtraSmall
                                x: Theme.horizontalPageMargin
                                wrapMode: Text.Wrap
                                text: display.otherNorwegian
                            }
                        }
                        Column {
                            id: columnGerman
                            width: parent.width / 2 - 2 * Theme.paddingLarge
                            Label {
                                width: parent.width
                                color: Theme.highlightColor
                                font.pixelSize: Theme.fontSizeSmall
                                x: Theme.horizontalPageMargin
                                wrapMode: Text.Wrap
                                text: display.wordGerman + display.genderGerman
                            }
                            Label {
                                width: parent.width
                                color: Theme.highlightColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                x: Theme.horizontalPageMargin
                                wrapMode: Text.Wrap
                                text: display.otherGerman
                            }
                        }
                    }

                }

                VerticalScrollDecorator {}

            }

        }



    }
}


