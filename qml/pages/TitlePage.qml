/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.wunderfitz 1.0


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
                title: qsTr("Wunderfitz")
            }

            SearchField {
                id: searchField
                x: Theme.paddingMedium
                width: parent.width
                placeholderText: qsTr("Search in dictionary...")
                focus: true

                onTextChanged: {
                    heinzelnissemodel.search(searchField.text)
                }
            }

            SilicaListView {

                id: listView

                height: titlePage.height - header.height
                anchors.left: parent.left
                anchors.right: parent.right

                clip: true

                model: HeinzelnisseModel {
                    id: heinzelnissemodel
                }

                delegate: ListItem {
                    Label {
                        font.pixelSize: Theme.fontSizeSmall
                        x: Theme.horizontalPageMargin
                        text: display.norwegisch + " - " + display.deutsch
                    }
                }
            }

        }



    }
}


