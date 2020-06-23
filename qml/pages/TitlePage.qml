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
import "../components"

Page {
    allowedOrientations: Orientation.All
    objectName: mainPageName

    AppNotification {
        id: titleNotification
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height
        contentWidth: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTr("About Wunderfitz")
                onClicked: pageStack.push(Qt.resolvedUrl("../pages/AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("../pages/SettingsPage.qml"));
            }
            MenuItem {
                visible: viewsSlideshow.currentIndex === 0
                text: qsTr("Dictionaries")
                onClicked: pageStack.push(Qt.resolvedUrl("../pages/DictionariesPage.qml"))
            }
        }

        SlideshowView {
            id: viewsSlideshow
            anchors.fill: parent
            itemWidth: width
            clip: true
            model: VisualItemModel {
                Loader {
                    id: dictView
                    property int index: index // makes attached property available from outside
                    width: viewsSlideshow.width; height: viewsSlideshow.height
                    source: Qt.resolvedUrl("../components/DictionariesView.qml")
                }
                Loader {
                    width: viewsSlideshow.width; height: viewsSlideshow.height
                    source: useCloud ? Qt.resolvedUrl("../components/CuriosityView.qml") : ""
                    asynchronous: true
                    onSourceChanged: {
                        if (source == "") console.log("CuriosityView unloaded", source);
                        else console.log("CuriosityView loaded:", source);
                    }
                }
            }

            interactive: useCloud
            onCurrentIndexChanged: {
                tabBar.currentSelection = currentIndex
                if (currentIndex === dictView.index && pageStack.currentPage.objectName === mainPageName) {
                    dictView.item.focusSearchField();
                }
            }

            currentIndex: tabBar.currentSelection
            Component.onCompleted: if (currentIndex === dictView.index) dictView.item.focusSearchField()

            Connections {
                target: curiosity
                onUseCloudChanged: if (!useCloud) viewsSlideshow.currentIndex = 0
            }

            Connections {
                target: tabBar
                onCurrentSelectionChanged: {
                    if (viewsSlideshow.currentIndex !== tabBar.currentSelection) {
                        viewsSlideshow.positionViewAtIndex(tabBar.currentSelection, PathView.SnapPosition);
                    }
                }
            }
        }
    }
}
