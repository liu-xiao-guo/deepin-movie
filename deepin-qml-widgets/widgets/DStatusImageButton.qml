/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.1

Item {
    id: button

    property var statusImageList: {}
    property string currentStatus: "undefined"

    property url normal_image: statusImageList[currentStatus][0]
    property url hover_image: statusImageList[currentStatus][1]
    property url press_image: statusImageList[currentStatus][2]

    signal clicked
    
    width: image.width
    height: image.height
    
    Image {
        id: image
        source: normal_image
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { image.source = hover_image }
        onExited: { image.source = normal_image }
        onPressed: { image.source = press_image }
        onReleased: {
            button.clicked()
            image.source= mouseArea.containsMouse ? hover_image : normal_image
        }
    }
}
