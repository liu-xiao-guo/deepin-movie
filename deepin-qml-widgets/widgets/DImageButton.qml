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

Item {
    id: button
    height: normalImage.width
    width: normalImage.height

    property url normal_image
    property url hover_image
    property url press_image
    property alias containsMouse: mouseArea.containsMouse

    property alias mouseArea: mouseArea
    property alias sourceSize: normalImage.sourceSize

    signal clicked
    signal entered
    signal exited

    property bool pressed: state == "normal"
    property bool transitionEnabled: false
    property int transitionDuration: 300

    state: "normal"

    states: [
        State {
            name: "normal"
            PropertyChanges { target: normalImage; opacity: 1 }
            PropertyChanges { target: hoverImage; opacity: 0 }
            PropertyChanges { target: pressImage; opacity: 0 }
        },
        State {
            name: "hovered"
            PropertyChanges { target: normalImage; opacity: 0 }
            PropertyChanges { target: hoverImage; opacity: 1 }
            PropertyChanges { target: pressImage; opacity: 0 }
        },
        State {
            name: "pressed"
            PropertyChanges { target: normalImage; opacity: 0 }
            PropertyChanges { target: hoverImage; opacity: 0 }
            PropertyChanges { target: pressImage; opacity: 1 }
        }
    ]

    transitions: Transition {
        from: "normal"; to: "hovered"
        reversible: true
        enabled: transitionEnabled
        NumberAnimation { properties: "opacity"; duration: transitionDuration }
    }

    Image {
        id: normalImage
        source: normal_image
        anchors.centerIn: parent
    }

    Image {
        id: hoverImage
        anchors.centerIn: normalImage
        width: normalImage.width
        height: normalImage.height
        source: hover_image
    }

    Image {
        id: pressImage
        anchors.centerIn: normalImage
        width: normalImage.width
        height: normalImage.height
        source: press_image
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { button.state = "hovered"; button.entered() }
        onExited: { button.state = "normal"; button.exited() }
        onPressed: { button.state = "pressed" }
        onReleased: { button.state = mouseArea.containsMouse ? "hovered" : "normal"}
        onClicked: button.clicked()
    }
}
