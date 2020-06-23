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
