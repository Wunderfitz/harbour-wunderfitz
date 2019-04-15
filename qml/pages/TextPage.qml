/*
    Copyright (C) 2016-19 Sebastian J. Wolf

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
import "../components"

Page {
    id: textPage
    allowedOrientations: Orientation.All

    property string original;
    property string translation;

    SilicaFlickable {
        id: textContainer
        contentHeight: column.height
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Copy translation to clipboard")
                onClicked: {
                    Clipboard.text = translationContent.text
                }
            }
            MenuItem {
                text: qsTr("Copy original to clipboard")
                onClicked: {
                    Clipboard.text = originalContent.text
                }
            }
        }

        Column {
            id: column
            width: textPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: textHeader
                title: qsTr("Result")
            }

            SectionHeader {
                id: originalHeader
                text: qsTr("Original")
            }

            Text {
                id: originalContent
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                linkColor: Theme.highlightColor
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                text: textPage.original
            }

            SectionHeader {
                id: translationHeader
                text: qsTr("Translation")
            }

            Text {
                id: translationContent
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                linkColor: Theme.highlightColor
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                text: textPage.translation
            }

            VerticalScrollDecorator {}
        }

    }
}
