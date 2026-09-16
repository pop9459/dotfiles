import "../theme"
import QtQuick
import Quickshell
import Quickshell.Io

PillWidget {
    id: widget

    property bool connected: false
    property string ssid: ""
    property int signalStrength: -1

    readonly property string wifiIcon: {
        if (!widget.connected)
            return "󰤭";
        if (widget.signalStrength >= 80)
            return "󰤨";
        if (widget.signalStrength >= 60)
            return "󰤥";
        if (widget.signalStrength >= 40)
            return "󰤢";
        if (widget.signalStrength >= 20)
            return "󰤟";
        return "󰤯";
    }

    function refreshWifi() {
        wifiProcess.running = false;
        wifiProcess.running = true;
    }

    Process {
        id: wifiProcess

        command: ["sh", "-c", "nmcli -t -f active,signal,ssid dev wifi list --rescan no 2>/dev/null | awk -F: '$1==\"yes\"{print $2\":\"$3; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                if (output.length === 0) {
                    widget.connected = false;
                    widget.ssid = "";
                    widget.signalStrength = -1;
                    return;
                }
                const sep = output.indexOf(":");
                const signalPart = sep >= 0 ? output.substring(0, sep) : output;
                const ssidPart = sep >= 0 ? output.substring(sep + 1) : "";
                const parsedSignal = parseInt(signalPart, 10);
                widget.connected = true;
                widget.signalStrength = Number.isNaN(parsedSignal) ? -1 : parsedSignal;
                widget.ssid = ssidPart;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: widget.refreshWifi()
    }

    Component.onCompleted: widget.refreshWifi()

    Text {
        anchors.centerIn: parent
        color: widget.accentColor
        text: widget.connected ? `${widget.wifiIcon} ${widget.ssid}` : widget.wifiIcon
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 160)

        font {
            family: root.fontFamily
            pixelSize: root.scaledFontSize
            bold: true
        }
    }
}
