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
import "pages"
import "components"
import "sf-docked-tab-bar"

ApplicationWindow
{
    id: window
    initialPage: Component { TitlePage {} }
    cover: Component { CoverPage {} }
    allowedOrientations: Orientation.All

    readonly property bool useCloud: curiosity.useCloud
    readonly property string mainPageName: "TitlePage"
    property alias tabBar: _tabBar

    DockedTabBar {
        id: _tabBar
        enabledOnPage: useCloud ? mainPageName : "[disabled]"
        currentSelection: 0

        DockedTabButton {
            icon.source: "image://theme/icon-m-search"
            label: qsTr("Dictionaries")
            fontSize: Theme.fontSizeTiny
        }
        DockedTabButton {
            icon.source: "image://theme/icon-m-camera"
            label: qsTr("Curiosity")
            fontSize: Theme.fontSizeTiny
        }
    }
}
