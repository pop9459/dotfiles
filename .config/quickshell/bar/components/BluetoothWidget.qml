import "../theme"
import QtQuick
import Quickshell
import Quickshell.Io

PillWidget {
    id: widget

    // See WifiWidget.qml for why width is set explicitly here instead of
    // relying on PillWidget's own (circular, animation-hostile) implicitWidth.
    width: bluetoothIconLabel.width
        + (showLabel ? (6 + Math.min(bluetoothLabelText.implicitWidth, 160)) : 0)
        + (padding * 2) + (extraSideMargin ? extraSideMarginSize : 0)

    Behavior on width {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    property bool powered: false
    property string connectedName: ""
    property bool showLabel: false

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

    function revealLabel() {
        widget.showLabel = true;
        revealTimer.restart();
    }

    onConnectedNameChanged: {
        if (widget.connectedName.length > 0)
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

    Row {
        id: bluetoothRow

        anchors.centerIn: parent
        spacing: widget.showLabel ? 6 : 0

        Behavior on spacing {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        Item {
            id: bluetoothLabelClip

            clip: true
            height: bluetoothIconLabel.height
            width: widget.showLabel ? Math.min(bluetoothLabelText.implicitWidth, 160) : 0

            Behavior on width {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }

            Text {
                id: bluetoothLabelText

                anchors.right: parent.right
                color: widget.accentColor
                text: widget.connectedName
                elide: Text.ElideLeft
                width: Math.min(implicitWidth, 160)

                font {
                    family: root.fontFamily
                    pixelSize: root.scaledFontSize
                    bold: true
                }
            }
        }

        Text {
            id: bluetoothIconLabel

            color: widget.accentColor
            text: widget.bluetoothIcon
            width: height
            horizontalAlignment: Text.AlignHCenter

            font {
                family: root.fontFamily
                pixelSize: root.scaledFontSize
                bold: true
            }
        }
    }

    MouseArea {
        anchors.fill: bluetoothRow
        cursorShape: Qt.PointingHandCursor
        onClicked: bluetuiProcess.running = true
    }
}
