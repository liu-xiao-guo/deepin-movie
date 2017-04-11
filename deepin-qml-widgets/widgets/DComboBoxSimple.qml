/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Widgets 1.0

Item {
    id: combobox
    width: Math.max(minMiddleWidth, parent.width)
    height: background.height

    property bool hovered: false
    property bool pressed: false

    property alias text: currentLabel.text

    signal showRequested(int x, int y, int width, int height)

    QtObject {
        id: buttonImage
        property string status: "normal"
        property string header: DPalette.imagesPath + "button_left_%1.png".arg(status)
        property string middle: DPalette.imagesPath + "button_center_%1.png".arg(status)
        property string tail: DPalette.imagesPath + "button_right_%1.png".arg(status)
    }

    property int minMiddleWidth: buttonHeader.width + downArrow.width + buttonTail.width

    Row {
        id: background
        height: buttonHeader.height
        width: parent.width

        Image{
            id: buttonHeader
            source: buttonImage.header
        }

        Image {
            id: buttonMiddle
            source: buttonImage.middle
            width: parent.width - buttonHeader.width - buttonTail.width
        }

        Image{
            id: buttonTail
            source: buttonImage.tail
        }
    }

    Rectangle {
        id: content
        width: buttonMiddle.width
        height: background.height
        anchors.left: parent.left
        anchors.leftMargin: buttonHeader.width
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(1, 0, 0, 0)

        DssH2 {
            id: currentLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - downArrow.width
            elide: Text.ElideRight
        }

        Image {
            id: downArrow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            source: hovered ? DPalette.imagesPath + "arrow_down_hover.png" : DPalette.imagesPath + "arrow_down_normal.png"
        }

    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            parent.hovered = true
        }

        onExited: {
            parent.hovered = false
        }

        onPressed: {
            parent.pressed = true
            buttonImage.status = "press"
        }
        onReleased: {
            parent.pressed = false
            parent.hovered = containsMouse
            buttonImage.status = "normal"
        }

        onClicked: {
            var pos = mapToItem(null, 0, 0)
            var x = pos.x
            var y = pos.y + height
            var w = width
            var h = height
            combobox.showRequested(x, y, w, h)
        }
    }

}
