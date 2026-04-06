import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: wifiButton
    
    color: Colors.base
    border.color: wifiStatus.enabled ? Colors.red : Colors.overlay0  // Fourth in cycle / disabled
    border.width: 2
    radius: 0
    
    implicitWidth: wifiText.implicitWidth + 20
    implicitHeight: 34
    
    property var wifiStatus: ({
        "available": false,
        "enabled": false,
        "connected": false,
        "ssid": "",
        "signal": 0,
        "icon": "󰤭",
        "label": "Wi-Fi N/A",
        "error": ""
    })
    
    property bool panelOpen: false
    
    // Poll WiFi status every 3 seconds
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            wifiStatusProcess.running = true
        }
    }
    
    Process {
        id: wifiStatusProcess
        command: ["python3", Quickshell.env("HOME") + "/.config/eww/scripts/wifi.py", "status"]
        running: false
        
        stdout: SplitParser {
            onRead: function(data) {
                try {
                    var status = JSON.parse(data);
                    wifiButton.wifiStatus = status;
                } catch (e) {
                    console.error("Failed to parse WiFi status:", e);
                }
            }
        }
    }
    
    Text {
        id: wifiText
        anchors.centerIn: parent
        text: wifiButton.wifiStatus.label
        color: wifiButton.wifiStatus.enabled ? Colors.red : Colors.overlay2
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 16
        font.weight: Font.Black
        elide: Text.ElideRight
        
        // Limit width (24 chars as per eww)
        maximumLineCount: 1
        Component.onCompleted: {
            const maxChars = 24;
            if (paintedWidth > maxChars * 10) {  // Rough char width estimate
                width = maxChars * 10;
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            wifiButton.panelOpen = !wifiButton.panelOpen;
            
            if (wifiButton.panelOpen) {
                wifiPanelLoader.active = true;
            } else {
                wifiPanelLoader.active = false;
            }
        }
    }
    
    // Panel loader (created on demand)
    Loader {
        id: wifiPanelLoader
        active: false
        
        sourceComponent: WiFiPanel {
            wifiButtonRect: wifiButton
            onCloseRequested: {
                wifiButton.panelOpen = false;
                wifiPanelLoader.active = false;
            }
        }
    }
}
