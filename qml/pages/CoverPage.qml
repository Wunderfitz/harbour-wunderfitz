/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/


import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.wunderfitz 1.0
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
        id: label
        anchors {
            top: parent.top
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter

        }
        text: "Wunderfitz"
    }

}


