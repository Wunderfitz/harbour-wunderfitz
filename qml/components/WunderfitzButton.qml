/*
    Copyright (C) 2016-18 Sebastian J. Wolf

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
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

Column {
    id: wunderfitzButton
    property bool isActive: false

    width: parent.width
    IconButton {
        id: wunderfitzButtonImage
        icon.source: wunderfitzButton.isActive ? "image://theme/icon-m-camera?" + Theme.highlightColor : "image://theme/icon-m-camera?" + Theme.primaryColor
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            handleWunderfitzClicked();
        }

    }
    Label {
        id: wunderfitzButtonText
        text: qsTr("Curiosity")
        font.pixelSize: Theme.fontSizeTiny
        color: wunderfitzButton.isActive ? Theme.highlightColor : Theme.primaryColor
        truncationMode: TruncationMode.Fade
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: handleWunderfitzClicked();
        }
    }
}
