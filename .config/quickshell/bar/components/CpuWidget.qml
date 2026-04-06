import Quickshell
import QtQuick
import "../theme"

PillWidget {
    property color colorValue: "#e0af68"
    property string fontFamily: "JetBrainsMono Nerd Font Propo"
    property int fontSize: 18
    property int pillPadding: 10
    property int cpuUsage: 0

    padding: pillPadding

    Text {
        anchors.centerIn: parent
        text: "CPU: " + cpuUsage + "%"
        color: colorValue
        font { family: fontFamily; pixelSize: fontSize; bold: true }
    }
}