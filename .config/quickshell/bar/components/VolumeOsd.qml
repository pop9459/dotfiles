import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    required property QtObject panelWindow
    readonly property int borderWidth: panelWindow ? panelWindow.borderWidth : 2
    readonly property int barHeight: panelWindow ? panelWindow.barHeight : 38
    readonly property string fontFamily: panelWindow ? panelWindow.fontFamily : "JetBrainsMono Nerd Font Propo"
    readonly property int scaledFontSize: panelWindow ? panelWindow.scaledFontSize : 18

    property bool popupVisible: false
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property real volume: sink && sink.audio ? Math.max(0, Math.min(1, sink.audio.volume)) : 0
    readonly property int volumePercent: Math.round((muted ? 0 : volume) * 100)
    readonly property string volumeIcon: {
        if (muted || volumePercent <= 0)
            return "󰝟";
        if (volumePercent < 35)
            return "󰕿";
        if (volumePercent < 70)
            return "󰖀";
        return "󰕾";
    }

    function show() {
        if (!sink || !sink.audio)
            return;

        popupVisible = true;
        hideTimer.restart();
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: root.sink && root.sink.audio ? root.sink.audio : null

        function onVolumeChanged() {
            root.show();
        }

        function onMutedChanged() {
            root.show();
        }
    }

    Connections {
        target: Pipewire

        function onDefaultAudioSinkChanged() {
            root.show();
        }
    }

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
            pillIndex: 1
            extraSideMargin: true

            StackLayout {
                anchors.fill: parent
                currentIndex: root.muted ? 1 : 0

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.fill: parent

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: root.scaledFontSize * 2.5
                            color: osdPill.accentColor
                            text: root.volumeIcon
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
                                width: Math.round(parent.width * root.volume)
                                color: osdPill.accentColor
                                radius: 0
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: root.scaledFontSize * 2.5
                            color: osdPill.accentColor
                            text: root.volumePercent 
                            font.family: root.fontFamily
                            font.pixelSize: root.scaledFontSize 
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        anchors.centerIn: parent
                        color: osdPill.accentColor
                        text: "Muted"
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
