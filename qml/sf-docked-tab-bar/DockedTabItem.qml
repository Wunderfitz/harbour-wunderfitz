import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: tab
    objectName: "DockedTabBarItem"

    property bool isSelected: false
    signal tabSelected(var tabIndex)
    default property alias contentItem: tabContentItem.data

    property alias pressed: mouseArea.pressed
    property bool highlighted: pressed || isSelected

    property alias _alignment: alignmentStateContainer.state
    property int _tabIndex: -1
    property DockedTabBar _tabBar

    width: Theme.itemSizeLarge
    height: Theme.itemSizeLarge + Theme.horizontalPageMargin

    onTabSelected: {
        if (tabIndex !== _tabIndex) return;

        if (_tabBar) {
            _tabBar.currentSelection = tabIndex;
        } else {
            console.log("DockedTabItem: no DockedTabBar available");
        }

        isSelected = true;
    }

    Connections {
        target: _tabBar
        onCurrentSelectionChanged: {
            if (_tabBar.currentSelection !== tab._tabIndex) {
                tab.isSelected = false;
            } else {
                tab.isSelected = true;
            }
        }
    }

    Item {
        id: tabContentItem
        width: Theme.itemSizeLarge; height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        // external children will be placed here
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        preventStealing: true
        onClicked: {
            console.log("clicked", _tabIndex)
            if (!isSelected) {
                tabSelected(_tabIndex)
                console.log("selected", _tabIndex)
            }
        }
    }

    Item {
        id: alignmentStateContainer
        states: [
            State {
                name: "left"
                AnchorChanges {
                    target: tabContentItem
                    anchors {
                        right: undefined; left: tab.left
                        horizontalCenter: undefined; verticalCenter: tab.verticalCenter
                        top: undefined; bottom: undefined
                    }
                }
            },
            State {
                name: "right"
                AnchorChanges {
                    target: tabContentItem
                    anchors {
                        right: tab.right; left: undefined
                        horizontalCenter: undefined; verticalCenter: tab.verticalCenter
                        top: undefined; bottom: undefined
                    }
                }
            },
            State {
                name: "top"
                AnchorChanges {
                    target: tabContentItem
                    anchors {
                        right: undefined; left: undefined
                        horizontalCenter: tab.horizontalCenter; verticalCenter: undefined
                        top: tab.top; bottom: undefined
                    }
                }
            },
            State {
                name: "bottom"
                AnchorChanges {
                    target: tabContentItem
                    anchors {
                        right: undefined; left: undefined
                        horizontalCenter: tab.horizontalCenter; verticalCenter: undefined
                        top: undefined; bottom: tab.bottom
                    }
                }
            }
        ]
    }
}
