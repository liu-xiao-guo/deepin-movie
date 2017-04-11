/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Deepin.Widgets 1.0

Item{
    id: expandRect

    property alias header: header
    property alias content: content
    property alias headerData: header.componentData
    property alias contentData: content.componentData
    property alias headerRect: headerRect
    property alias contentRect: contentRect
    property alias separator: separator
    property bool expanded: false

    height: headerRect.height + contentRect.height
    width: parent.width

    signal contentLoaded

    Column {
        width: parent.width

        Rectangle {
            id: headerRect
            width: parent.width
            height: 28
            clip: true
            color: DPalette.panelBgColor

            Loader {
                id: header
                width: headerRect.width
                property var componentData: undefined
                anchors.verticalCenter: parent.verticalCenter
                property alias root: expandRect
            }
        }


        Rectangle {
            id: contentRect
            width: parent.width
            height: expanded ? content.height + 2 : 0
            clip: true
            color: DPalette.contentBgColor

            Column {
                width: parent.width
                DSeparatorHorizontal {
                    id: separator
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Loader {
                    id: content
                    clip: true
                    width: headerRect.width
                    property var componentData: undefined
                    property alias root: expandRect
                    height: sourceComponent.height
                    onLoaded: {
                        expandRect.contentLoaded()
                    }
                }
            }

            Behavior on height {
                SmoothedAnimation { duration: 200 }
            }
        }

        //DSeparatorHorizontal { visible: expanded }
    }
}

