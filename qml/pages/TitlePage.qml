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

        PullDownMenu {
            MenuItem {
                text: qsTr("About Wunderfitz")
                onClicked: pageStack.push(aboutPage)
            }
        }

        contentHeight: parent.height

        Column {
            id: column

            width: titlePage.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Wunderfitz")
            }
            SearchField {
                id: searchField
                x: Theme.paddingMedium
                width: parent.width
                placeholderText: qsTr("Search in dictionary...")
                focus: true
            }
        }
    }
}


