import QtQuick 2.0
import Sailfish.Silica 1.0

DockedPanel {
    id: tabBar
    property string enabledOnPage: "[nowhere]"
    default property alias tabsContainer: contentFlow.data

    property bool _debug: false
    property int _orientation: pageStack.currentOrientation
    property alias _orientationState: orientationContainer.state
    property bool isVertical: orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted
    property bool isHorizontal: orientation === Orientation.Portrait || orientation === Orientation.PortraitInverted

    property int _baseTabHeight: Theme.itemSizeLarge

    property int currentSelection: -1
    onCurrentSelectionChanged: {
        if (currentSelection > _tabs.length) {
            console.log("DockedTabBar: index out of range:", currentSelection, _tabs.length);
        } else {
            console.log("DockedTabBar: current selection:", currentSelection)
        }
    }

    property var _tabs: []

    visible: true
    open: true
    background: Item {} // = none
    dock: Dock.Bottom

    Connections {
        target: pageStack
        onCurrentPageChanged: {
            if (pageStack.currentPage.objectName === tabBar.enabledOnPage) {
                tabBar.show();
            } else {
                tabBar.hide();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
    }

    Separator {
        id: separator
        horizontalAlignment: Qt.AlignHCenter
        width: parent.width
        anchors.top: contentFlow.top
        color: Theme.primaryColor
        transform: Rotation {
            id: separatorRotation
            angle: 0
            // FIXME, TODO: the separator is still visible when the dock is vertical and hidden
        }
    }

    Flow {
        id: contentFlow
        anchors.fill: parent
        flow: isHorizontal ? Flow.LeftToRight : Flow.TopToBottom

        function relayout() {
            if (!isHorizontal && !isVertical) return;

            _tabs = []; var i;
            for (i in children) {
                if (children[i].objectName === 'DockedTabBarItem') _tabs.push(children[i]);
            }

            console.log("layouting DockedTabBar: found", _tabs.length, "tabs");
            var baseTabWidth = Theme.itemSizeLarge;
            var baseTabHeight = _baseTabHeight;

            if (isHorizontal) {
                console.log("layouting horizontally");
                var usedWidth = __silica_applicationwindow_instance.width;
                var tabsPerRow = Math.floor(usedWidth / baseTabWidth)+1;
                var rows = Math.ceil(_tabs.length / tabsPerRow);
                var lastRowIndex = _tabs.length - (_tabs.length % tabsPerRow);
                var tabWidth = rows > 1 ? usedWidth / tabsPerRow : usedWidth / _tabs.length;
                var lastRowCount = _tabs.length-lastRowIndex;
                var lastRowOuterTabWidth = (usedWidth - ((Math.max(lastRowCount-2, 0))*tabWidth)) / 2;

                tabBar.width = __silica_applicationwindow_instance.width
                tabBar.height = baseTabHeight*rows;
                __silica_applicationwindow_instance.bottomMargin = Qt.binding(function() { return tabBar.visibleSize; });
                // __silica_applicationwindow_instance._clippingItem.height = Qt.binding(function(){ return __silica_applicationwindow_instance.height; })

                console.log("#:", usedWidth, baseTabWidth, tabsPerRow, rows, lastRowIndex,
                            tabWidth, lastRowCount, lastRowOuterTabWidth,
                            tabBar.height, __silica_applicationwindow_instance.bottomMargin, tabBar.visibleSize);

                for (i in _tabs) {
                    _tabs[i]._tabIndex = Number(i);
                    _tabs[i]._tabBar = tabBar;
                    if (currentSelection === Number(i)) _tabs[i].isSelected = true;

                    _tabs[i]._alignment = '';
                    if (rows > 1 && lastRowCount >= 2) {
                        if (Number(i) === lastRowIndex) {
                            _tabs[i].width = lastRowOuterTabWidth;
                            _tabs[i]._alignment = 'right';
                        } else if (Number(i) === _tabs.length-1) {
                            _tabs[i].width = lastRowOuterTabWidth;
                            _tabs[i]._alignment = 'left';
                        } else {
                            _tabs[i].width = tabWidth;
                        }
                    } else if (rows > 1 && lastRowCount === 1 && Number(i) === lastRowIndex) {
                        _tabs[i].width = usedWidth;
                    } else {
                        _tabs[i].width = tabWidth;
                    }

                    _tabs[i].height = baseTabHeight;
                }
            } else {
                console.log("layouting vertically");
                var usedHeight = __silica_applicationwindow_instance.width;
                var tabsPerCol = Math.floor(usedHeight / baseTabHeight)+1;
                var cols = Math.ceil(_tabs.length / tabsPerCol);
                var lastColIndex = _tabs.length - (_tabs.length % tabsPerCol);
                var tabHeight = cols > 1 ? usedHeight / tabsPerCol : usedHeight / _tabs.length;
                var lastColCount = _tabs.length-lastColIndex;
                var lastColOuterTabHeight = (usedHeight - (Math.max(lastColCount-2, 0)*tabHeight)) / 2;

                tabWidth = baseTabWidth + Theme.horizontalPageMargin + (cols > 1 ? 0 : Theme.horizontalPageMargin);
                tabBar.width = tabWidth*cols;
                tabBar.height = __silica_applicationwindow_instance.width;
                __silica_applicationwindow_instance.bottomMargin = 0;
                // __silica_applicationwindow_instance._clippingItem.height = Qt.binding(function(){ return __silica_applicationwindow_instance.height - tabBar.visibleSize; })

                // FIXME, TODO: dock and separator are on the wrong side for LandscapeInverted

                console.log("#:", usedHeight, tabsPerCol, cols, lastColIndex, tabHeight, tabWidth,
                            lastColCount, lastColOuterTabHeight, tabBar.width, tabBar.visibleSize);

                for (i in _tabs) {
                    _tabs[i]._tabIndex = Number(i);
                    _tabs[i]._tabBar = tabBar;
                    if (currentSelection === Number(i)) _tabs[i].isSelected = true;

                    _tabs[i]._alignment = '';
                    if (cols > 1 && lastColCount >= 2) {
                        if (Number(i) === lastColIndex) {
                            _tabs[i].height = lastColOuterTabHeight;
                            _tabs[i]._alignment = 'bottom';
                        } else if (Number(i) === _tabs.length-1) {
                            _tabs[i].height = lastColOuterTabHeight;
                            _tabs[i]._alignment = 'top';
                        } else {
                            _tabs[i].height = tabHeight;
                        }
                    } else if (cols > 1 && lastColCount === 1 && Number(i) === lastColIndex) {
                        _tabs[i].height = usedHeight;
                    } else {
                        _tabs[i].height = tabHeight;
                    }

                    _tabs[i].width = tabWidth;
                }
            }
        }

        onChildrenChanged: {
            // relayout();
            console.log("TabBar: children changed")
        }

        Component.onCompleted: relayout()
    }

    Rectangle {
        visible: _debug
        z: -10
        anchors.fill: parent
        color: "red"
        border.color: "orange"
        opacity: 0.3
    }

    Item {
        id: orientationContainer
        onStateChanged: console.log("=>", state)
        states: [
            State {
                when: isHorizontal
                name: "horizontal"
                PropertyChanges {
                    target: tabBar
                    dock: Dock.Bottom
                }
                PropertyChanges {
                    target: separatorRotation
                    angle: 0
                }
                StateChangeScript { script: contentFlow.relayout(); }
            },
            State {
                when: isVertical
                name: "vertical"
                PropertyChanges {
                    target: tabBar
                    dock: Dock.Right
                }
                PropertyChanges {
                    target: __silica_applicationwindow_instance._clippingItem
                    height: { return __silica_applicationwindow_instance.height - tabBar.visibleSize; }
                }
                PropertyChanges {
                    target: separatorRotation
                    angle: 90
                }
                PropertyChanges {
                    target: separator
                    width: __silica_applicationwindow_instance.width
                }
                StateChangeScript { script: contentFlow.relayout(); }
            }
        ]
    }
}