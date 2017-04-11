/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.1
import QtGraphicalEffects 1.0
import Deepin.Widgets 1.0

Item {
    id: root

    //switch visible height: 18,visible width 28,44 and 22 is with padding
    width: 44
    height: 22

    property color leftTopColor: DPalette.switchButtonStyle.leftTopColor
    property color leftBottomColor: DPalette.switchButtonStyle.leftBottomColor
    property color rightTopColor: DPalette.switchButtonStyle.rightTopColor
    property color rightBottomColor: DPalette.switchButtonStyle.rightBottomColor
    property color frameOnColor: DPalette.switchButtonStyle.frameOnColor
    property color frameOffColor: DPalette.switchButtonStyle.frameOffColor
    property int frameWidth: DPalette.switchButtonStyle.frameWidth
    property var shapeStyle: DPalette.switchButtonStyle.shape

    property bool checked: false
    property bool enabled: true

    state: { enabled ? checked ? "on" : "off" : "disabled" }

    signal clicked

    transitions: Transition {
        NumberAnimation { properties: "x"; duration: 150; easing.type: Easing.InOutQuad }
    }

    Rectangle {
        id: mask
        width: 36
        height: 18
        radius: 9

        anchors.centerIn: parent
    }

    Item {
        id: innerItem

        width: 36
        height: 18
        antialiasing: false
        anchors.verticalCenter: parent.verticalCenter
        x: 0

        Rectangle {
            id: leftRec
            width: parent.width / 2 + shapeRec.width / 2
            height: parent.height
            gradient: Gradient {
                GradientStop { position: 0; color: leftTopColor }
                GradientStop { position: 1; color: leftBottomColor }
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: rightRec
            width: parent.width / 2 + shapeRec.width / 2
            height: parent.height
            gradient: Gradient {
                GradientStop { position: 0; color: rightTopColor }
                GradientStop { position: 1; color: rightBottomColor }
            }
            anchors.left: leftRec.right
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: shapeRec
            height: parent.height
            width: height
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            x: rightRec.x - width / 2
            border.width: 1
            border.color: root.state == "on" ? shapeStyle.border.outOnColor : shapeStyle.border.outOffColor
            gradient: Gradient {
                GradientStop { position: 0; color: shapeStyle.topColor }
                GradientStop { position: 0.94; color: shapeStyle.bottomColor }
            }

            Rectangle {
                width: parent.width - 2
                height: parent.height - 2
                radius: height / 2
                anchors.centerIn: parent
                border.color: root.state == "on" ? shapeStyle.border.innerOnColor : shapeStyle.border.innerOffColor
                border.width: 1
                color: "#00000000"
            }
        }
    }

    OpacityMask {
        anchors.fill: mask
        source: ShaderEffectSource { sourceItem: innerItem; hideSource: true }
        maskSource: ShaderEffectSource { sourceItem: mask; hideSource: true }
    }

    Rectangle {
        id:frameRec
        height: 18
        width: 36
        radius: 9
        border.color: root.state == "on" ? frameOnColor : frameOffColor
        border.width: frameWidth
        color: "#00000000"
        anchors.centerIn: mask
    }

    DropShadow {
        z: -2
        anchors.fill: frameRec
        horizontalOffset: 0
        verticalOffset: 1
        radius: 0
        samples: 16
        color: Qt.rgba(255,255,255,0.05)
        source: frameRec
    }

    states:  [
        State {
            name: "on"
            PropertyChanges { target: leftRec; x: 0}
            PropertyChanges { target: leftRec; opacity: 1}
            PropertyChanges { target: rightRec; opacity: 1}
            PropertyChanges { target: mouse_area; enabled: true }
        },
        State {
            name: "off"
            PropertyChanges { target: leftRec; x: -leftRec.width + shapeRec.width / 2}
            PropertyChanges { target: leftRec; opacity: 1}
            PropertyChanges { target: rightRec; opacity: 1}
            PropertyChanges { target: mouse_area; enabled: true }
        },
        State {
            name: "disabled"
            PropertyChanges { target: leftRec; x: leftRec.x}
            PropertyChanges { target: leftRec; opacity: 0.5}
            PropertyChanges { target: rightRec; opacity: 0.5}
            PropertyChanges { target: mouse_area; enabled: false }
        }
    ]

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        visible: enabled

        onClicked: {
            checked = !checked
            root.clicked()
        }
    }
}
