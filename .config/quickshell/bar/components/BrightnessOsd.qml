import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Scope {
    id: root

    required property QtObject panelWindow
    readonly property int borderWidth: panelWindow ? panelWindow.borderWidth : 2
    readonly property int barHeight: panelWindow ? panelWindow.barHeight : 38
    readonly property string fontFamily: panelWindow ? panelWindow.fontFamily : "JetBrainsMono Nerd Font Propo"
    readonly property int scaledFontSize: panelWindow ? panelWindow.scaledFontSize : 18

    property bool popupVisible: false
    property int brightnessPercent: 0
    readonly property real brightnessRatio: Math.max(0, Math.min(1, brightnessPercent / 100.0))
    readonly property string brightnessIcon: {
        if (brightnessPercent <= 20)
            return "󰃞";
        if (brightnessPercent <= 60)
            return "󰃟";
        return "󰃠";
    }

    function refreshBrightness() {
        if (brightnessProcess.running)
            return;

        brightnessProcess.running = true;
    }

    function show() {
        popupVisible = true;
        hideTimer.restart();
        refreshBrightness();
    }

    IpcHandler {
        target: "brightness"

        function popup() {
            root.show();
        }
    }

    Process {
        id: brightnessProcess

        command: ["sh", "-c", "brightnessctl -m 2>/dev/null | awk -F, 'NR==1{gsub(/%/,\"\",$4); print $4; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parsedPercent = parseInt(this.text.trim(), 10);
                if (!Number.isNaN(parsedPercent))
                    root.brightnessPercent = Math.max(0, Math.min(100, parsedPercent));
            }
        }
    }

    Component.onCompleted: root.refreshBrightness()

    Timer {
        id: hideTimer

        interval: 1400
        repeat: false
        onTriggered: root.popupVisible = false
    }

    PopupWindow {
        id: popup

        anchor.window: root.panelWindow
        anchor.rect.x: Math.round((root.panelWindow.width - implicitWidth) / 2)
        anchor.rect.y: Math.max(
            0,
            (root.panelWindow.screen ? root.panelWindow.screen.height : root.panelWindow.height) - implicitHeight - 94
        )
        color: "transparent"
        visible: root.popupVisible
        implicitWidth: 300
        implicitHeight: root.barHeight

        PillWidget {
            id: osdPill
            anchors.fill: parent
            pillIndex: 2
            extraSideMargin: true

            RowLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: root.scaledFontSize * 2.5
                    color: osdPill.accentColor
                    text: root.brightnessIcon
                    font.family: root.fontFamily
                    font.pixelSize: root.scaledFontSize
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.scaledFontSize
                    Layout.alignment: Qt.AlignVCenter
                    color: Colors.surface1
                    radius: 0

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: Math.round(parent.width * root.brightnessRatio)
                        color: osdPill.accentColor
                        radius: 0
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: root.scaledFontSize * 2.5
                    color: osdPill.accentColor
                    text: root.brightnessPercent
                    font.family: root.fontFamily
                    font.pixelSize: root.scaledFontSize
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
