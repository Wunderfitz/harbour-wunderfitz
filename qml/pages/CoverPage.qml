/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/


import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Image {
        source: "../images/background.png"
        anchors {
            verticalCenter: parent.verticalCenter

            left: parent.left
            leftMargin: Theme.paddingMedium

            right: parent.right
            rightMargin: Theme.paddingMedium
        }

        fillMode: Image.PreserveAspectFit
        opacity: 0.3
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

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: {
                pageStack.pop(pageStack.find( function(page){ return(page._depth === 0)} ), PageStackAction.Immediate)
                window.activate()
            }
        }

    }
}


