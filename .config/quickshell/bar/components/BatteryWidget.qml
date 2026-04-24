import "../theme"
import QtQuick
import Quickshell
import Quickshell.Io

PillWidget {
    id: widget

    property int batteryPercent: -1
    property string batteryState: "Unknown"
    
    visible: batteryState != "Unknown"
    readonly property string batteryIcon: {
        if (batteryPercent < 0)
            return "󰂃";
        if (batteryState === "Charging")
            return "󰂄";
        if (batteryPercent >= 90)
            return "󰁹";
        if (batteryPercent >= 70)
            return "󰂀";
        if (batteryPercent >= 50)
            return "󰁾";
        if (batteryPercent >= 30)
            return "󰁼";
        if (batteryPercent >= 15)
            return "󰁺";
        return "󰂎";
    }

    function refreshBattery() {
        batteryProcess.running = false;
        batteryProcess.running = true;
    }

    Process {
        id: batteryProcess

        command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*; do [ -d \"$b\" ] || continue; if [ -r \"$b/capacity\" ]; then status=$(cat \"$b/status\" 2>/dev/null || echo Unknown); cap=$(cat \"$b/capacity\" 2>/dev/null || echo -1); printf \"%s %s\\n\" \"$status\" \"$cap\"; exit 0; fi; done; echo \"Unknown -1\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                const parts = output.split(/\s+/);
                widget.batteryState = parts.length > 0 ? parts[0] : "Unknown";
                const parsedPercent = parts.length > 1 ? parseInt(parts[1], 10) : -1;
                widget.batteryPercent = Number.isNaN(parsedPercent) ? -1 : parsedPercent;
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: widget.refreshBattery()
    }

    Component.onCompleted: widget.refreshBattery()

    Text {
        anchors.centerIn: parent
        color: widget.accentColor
        text: widget.batteryPercent >= 0 ? `${widget.batteryIcon} ${widget.batteryPercent}%` : `${widget.batteryIcon} --%`

        font {
            family: root.fontFamily
            pixelSize: root.scaledFontSize
            bold: true
        }
    }
}
