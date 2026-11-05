import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// 20-20-20 rule: every 20 min, look 20 ft away for 20 s. Plays a sound when done.
// Single instance (outside the per-screen bar Variants) so the sound plays once.
Scope {
    id: root

    // Pill styling (PillWidget reads root.borderWidth / root.barHeight)
    readonly property int borderWidth: 2
    readonly property int barHeight: 38
    readonly property int scaledFontSize: 18
    readonly property string fontFamily: "JetBrainsMono Nerd Font Propo"

    readonly property int workMinutes: 20
    readonly property int breakSeconds: 20
    readonly property string doneSound: "/usr/share/sounds/freedesktop/stereo/complete.oga"

    // "idle" | "break" | "done"
    property string phase: "idle"
    property int remaining: breakSeconds

    function startBreak() {
        remaining = breakSeconds;
        phase = "break";
        tick.restart();
        workTimer.stop();
    }

    function finishBreak() {
        tick.stop();
        phase = "done";
        sound.running = false;
        sound.running = true;
        doneTimer.restart();
        workTimer.restart();
    }

    Timer {
        id: workTimer

        interval: root.workMinutes * 60 * 1000
        running: true
        repeat: false
        onTriggered: root.startBreak()
    }

    Timer {
        id: tick

        interval: 1000
        repeat: true
        onTriggered: {
            root.remaining -= 1;
            if (root.remaining <= 0)
                root.finishBreak();
        }
    }

    Timer {
        id: doneTimer

        interval: 3000
        repeat: false
        onTriggered: root.phase = "idle"
    }

    Process {
        id: sound

        command: ["paplay", root.doneSound]
    }

    IpcHandler {
        target: "eyebreak"

        function start() {
            root.startBreak();
        }

        function skip() {
            tick.stop();
            doneTimer.stop();
            root.phase = "idle";
            workTimer.restart();
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData

                screen: modelData
                color: "transparent"
                visible: root.phase !== "idle"
                focusable: false
                implicitHeight: root.barHeight

                anchors {
                    bottom: true
                    left: true
                    right: true
                }
                margins.bottom: 94

                WlrLayershell.layer: WlrLayer.Overlay
                exclusionMode: ExclusionMode.Ignore

                mask: Region {
                    item: pill
                }

                PillWidget {
                    id: pill

                    anchors.centerIn: parent
                    width: 380
                    height: root.barHeight
                    pillIndex: root.phase === "done" ? 2 : 1
                    extraSideMargin: true

                    RowLayout {
                        anchors.fill: parent

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: root.scaledFontSize * 2.5
                            color: pill.accentColor
                            text: root.phase === "done" ? "󰄬" : "󰈈"
                            font.family: root.fontFamily
                            font.pixelSize: root.scaledFontSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            color: pill.accentColor
                            text: root.phase === "done" ? "You can look back" : "Look 20 ft away"
                            font.family: root.fontFamily
                            font.pixelSize: root.scaledFontSize
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: root.scaledFontSize * 2.5
                            color: pill.accentColor
                            text: root.phase === "done" ? "" : root.remaining
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
    }
}
