import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: volumeOsd

    required property QtObject panelWindow

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
        target: volumeOsd.sink && volumeOsd.sink.audio ? volumeOsd.sink.audio : null

        function onVolumeChanged() {
            volumeOsd.show();
        }

        function onMutedChanged() {
            volumeOsd.show();
        }
    }

    Connections {
        target: Pipewire

        function onDefaultAudioSinkChanged() {
            volumeOsd.show();
        }
    }

    Timer {
        id: hideTimer

        interval: 1400
        repeat: false
        onTriggered: volumeOsd.popupVisible = false
    }

    PopupWindow {
        id: popup

        anchor.window: volumeOsd.panelWindow
        anchor.rect.x: Math.round((volumeOsd.panelWindow.width - implicitWidth) / 2)
        anchor.rect.y: Math.max(
            0,
            (volumeOsd.panelWindow.screen ? volumeOsd.panelWindow.screen.height : volumeOsd.panelWindow.height) - implicitHeight - 96 
        )
        color: "transparent"
        visible: volumeOsd.popupVisible
        implicitWidth: 260
        implicitHeight: 72

        Rectangle {
            anchors.fill: parent
            color: Colors.base
            border.color: Colors.cycleColor(1)
            border.width: 2
            radius: 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        color: Colors.cycleColor(1)
                        text: volumeOsd.volumeIcon
                        font.family: volumeOsd.panelWindow.fontFamily
                        font.pixelSize: volumeOsd.panelWindow.scaledFontSize
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        color: Colors.text
                        text: volumeOsd.muted ? "Muted" : "Volume " + volumeOsd.volumePercent + "%"
                        font.family: volumeOsd.panelWindow.fontFamily
                        font.pixelSize: volumeOsd.panelWindow.scaledFontSize - 2
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    color: Colors.surface1
                    radius: 0

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: Math.round(parent.width * (volumeOsd.muted ? 0 : volumeOsd.volume))
                        color: Colors.cycleColor(1)
                        radius: 0
                    }
                }
            }
        }
    }
}
