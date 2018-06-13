/*
    Copyright (C) 2016-18 Sebastian J. Wolf

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
import org.nemomobile.notifications 1.0
import org.nemomobile.dbus 2.0

Page {
    id: dictionariesPage
    allowedOrientations: Orientation.All

    function toggleBusyIndicator() {
        busyIndicator.running = dictCCImporterModel.isWorking()
        busyIndicatorColumn.opacity = dictCCImporterModel.isWorking() ? 1 : 0
        dictionaryFlickable.opacity = dictCCImporterModel.isWorking() ? 0 : 1
    }

    Notification {
        id: importNotification
        appName: "Wunderfitz"
        appIcon: "/usr/share/icons/hicolor/256x256/apps/harbour-wunderfitz.png"
    }

    Connections {
        target: dictCCImporterModel
        onDictionaryFound: {
            importNotification.summary = qsTr("Dict.cc Import")
            importNotification.body = qsTr("Dictionary %1 successfully imported").arg(languages)
            importNotification.previewSummary = qsTr("Dict.cc Import")
            importNotification.previewBody = qsTr("Dictionary %1 imported").arg(languages)
            importNotification.replacesId = 0
            importNotification.publish()
        }
    }

    Column {
        y: parent.height / 2 - busyIndicator.height - Theme.paddingLarge
        width: parent.width
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

        Connections {
            target: dictionaryModel
            onDictionaryChanged: {
                dictionaryPullDown.enabled = (dictionaryModel.getSelectedDictionaryId() === "heinzelnisse") ? false : true
                dictionaryComboBox.currentIndex = dictionaryModel.getSelectedDictionaryIndex();
            }
        }

        RemorsePopup {
            id: remorseDelete
        }

        PullDownMenu {
            id: dictionaryPullDown
            MenuItem {
                text: qsTr("Delete selected dictionary")
                onClicked: remorseDelete.execute(qsTr("Deleting dictionary %1").arg(dictionaryModel.getSelectedDictionaryId()), function() {dictionaryModel.deleteSelectedDictionary()}, 4000)
            }
            enabled: (dictionaryModel.getSelectedDictionaryId() === "heinzelnisse") ? false : true
        }

        Column {
            id: dictionariesColumn
            width: dictionariesPage.width

            PageHeader {
                id: header
                title: qsTr("Dictionaries")
            }

            ComboBox {
                id: dictionaryComboBox
                label: qsTr("Dictionary")
                currentIndex: dictionaryModel.getSelectedDictionaryIndex()
                description: qsTr("Choose the active dictionary here")
                menu: ContextMenu {
                    Repeater {
                        model: dictionaryModel
                        delegate: MenuItem {
                            text: display.languages
                        }
                    }
                    onActivated: {
                        dictionaryModel.selectDictionary(index);
                    }
                }
            }

            SectionHeader {
                text: qsTr("Dict.cc Import")
            }

            Column {
                width: parent.width
                spacing: Theme.paddingLarge

                Row {
                    id: infoRow
                    x: Theme.paddingLarge
                    spacing: Theme.paddingSmall
                    width : parent.width

                    Image {
                        id: infoImage
                        source: "image://theme/icon-m-about"
                    }

                    Label {
                        text: qsTr("Dict.cc does not allow other applications such as Wunderfitz to ship their dictionaries. Therefore, you must download them from dict.cc yourself. Use the Download link, follow the instructions and import the files here afterwards. The downloaded dict.cc ZIP files must be placed in the Downloads folder. If in doubt, use the SailfishOS E-Mail and Browser apps to store the downloads there automatically. After the import in Wunderfitz you can delete the ZIP archives. Please note that you only need to download one combination of two languages. For example if you use DE-EN, you don't need EN-DE as Wunderfitz always searches in both languages.")
                        font.pixelSize: Theme.fontSizeExtraSmall
                        wrapMode: Text.Wrap
                        width: parent.width - infoImage.width - (3 * infoRow.x)
                    }
                }

                Text {
                    id: downloadLink
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

                Label {
                    id: separatorLabel
                    font.pixelSize: Theme.fontSizeSmall
                    width: parent.width - 2 * Theme.horizontalPageMargin
                }
            }

            VerticalScrollDecorator {}

        }

    }
}
