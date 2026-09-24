import "../theme"
import QtQuick
import Quickshell
import Quickshell.Io

// One row of the desktop ServiceMonitor. Runs its own periodic check via
// scripts/check_service.sh and exposes the result as `status`.
Item {
    id: row

    property string name: ""
    property string icon: ""
    property string type: ""
    property string target: ""
    property bool user: false
    property int intervalSeconds: 60
    property string fontFamily: "JetBrainsMono Nerd Font Propo"
    property int fontSize: 16

    // "pending" until the first check finishes, then "up" / "down".
    property string status: "pending"
    readonly property color statusColor: status === "up" ? Colors.green : status === "down" ? Colors.red : Colors.overlay0

    function refresh() {
        checkProcess.running = false;
        checkProcess.running = true;
    }

    onStatusChanged: {
        if (row.status !== "down")
            statusDot.opacity = 1;
    }

    implicitHeight: rowContent.implicitHeight

    Process {
        id: checkProcess

        command: ["bash", Quickshell.shellPath("scripts/check_service.sh"), row.type, row.target, row.user ? "user" : ""]
        stdout: StdioCollector {
            onStreamFinished: row.status = this.text.trim() === "up" ? "up" : "down"
        }
    }

    Timer {
        interval: Math.max(5, row.intervalSeconds) * 1000
        running: true
        repeat: true
        onTriggered: row.refresh()
    }

    Component.onCompleted: row.refresh()

    Row {
        id: rowContent

        anchors.left: parent.left
        anchors.right: statusLabel.left
        anchors.rightMargin: 8
        spacing: 8

        Text {
            id: statusDot

            color: row.statusColor
            text: "■"
            font { family: row.fontFamily; pixelSize: row.fontSize; bold: true }

            Behavior on color {
                ColorAnimation { duration: 300 }
            }

            // Pulse only while down, so failures stand out.
            SequentialAnimation on opacity {
                running: row.status === "down"
                loops: Animation.Infinite

                NumberAnimation { to: 0.25; duration: 700; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1; duration: 700; easing.type: Easing.InOutSine }
            }
        }

        Text {
            color: Colors.subtext1
            text: row.icon
            width: row.fontSize
            horizontalAlignment: Text.AlignHCenter
            font { family: row.fontFamily; pixelSize: row.fontSize; bold: true }
        }

        Text {
            width: rowContent.width - x
            color: Colors.text
            text: row.name
            elide: Text.ElideRight
            font { family: row.fontFamily; pixelSize: row.fontSize; bold: true }
        }
    }

    Text {
        id: statusLabel

        anchors.right: parent.right
        anchors.verticalCenter: rowContent.verticalCenter
        color: row.statusColor
        text: row.status === "pending" ? "···" : row.status
        font { family: row.fontFamily; pixelSize: row.fontSize; bold: true }

        Behavior on color {
            ColorAnimation { duration: 300 }
        }
    }
}
