import "../theme"
import QtQuick
import Quickshell

PillWidget {
    id: widget

    property int spacingSize: widget.padding

    Text {
        id: clock

        color: widget.accentColor
        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "dd/MM")

        font {
            family: root.fontFamily
            pixelSize: root.scaledFontSize
            bold: true
        }

    }

}
