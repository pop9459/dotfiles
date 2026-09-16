import "../theme"
import QtQuick
import Quickshell
import Quickshell.Io

PillWidget {
    id: widget

    // PillWidget's own implicitWidth is derived from contentRoot.childrenRect,
    // which is circular (content is centered within contentRoot, whose size
    // derives from that same content) - harmless for static content, but an
    // animated width feeding through that chain gets silently suppressed by
    // Qt's binding-loop breaker. Set width explicitly here instead, computed
    // from the labels' own implicitWidth (leaf values, non-circular), so it
    // can be animated safely without touching PillWidget.qml.
    width: wifiIconLabel.implicitWidth
        + (showLabel ? (6 + Math.min(wifiLabelText.implicitWidth, 160)) : 0)
        + (padding * 2) + (extraSideMargin ? extraSideMarginSize : 0)

    Behavior on width {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    property bool connected: false
    property string ssid: ""
    property int signalStrength: -1
    property bool showLabel: false

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

    function revealLabel() {
        widget.showLabel = true;
        revealTimer.restart();
    }

    onConnectedChanged: {
        if (widget.connected)
            widget.revealLabel();
    }

    onSsidChanged: {
        if (widget.connected)
            widget.revealLabel();
    }

    Timer {
        id: revealTimer

        interval: 4000
        running: false
        repeat: false
        onTriggered: widget.showLabel = false
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

    Process {
        id: nmtuiProcess

        command: ["kitty", "nmtui"]
        running: false
    }

    Row {
        id: wifiRow

        anchors.centerIn: parent
        spacing: widget.showLabel ? 6 : 0

        Behavior on spacing {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        Text {
            id: wifiIconLabel

            color: widget.accentColor
            text: widget.wifiIcon

            font {
                family: root.fontFamily
                pixelSize: root.scaledFontSize
                bold: true
            }
        }

        Item {
            id: wifiLabelClip

            clip: true
            height: wifiIconLabel.height
            width: widget.showLabel ? Math.min(wifiLabelText.implicitWidth, 160) : 0

            Behavior on width {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }

            Text {
                id: wifiLabelText

                color: widget.accentColor
                text: widget.ssid
                elide: Text.ElideRight
                width: 160

                font {
                    family: root.fontFamily
                    pixelSize: root.scaledFontSize
                    bold: true
                }
            }
        }
    }

    MouseArea {
        anchors.fill: wifiRow
        cursorShape: Qt.PointingHandCursor
        onClicked: nmtuiProcess.running = true
    }
}
