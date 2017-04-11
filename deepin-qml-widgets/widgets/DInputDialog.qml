/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.1
import Deepin.Widgets 1.0

DDialog {
    id: dialog
    width: 362 + shadowWidth * 2
    height: 112 + shadowWidth * 2

    property alias message: msg.text
    property alias confirmButtonLabel: confirm_button.text
    property alias cancelButtonLabel: cancel_button.text

    property alias cursorPosGetter: input.cursorPosGetter

    signal confirmed (string input)
    signal cancelled

    onClosing: { dialog.cancelled(); input.text = ""; }

    function forceFocus() { input.forceActiveFocus() }

    function _accept() {
        dialog.confirmed(input.text)
        input.text = ""
        dialog.close()
    }

    function _deny() {
        dialog.cancelled()
        input.text = ""
        dialog.close()
    }

    Column {
        spacing: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 14
        anchors.rightMargin: 14

        Text {
            id: msg
            text: ""
            color: "white"
            font.pixelSize: 12
        }
        DTextInput {
            id: input
            width: parent.width
            showClearButton: true

            onAccepted: dialog._accept()
        }
        Row {
            spacing: 10
            anchors.right: parent.right

            DTextButton {
                id: cancel_button
                text: "Cancel"

                onClicked: dialog._deny()
            }

            DTextButton {
                id: confirm_button
                text: "Confirm"

                onClicked: dialog._accept()
            }
        }
    }
}