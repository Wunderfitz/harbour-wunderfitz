/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/


import QtQuick 2.0
import Sailfish.Silica 1.0
import "."

CoverBackground {

    Image {
        source: "../images/background.png"
        anchors {
            verticalCenter: parent.verticalCenter

            bottom: parent.bottom
            bottomMargin: Theme.paddingMedium

            right: parent.right
            rightMargin: Theme.paddingMedium
        }

        fillMode: Image.PreserveAspectFit
        opacity: 0.15
    }

    Label {
        id: labelTitle
        anchors {
            top: parent.top
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter

        }
        text: "Wunderfitz"
    }

    SilicaListView {
        id: coverListView
        anchors {
            top: labelTitle.bottom
            topMargin: Theme.paddingLarge
            left: parent.left
            leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
            bottom: parent.bottom
        }
        model: heinzelnisseModel
        delegate: ListItem {
            anchors {
                topMargin:  Theme.paddingMedium
            }
            height: resultLabelNorwegian.height + resultLabelGerman.height + Theme.paddingSmall
            opacity: index < 5 ? 1.0 - index * 0.15 : 0.0
            Label {
                id: resultLabelNorwegian
                maximumLineCount: 1
                wrapMode: Text.Wrap
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: display.wordNorwegian
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Label {
                id: resultLabelGerman
                maximumLineCount: 1
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeTiny
                text: display.wordGerman
                anchors {
                    top: resultLabelNorwegian.bottom
                    left: parent.left
                    right: parent.right
                }
            }
        }
    }

}


