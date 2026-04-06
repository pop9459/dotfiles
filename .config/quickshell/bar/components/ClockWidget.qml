import Quickshell
import QtQuick
import "../theme"

PillWidget {
    id : widget

    property int badgeSize: 28
    property int spacingSize: widget.padding

    padding: 8

    Text {
        id: clock
        color: widget.accentColor
        anchors.centerIn: parent
        font { family: root.fontFamily; pixelSize: root.scaledFontSize; bold: true }
        text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
        }
    }
}