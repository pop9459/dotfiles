import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PillWidget {
    id: widget

    RowLayout {
        id: sessionControlsRow

        height: widget.contentItem.height
        spacing: 0

        // Power button area
        Rectangle {
            id: powerButton

            property bool hovered: false

            color: powerButton.hovered ? widget.accentColor : Colors.base
            implicitHeight: widget.contentItem.height
            implicitWidth: implicitHeight

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: powerButton.hovered = true
                onExited: powerButton.hovered = false
                onClicked: poweroffProcess.running = true
            }

            Process {
                id: poweroffProcess

                command: ["systemctl", "poweroff"]
                running: false
            }

            // NerdFonts icon
            Text {
                anchors.centerIn: parent
                color: powerButton.hovered ? Colors.base : widget.accentColor
                text: "⏻"
                font.family: root.fontFamily
                font.pixelSize: root.scaledFontSize
                font.bold: true
            }

        }

        // Reboot button area
        Rectangle {
            id: rebootButton

            property bool hovered: false

            color: rebootButton.hovered ? widget.accentColor : Colors.base
            implicitHeight: widget.contentItem.height
            implicitWidth: implicitHeight

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: rebootButton.hovered = true
                onExited: rebootButton.hovered = false
                onClicked: rebootProcess.running = true
            }

            Process {
                id: rebootProcess

                command: ["systemctl", "reboot"]
                running: false
            }

            // NerdFonts icon
            Text {
                anchors.centerIn: parent
                color: rebootButton.hovered ? Colors.base : widget.accentColor
                text: ""
                font.family: root.fontFamily
                font.pixelSize: root.scaledFontSize
                font.bold: true
            }

        }

        // Session lock button area
        Rectangle {
            id: lockButton

            property bool hovered: false

            color: lockButton.hovered ? widget.accentColor : Colors.base
            implicitHeight: widget.contentItem.height
            implicitWidth: implicitHeight

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: lockButton.hovered = true
                onExited: lockButton.hovered = false
                onClicked: lockProcess.running = true
            }

            Process {
                id: lockProcess

                command: ["sh", "-c", "pidof hyprlock >/dev/null || hyprlock || loginctl lock-session"]
                running: false
            }

            // NerdFonts icon
            Text {
                anchors.centerIn: parent
                color: lockButton.hovered ? Colors.base : widget.accentColor
                text: ""
                font.family: root.fontFamily
                font.pixelSize: root.scaledFontSize
                font.bold: true
            }

        }

        // Session suspend button area
        Rectangle {
            id: suspendButton

            property bool hovered: false

            color: suspendButton.hovered ? widget.accentColor : Colors.base
            implicitHeight: widget.contentItem.height
            implicitWidth: implicitHeight

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: suspendButton.hovered = true
                onExited: suspendButton.hovered = false
                onClicked: suspendProcess.running = true
            }

            Process {
                id: suspendProcess

                command: ["systemctl", "suspend"]
                running: false
            }

            // NerdFonts icon
            Text {
                anchors.centerIn: parent
                color: suspendButton.hovered ? Colors.base : widget.accentColor
                text: "󰤄"
                font.family: root.fontFamily
                font.pixelSize: root.scaledFontSize
                font.bold: true
            }

        }

        // Logout button area
        Rectangle {
            id: logoutButton

            property bool hovered: false

            color: logoutButton.hovered ? widget.accentColor : Colors.base
            implicitHeight: widget.contentItem.height
            implicitWidth: implicitHeight

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: logoutButton.hovered = true
                onExited: logoutButton.hovered = false
                onClicked: logoutProcess.running = true
            }

            Process {
                id: logoutProcess

                command: ["hyprctl", "dispatch", "exit"] // Example command for Sway, adjust as needed for your compositor
                running: false
            }

            // NerdFonts icon
            Text {
                anchors.centerIn: parent
                color: logoutButton.hovered ? Colors.base : widget.accentColor
                text: ""
                font.family: root.fontFamily
                font.pixelSize: root.scaledFontSize
                font.bold: true
            }

        }

    }

}
