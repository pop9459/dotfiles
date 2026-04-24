import "../theme"
import QtQuick
import Quickshell
import Quickshell.Wayland

PillWidget {
    id: widget

    visible: ToplevelManager.activeToplevel.activated

    Text {
        id: activeAppLabel

        anchors.centerIn: parent
        color: widget.accentColor
        text: ToplevelManager.activeToplevel.appId
        font.family: root.fontFamily
        font.pixelSize: root.scaledFontSize
        font.bold: true
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 480)
    }
}
