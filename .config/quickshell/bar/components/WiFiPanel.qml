import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PopupWindow {
    id: wifiPanel
    
    property var wifiButtonRect
    signal closeRequested()
    
    // Position at top-right
    anchor {
        rect.x: screen.width - width - 20
        rect.y: 52  // Below bar
    }
    
    width: 360
    height: 520
    
    visible: true
    color: "transparent"
    
    // Dismiss layer (click outside to close)
    MouseArea {
        anchors.fill: parent
        z: -1
        
        onClicked: {
            wifiPanel.closeRequested();
        }
    }
    
    Rectangle {
        id: panelContent
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        
        width: 360
        height: panelColumn.implicitHeight + 16
        
        color: Colors.base
        border.color: Colors.blue
        border.width: 2
        radius: 0
        
        property var wifiStatus: wifiButtonRect ? wifiButtonRect.wifiStatus : null
        property var wifiNetworks: []
        property string selectedSsidB64: ""
        property string password: ""
        property string message: ""
        property bool refreshing: false
        property string connectSsidB64: ""
        property string connectPassword: ""
        
        // Poll networks every 12 seconds
        Timer {
            interval: 12000
            running: true
            repeat: true
            triggeredOnStart: true
            
            onTriggered: {
                wifiNetworksProcess.running = true
            }
        }
        
        Process {
            id: wifiNetworksProcess
            command: ["python3", Quickshell.env("HOME") + "/.config/eww/scripts/wifi.py", "list"]
            running: false
            
            stdout: SplitParser {
                onRead: function(data) {
                    try {
                        panelContent.wifiNetworks = JSON.parse(data);
                    } catch (e) {
                        console.error("Failed to parse WiFi networks:", e);
                    }
                }
            }
        }
        
        // Reusable processes for WiFi operations
        Process {
            id: wifiToggleProcess
            command: ["python3", Quickshell.env("HOME") + "/.config/eww/scripts/wifi.py", "toggle"]
            running: false
        }
        
        Process {
            id: wifiConnectProcess
            running: false
        }
        
        ColumnLayout {
            id: panelColumn
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 0
                
                Text {
                    Layout.fillWidth: true
                    text: "Wi-Fi"
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 16
                    font.weight: Font.Black
                }
                
                Rectangle {
                    width: 60
                    height: 26
                    color: Colors.mantle
                    border.color: Colors.surface1
                    border.width: 2
                    radius: 0
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰅙"
                        color: Colors.text
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 16
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wifiPanel.closeRequested()
                    }
                }
            }
            
            // Controls row
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                
                // Toggle switch
                Rectangle {
                    width: 70
                    height: 26
                    color: "transparent"
                    
                    Rectangle {
                        id: toggleTrack
                        anchors.centerIn: parent
                        width: 44
                        height: 22
                        
                        property bool isOn: panelContent.wifiStatus && panelContent.wifiStatus.enabled
                        
                        color: isOn ? "#243427" : "#35242a"
                        border.color: isOn ? Colors.green : Colors.red
                        border.width: 2
                        radius: 0
                        
                        Rectangle {
                            id: toggleKnob
                            width: 14
                            height: 14
                            anchors.verticalCenter: parent.verticalCenter
                            x: toggleTrack.isOn ? 26 : 2
                            
                            color: Colors.text
                            radius: 0
                            
                            Behavior on x {
                                NumberAnimation { duration: 200 }
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            wifiToggleProcess.running = true;
                            panelContent.selectedSsidB64 = "";
                            panelContent.password = "";
                        }
                    }
                }
                
                Text {
                    text: (panelContent.wifiStatus && panelContent.wifiStatus.enabled) ? "On" : "Off"
                    color: Colors.subtext1
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 16
                }
                
                Item { Layout.fillWidth: true }
                
                // Refresh button
                Rectangle {
                    width: 60
                    height: 26
                    color: panelContent.refreshing ? Colors.surface0 : Colors.mantle
                    border.color: panelContent.refreshing ? Colors.sky : Colors.surface1
                    border.width: 2
                    radius: 0
                    
                    Text {
                        anchors.centerIn: parent
                        text: panelContent.refreshing ? "󰑐..." : "󰑐"
                        color: panelContent.refreshing ? Colors.sky : Colors.text
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 16
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            panelContent.refreshing = true;
                            wifiNetworksProcess.running = true;
                            refreshTimer.start();
                        }
                    }
                    
                    Timer {
                        id: refreshTimer
                        interval: 800
                        onTriggered: panelContent.refreshing = false
                    }
                }
            }
            
            // Current connection
            Text {
                text: {
                    if (!panelContent.wifiStatus) return "";
                    if (panelContent.wifiStatus.connected) return panelContent.wifiStatus.ssid;
                    if (panelContent.wifiStatus.enabled) return "Not connected";
                    return "Wi-Fi disabled";
                }
                color: Colors.subtext1
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 16
                elide: Text.ElideRight
                Layout.maximumWidth: 320
            }
            
            // Network list
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 350
                clip: true
                
                ColumnLayout {
                    width: parent.width
                    spacing: 0
                    
                    Repeater {
                        model: panelContent.wifiNetworks
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 30
                                
                                color: modelData.active ? Colors.surface0 : Colors.mantle
                                border.color: modelData.active ? Colors.blue : Colors.surface1
                                border.width: 2
                                radius: 0
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    spacing: 4
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: (modelData.active ? "󰄬 " : "") + modelData.ssid
                                        color: Colors.text
                                        font.family: "JetBrainsMono Nerd Font Propo"
                                        font.pixelSize: 16
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        text: modelData.signal + "% " + (modelData.secure ? "󰌾" : "󰌿")
                                        color: Colors.subtext0
                                        font.family: "JetBrainsMono Nerd Font Propo"
                                        font.pixelSize: 16
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    
                                    onEntered: {
                                        if (!modelData.active) parent.color = Colors.surface0;
                                    }
                                    
                                    onExited: {
                                        if (!modelData.active) parent.color = Colors.mantle;
                                    }
                                    
                                    onClicked: {
                                        if (modelData.secure) {
                                            panelContent.selectedSsidB64 = modelData.ssid_b64;
                                            panelContent.password = "";
                                            panelContent.message = "";
                                        } else {
                                            // Connect without password
                                            wifiConnectProcess.command = ["python3", Quickshell.env("HOME") + "/.config/eww/scripts/wifi.py", "connect", "--ssid-b64", modelData.ssid_b64];
                                            wifiConnectProcess.running = true;
                                            panelContent.selectedSsidB64 = "";
                                            panelContent.password = "";
                                            panelContent.message = "Connecting...";
                                        }
                                    }
                                }
                            }
                            
                            // Password input (for secured networks)
                            Rectangle {
                                Layout.fillWidth: true
                                height: panelContent.selectedSsidB64 === modelData.ssid_b64 && modelData.secure ? 34 : 0
                                visible: height > 0
                                color: "transparent"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    spacing: 4
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 26
                                        color: Colors.mantle
                                        border.color: Colors.surface1
                                        border.width: 2
                                        radius: 0
                                        
                                        TextInput {
                                            id: passwordInput
                                            anchors.fill: parent
                                            anchors.margins: 6
                                            color: Colors.text
                                            font.family: "JetBrainsMono Nerd Font Propo"
                                            font.pixelSize: 16
                                            echoMode: TextInput.Password
                                            
                                            onTextChanged: {
                                                panelContent.password = text;
                                            }
                                        }
                                        
                                        Text {
                                            visible: passwordInput.text === ""
                                            anchors.left: parent.left
                                            anchors.leftMargin: 6
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "Password"
                                            color: Colors.overlay2
                                            font.family: "JetBrainsMono Nerd Font Propo"
                                            font.pixelSize: 16
                                        }
                                    }
                                    
                                    Rectangle {
                                        width: 80
                                        height: 26
                                        color: Colors.mantle
                                        border.color: Colors.blue
                                        border.width: 2
                                        radius: 0
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Connect"
                                            color: Colors.blue
                                            font.family: "JetBrainsMono Nerd Font Propo"
                                            font.pixelSize: 16
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            
                                            onClicked: {
                                                wifiConnectProcess.command = ["python3", Quickshell.env("HOME") + "/.config/eww/scripts/wifi.py", "connect", "--ssid-b64", modelData.ssid_b64, "--password", panelContent.password];
                                                wifiConnectProcess.running = true;
                                                panelContent.selectedSsidB64 = "";
                                                panelContent.password = "";
                                                panelContent.message = "Connecting...";
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Message area
            Text {
                visible: panelContent.message !== ""
                text: panelContent.message
                color: Colors.yellow
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 16
                elide: Text.ElideRight
                Layout.maximumWidth: 320
            }
        }
    }
}
