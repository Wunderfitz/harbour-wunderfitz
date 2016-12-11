/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/

import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: aboutPage
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: aboutContainer
        contentHeight: column.height
        anchors.fill: parent

        Column {
            id: column
            width: aboutPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About Wunderfitz")
            }

            Image {
                id: wunderfitzImage
                source: "../images/wunderfitz.png"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                fillMode: Image.PreserveAspectFit
                width: 1/2 * parent.width

            }

            Label {
                text: "Wunderfitz 0.2.1"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraLarge
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Label {
                wrapMode: Text.Wrap
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("A Norwegian-German dictionary based on Heinzelnisse")
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Label {
                text: qsTr("By Sebastian J. Wolf")
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Button {
                text: qsTr("Send E-Mail")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: Qt.openUrlExternally("mailto:sebastian@ygriega.de")
            }

            Label {
                text: qsTr("Licensed under GNU GPLv2")
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Button {
                text: qsTr("Sources on GitHub")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: Qt.openUrlExternally("https://github.com/Wunderfitz/harbour-wunderfitz")
            }

            SectionHeader {
                text: qsTr("Credits")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: qsTr("This project uses the Norwegian-German dictionary from heinzelnisse.info - Updated on November 5, 2016 - Thanks to the authors Heiko Klein and Julia Emmerich for making the dictionary available under the conditions of the GNU GPLv2!")
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Button {
                text: qsTr("Open heinzelnisse.info")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: Qt.openUrlExternally("http://www.heinzelnisse.info/")
            }

            VerticalScrollDecorator {}
        }

    }
}





