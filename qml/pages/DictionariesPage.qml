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

            SectionHeader {
                text: qsTr("Dict.cc dictionary archives")
            }

            Row {
                id: infoRow
                x: Theme.paddingLarge
                spacing: Theme.paddingLarge
                width : parent.width

                Image {
                    id: infoImage
                    source: "image://theme/icon-m-about"
                }

                Label {
                    text: qsTr("Dict.cc does not allow third-party applications such as Wunderfitz to ship their dictionaries. Therefore, you must download them from dict.cc yourself. Use the Download link, follow the instructions and import the files later. The downloaded dict.cc ZIP files must be placed in the Downloads folder so that they can be imported properly. If you use the standard E-Mail Client or Browser, everything is fine. :)")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.Wrap
                    width: parent.width - infoImage.width - (3 * infoRow.x)
                }
            }

            Text {
                text: "<a href=\"http://www1.dict.cc/translation_file_request.php?l=e\">" + qsTr("Download dict.cc dictionaries") + "</a>"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                font.pixelSize: Theme.fontSizeSmall
                linkColor: Theme.highlightColor

                onLinkActivated: Qt.openUrlExternally("http://www1.dict.cc/translation_file_request.php?l=e")
            }

            Button {
                text: qsTr("Import dict.cc archives")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: dictCCImporterModel.importDictionaries()
            }

             VerticalScrollDecorator {}

        }

    }
}
