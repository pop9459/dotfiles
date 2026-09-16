import "../theme"
import QtQuick
import Quickshell
import Quickshell.Io

PillWidget {
    id: widget

    property bool powered: false
    property string connectedName: ""

    readonly property string bluetoothIcon: {
        if (!widget.powered)
            return "󰂲";
        if (widget.connectedName.length > 0)
            return "󰂱";
        return "󰂯";
    }

    function refreshBluetooth() {
        bluetoothProcess.running = false;
        bluetoothProcess.running = true;
    }

    Process {
        id: bluetoothProcess

        command: ["sh", "-c", "powered=$(bluetoothctl show | awk -F': ' '/^\\tPowered/{print $2; exit}'); if [ \"$powered\" = yes ]; then name=$(bluetoothctl devices Connected | head -n1 | cut -d' ' -f3-); else name=; fi; printf '%s|%s' \"$powered\" \"$name\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                const sep = output.indexOf("|");
                const poweredPart = sep >= 0 ? output.substring(0, sep) : output;
                const namePart = sep >= 0 ? output.substring(sep + 1) : "";
                widget.powered = poweredPart === "yes";
                widget.connectedName = namePart;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: widget.refreshBluetooth()
    }

    Component.onCompleted: widget.refreshBluetooth()

    Process {
        id: bluetuiProcess

        command: ["kitty", "bluetui"]
        running: false
    }

    Text {
        id: bluetoothLabel

        anchors.centerIn: parent
        color: widget.accentColor
        text: widget.connectedName.length > 0 ? `${widget.bluetoothIcon} ${widget.connectedName}` : widget.bluetoothIcon
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 160)

        font {
            family: root.fontFamily
            pixelSize: root.scaledFontSize
            bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: bluetuiProcess.running = true
        }
    }
}
