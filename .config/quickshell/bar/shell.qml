import "../theme"
import "./components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

Scope {
    // Variants is used here to create a separate PanelWindow for each screen, as Wayland doesn't allow a single window to span multiple screens.
    Variants {
        model: Quickshell.screens

        delegate: Component {
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
                readonly property int scaledFontSize: fontSize
                readonly property int scaledMargin: 10 // Bar outside margin - same as hyprland's outer gap size for consistency
                readonly property int scaledSpacing: 8
                property int fontSize: 18
                property int barHeight: 38

                anchors.top: true
                anchors.left: true
                anchors.right: true
                color: root.colBg
                implicitHeight: root.barHeight + root.scaledMargin // One margin here and the other one is done with the anchors.margins of the content

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
                            WorkspaceWidget {
                                pillIndex: 0
                            }

                            id: leftRow

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: root.scaledSpacing
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

                            DateWidget {
                                pillIndex: 1
                            }

                            ClockWidget {
                                pillIndex: 2
                            }

                        }

                    }

                    // Right
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        implicitHeight: rightRow.implicitHeight

                        RowLayout {
                            // Add right-side widgets here.

                            id: rightRow

                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: root.scaledSpacing
                        }

                    }

                }

            }

        }

    }

    // Processes and timers here...
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            clock.text = Qt.formatDateTime(new Date(), "HH:mm");
            date.text = Qt.formatDateTime(new Date(), "dd/MM");
        }
    }

}
