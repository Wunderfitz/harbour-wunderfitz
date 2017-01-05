import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: dictionariesPage
    allowedOrientations: Orientation.All

    function toggleBusyIndicator() {
        busyIndicator.running = dictCCImporterModel.isWorking()
        busyIndicatorColumn.opacity = dictCCImporterModel.isWorking() ? 1 : 0
        dictionaryFlickable.opacity = dictCCImporterModel.isWorking() ? 0 : 1
    }

    Column {
        y: Screen.height / 2 - busyIndicator.height - Theme.paddingLarge
        width: Screen.width
        id: busyIndicatorColumn
        Behavior on opacity { NumberAnimation {} }
        opacity: dictCCImporterModel.isWorking() ? 1 : 0

        BusyIndicator {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            running: dictCCImporterModel.isWorking()
            size: BusyIndicatorSize.Large
        }
        InfoLabel {
            id: busyInfoLabel
            text: dictCCImporterModel.getStatusText()
        }
        Connections {
            target: dictCCImporterModel
            onStatusChanged: {
                busyInfoLabel.text = dictCCImporterModel.getStatusText()
                toggleBusyIndicator()
            }
        }
    }

    SilicaFlickable {

        id: dictionaryFlickable
        anchors.fill: parent
        contentHeight: dictionariesColumn.height
        Behavior on opacity { NumberAnimation {} }
        opacity: dictCCImporterModel.isWorking() ? 0 : 1

        Column {
            id: dictionariesColumn

            width: dictionariesPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: header
                title: qsTr("Dictionaries")
            }

            ComboBox {
                label: qsTr("Dictionary")
                menu: ContextMenu {
                    MenuItem { text: "DE-NO (Heinzelnisse)" }
                }
            }

            SectionHeader {
                text: qsTr("Dict.cc Import")
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
                    text: qsTr("Dict.cc does not allow third-party applications such as Wunderfitz to ship their dictionaries. Therefore, you must download them from dict.cc yourself. Use the Download link, follow the instructions and import the files later. The downloaded dict.cc ZIP files must be placed in the Downloads folder. If in doubt, use the SailfishOS E-Mail and Browser apps to store the downloads there automatically. After the import in Wunderfitz you can delete the ZIP archives.")
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
                text: qsTr("Import dict.cc ZIP archives")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: dictCCImporterModel.importDictionaries()
            }

            Text {
                id: importStatusText
                text: dictCCImporterModel.getStatusText()
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                Connections {
                    target: dictCCImporterModel
                    onStatusChanged: {
                        importStatusText.text = dictCCImporterModel.getStatusText()
                    }
                }

            }



             VerticalScrollDecorator {}

        }

    }
}
