import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: dictionariesPage
    allowedOrientations: Orientation.All

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: dictionariesColumn.height

        Column {
            id: dictionariesColumn

            width: dictionariesPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: header
                title: qsTr("Dictionaries")
            }

             VerticalScrollDecorator {}

        }

    }
}
