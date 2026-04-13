import "../theme"
import QtQuick
import Quickshell

PillWidget {
    id: widget

    property int spacingSize: widget.padding

    function refresh() {
        dateLabel.text = Qt.formatDateTime(new Date(), "dd/MM");
    }

    Component.onCompleted: refresh()

    Text {
        id: dateLabel

        color: widget.accentColor
        anchors.centerIn: parent
        text: "00/00"
        font.family: root.fontFamily
        font.pixelSize: root.scaledFontSize
        font.bold: true
    }

}
