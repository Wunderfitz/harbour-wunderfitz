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
                    Clipboard.text = textPage.translation
                }
            }
            MenuItem {
                text: qsTr("Copy original to clipboard")
                onClicked: {
                    Clipboard.text = textPage.original
                }
            }
        }

        Column {
            id: column
            width: textPage.width

            PageHeader {
                title: qsTr("Result")
            }

            SectionHeader {
                text: qsTr("Original")
            }

            TextArea {
                width: parent.width
                wrapMode: TextEdit.Wrap
                font.pixelSize: Theme.fontSizeMedium
                text: textPage.original
            }

            SectionHeader {
                text: qsTr("Translation")
            }

            TextArea {
                width: parent.width
                wrapMode: TextEdit.Wrap
                font.pixelSize: Theme.fontSizeMedium
                text: textPage.translation
            }

            Item { width: parent.width; height: Theme.paddingLarge }
        }

        VerticalScrollDecorator {}
    }
}
