import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../theme"
import "./components"

PanelWindow {
    id: root

    // Theme
    property color colBg: "#00000000"
    property color colFg: "#a9b1d6"
    property color colMuted: "#444b6a"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property string fontFamily: "JetBrainsMono Nerd Font Propo"
    

    // Responsive scaling based on a 1920x1080 baseline.
    // property real baseWidth: 1920
    // property real baseHeight: 1080
    // readonly property real uiScale: {
    //     const sx = root.width / baseWidth
    //     const sy = Screen.height / baseHeight
    //     return Math.max(0.85, Math.min(Math.min(sx, sy), 1.35))
    // }

    readonly property int scaledFontSize: fontSize
    readonly property int scaledMargin: 10
    readonly property int scaledSpacing: 8
    readonly property int scaledPillPadding: 10
    readonly property int scaledSeparatorHeight: 16
    readonly property int scaledSeparatorWidth: 1
    
    property int fontSize: 18
    
    // System data
    property int cpuUsage: 0
    property int memUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    // Processes and timers here...
    anchors.top: true
    anchors.left: true
    anchors.right: true
    color: root.colBg

    RowLayout {
        id: barContent
        anchors.fill: parent
        anchors.margins: scaledMargin
        spacing: 0

        // Left
        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            implicitHeight: leftRow.implicitHeight

            RowLayout {
                id: leftRow
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: root.scaledSpacing

                WorkspaceWidget { pillIndex: 0 }
            }
        }

        // Center
        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            implicitHeight: centerRow.implicitHeight

            RowLayout {
                id: centerRow
                anchors.centerIn: parent
                spacing: root.scaledSpacing

                ClockWidget { pillIndex: 1 }
            }
        }

        // Right
        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            implicitHeight: rightRow.implicitHeight

            RowLayout {
                id: rightRow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: root.scaledSpacing

                // Add right-side widgets here.
            }
        }
    }

    implicitHeight: barContent.implicitHeight + scaledMargin
}