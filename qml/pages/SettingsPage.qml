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

Page {
    id: settingsPage
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        computerVisionKeyField.text = curiosity.getComputerVisionKey();
        translatorTextKeyField.text = curiosity.getTranslatorTextKey();
    }

    SilicaFlickable {
        id: settingsContainer
        contentHeight: column.height
        anchors.fill: parent

        Column {
            id: column
            width: settingsPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Cloud API")
            }

            TextSwitch {
                checked: useCloud
                text: qsTr("Enable cloud features")
                description: qsTr("The Curiosity feature needs API keys and access to the Internet. " +
                                  "No data is uploaded without your consent.")
                onClicked: curiosity.useCloud = !curiosity.useCloud
            }

            TextSwitch {
                checked: curiosity.cloudTermsAccepted
                text: qsTr("Accept Microsoft Azure terms and conditions")
                description: qsTr("You have to accept the terms of service and the privacy statement " +
                                  "in order to use this service. More information is given when opening " +
                                  "the Curiosity feature.")
                onClicked: curiosity.cloudTermsAccepted = !curiosity.cloudTermsAccepted
                enabled: useCloud
            }

            TextField {
                id: computerVisionKeyField
                width: parent.width
                placeholderText: qsTr("Azure Computer Vision API Key")
                label: placeholderText
                onTextChanged: curiosity.setComputerVisionKey(text)
                enabled: useCloud
            }

            TextField {
                id: translatorTextKeyField
                width: parent.width
                placeholderText: qsTr("Azure Translator Text API Key")
                label: placeholderText
                onTextChanged: curiosity.setTranslatorTextKey(text)
                enabled: useCloud
            }

            Label {
                id: separatorLabel
                x: Theme.horizontalPageMargin
                width: parent.width  - ( 2 * Theme.horizontalPageMargin )
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            VerticalScrollDecorator {}
        }

    }
}
