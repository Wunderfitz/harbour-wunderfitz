/*
    Copyright (C) 2016-19 Sebastian J. Wolf
                     2020 Mirian Margiani

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
import Sailfish.Silica 1.0
import "."

CoverBackground {
    SilicaListView {
        id: coverListView
        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            left: parent.left
            leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
            bottom: parent.bottom
        }

        model: heinzelnisseModel

        header: Label {
            id: headerLabel
            maximumLineCount: 1
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
            anchors { left: parent.left; right: parent.right }
            text: dictionaryModel.selectedDictionaryName
            horizontalAlignment: Text.AlignHCenter

            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignHCenter
                color: Theme.highlightColor
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.bottom
                }
            }
        }

        delegate: ListItem {
            anchors {
                topMargin:  Theme.paddingMedium
            }
            height: resultLabelNorwegian.height + resultLabelGerman.height + Theme.paddingSmall
            opacity: index < 5 ? 1.0 - index * 0.15 : 0.0
            Label {
                id: resultLabelNorwegian
                maximumLineCount: 1
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: display.wordLeft
                truncationMode: TruncationMode.Fade
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Label {
                id: resultLabelGerman
                maximumLineCount: 1
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: display.wordRight
                truncationMode: TruncationMode.Fade
                anchors {
                    top: resultLabelNorwegian.bottom
                    left: parent.left
                    right: parent.right
                }
            }
        }

        Column {
            visible: coverListView.count === 0
            width: parent.width
            height: childrenRect.height
            anchors.verticalCenter: parent.verticalCenter

            Label {
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font { pixelSize: Theme.fontSizeMedium; family: Theme.fontFamilyHeading }
                x: Theme.paddingMedium
                width: parent.width - 2*x
                color: Theme.highlightColor
                text: "Wunderfitz"
            }
            Label {
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font { pixelSize: Theme.fontSizeMedium; family: Theme.fontFamilyHeading }
                x: Theme.paddingMedium
                width: parent.width - 2*x
                color: Theme.highlightColor
                opacity: Theme.opacityLow
                text: qsTr("Dictionary")
            }
        }
    }
}
