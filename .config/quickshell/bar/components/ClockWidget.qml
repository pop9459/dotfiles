import "../theme"
import QtQuick
import Quickshell

PillWidget {
    id: widget

    property int spacingSize: widget.padding

    function refresh() {
        clock.text = Qt.formatDateTime(new Date(), "HH:mm");
    }

    Component.onCompleted: refresh()

    Text {
        id: clock

        color: widget.accentColor
        anchors.centerIn: parent
        text: "00:00"
        font.family: root.fontFamily
        font.pixelSize: root.scaledFontSize
        font.bold: true
    }

}
