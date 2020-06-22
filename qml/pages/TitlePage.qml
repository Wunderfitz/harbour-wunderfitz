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

    readonly property int currentTabId: tabBar.currentSelection

    function openTab(tabId) {
        viewsSlideshow.opacity = 0;
        slideshowVisibleTimer.goToTab(tabId);
        tabBar.currentSelection = tabId;
    }

    onCurrentTabIdChanged: {
        if (viewsSlideshow.currentIndex !== currentTabId) openTab(currentTabId);
    }

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
                visible: currentTabId === 0
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

            onCurrentIndexChanged: openTab(currentIndex)
            interactive: useCloud

            Connections {
                target: curiosity
                onUseCloudChanged: if (!useCloud) viewsSlideshow.currentIndex = 0
            }

            Behavior on opacity { NumberAnimation {} }
            onOpacityChanged: {
                if (opacity === 0) {
                    slideshowVisibleTimer.start();
                }
            }

            Timer {
                id: slideshowVisibleTimer
                property int targetTabId: 0
                interval: 50
                repeat: false

                onTriggered: {
                    viewsSlideshow.positionViewAtIndex(targetTabId, PathView.SnapPosition);
                    viewsSlideshow.opacity = 1;
                }

                function goToTab(newTabId) {
                    targetTabId = newTabId;
                    start();
                }
            }
        }
    }
}
