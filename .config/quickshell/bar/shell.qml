import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "components"
import "theme"

ShellRoot {
    PanelWindow {
        id: bar
        
        anchors {
            top: true
            left: true
            right: true
        }
        
        implicitHeight: 42  // 32px bar + 10px top padding
        margins {
            top: 0
            left: 0
            right: 0
        }
        
        color: "transparent"
        
        Rectangle {
            id: barBackground
            anchors.fill: parent
            anchors.topMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            color: "transparent"
            
            RowLayout {
                id: barLayout
                anchors.fill: parent
                spacing: 0
                
                // Left section
                RowLayout {
                    id: leftSection
                    Layout.alignment: Qt.AlignLeft
                    spacing: 10
                    
                    Workspaces {
                        id: workspaces
                    }
                }
                
                // Spacer to push center to middle
                Item {
                    Layout.fillWidth: true
                }
                
                // Center section
                RowLayout {
                    id: centerSection
                    Layout.alignment: Qt.AlignCenter
                    spacing: 10
                    
                    Clock {
                        id: clock
                    }
                }
                
                // Spacer to push right to end
                Item {
                    Layout.fillWidth: true
                }
                
                // Right section
                RowLayout {
                    id: rightSection
                    Layout.alignment: Qt.AlignRight
                    spacing: 10
                    
                    WiFiButton {
                        id: wifiButton
                    }
                }
            }
        }
    }
}
