import Quickshell
import QtQuick
import "../theme"

PillWidget {
    property color colorValue: "#0db9d7"
    property string fontFamily: "JetBrainsMono Nerd Font Propo"
    property int fontSize: 18
    property int pillPadding: 10
    property int memUsage: 0

    padding: pillPadding

    Text {
        anchors.centerIn: parent
        text: "Mem: " + memUsage + "%"
        color: colorValue
        font { family: fontFamily; pixelSize: fontSize; bold: true }
    }
}