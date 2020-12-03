/*
 * This file is part of sf-docked-tab-bar.
 * Copyright (C) 2020  Mirian Margiani
 *
 * sf-docked-tab-bar is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * sf-docked-tab-bar is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with sf-docked-tab-bar. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

DockedTabItem {
    id: tab
    property alias icon: tabIcon.icon
    property alias label: tabLabel.text
    property alias fontSize: tabLabel.font.pixelSize

    Column {
        anchors {
            left: parent.left; right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: Theme.paddingSmall; rightMargin: Theme.paddingSmall
        }

        IconButton {
            id: tabIcon
            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.iconSizeMedium
            width: Theme.iconSizeMedium
            highlighted: tab.highlighted
        }

        Label {
            id: tabLabel
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            color: tab.highlighted ? Theme.highlightColor : Theme.primaryColor
            clip: true

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            font.pixelSize: Theme.fontSizeExtraSmall
            minimumPixelSize: Theme.fontSizeTiny * 4 / 5
            fontSizeMode: Text.Fit
            truncationMode: TruncationMode.Fade
        }
    }
}
