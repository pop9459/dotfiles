import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: workspacesContainer
    
    color: Colors.base
    border.color: Colors.blue
    border.width: 2
    radius: 0
    
    implicitWidth: workspaceRow.implicitWidth + 8
    implicitHeight: 34
    
    property var workspaceData: []
    property int activeWorkspace: 1
    
    // Monitor Hyprland socket for workspace changes
    Process {
        id: workspaceMonitor
        command: ["bash", "-c", "socat -U UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock STDOUT"]
        running: true
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: function(data) {
                // Reload workspace data on any workspace event
                if (data.includes("workspace>>") || data.includes("createworkspace>>") || data.includes("destroyworkspace>>")) {
                    updateWorkspaces.running = true;
                }
            }
        }
    }
    
    // Get initial workspace state
    Process {
        id: initialWorkspaces
        command: ["bash", "-c", "hyprctl workspaces -j | jq -r '.[].id' | sort -n"]
        running: true
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: function(data) {
                if (data.trim() !== "") {
                    var wsIds = data.trim().split("\n").map(Number).filter(function(n) { return !isNaN(n); });
                    if (wsIds.length > 0) {
                        workspaceData = wsIds;
                        updateActiveWorkspace.running = true;
                    }
                }
            }
        }
    }
    
    // Get active workspace
    Process {
        id: updateActiveWorkspace
        command: ["bash", "-c", "hyprctl activeworkspace -j | jq -r '.id'"]
        running: false
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: function(data) {
                if (data.trim() !== "") {
                    activeWorkspace = parseInt(data.trim());
                }
            }
        }
    }
    
    // Update workspace list
    Process {
        id: updateWorkspaces
        command: ["bash", "-c", "hyprctl workspaces -j | jq -r '.[].id' | sort -n"]
        running: false
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: function(data) {
                if (data.trim() !== "") {
                    var wsIds = data.trim().split("\n").map(Number).filter(function(n) { return !isNaN(n); });
                    if (wsIds.length > 0) {
                        workspaceData = wsIds;
                        updateActiveWorkspace.running = true;
                    }
                }
            }
        }
    }
    
    // Workspace switch process (reusable)
    Process {
        id: switchWorkspace
        running: false
    }
    
    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 4
        
        Repeater {
            model: workspaceData
            
            Rectangle {
                id: workspaceButton
                
                width: 26
                height: 26
                radius: 0
                
                property bool isActive: modelData === activeWorkspace
                
                color: isActive ? Colors.blue : Colors.base
                border.color: Colors.blue
                border.width: 2
                
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: isActive ? Colors.base : Colors.blue
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 16
                    font.weight: Font.Black
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    
                    onEntered: {
                        if (!parent.isActive) {
                            parent.color = Colors.surface1;
                        }
                    }
                    
                    onExited: {
                        if (!parent.isActive) {
                            parent.color = Colors.base;
                        }
                    }
                    
                    onClicked: {
                        // Execute workspace switch command
                        switchWorkspace.command = ["hyprctl", "dispatch", "workspace", modelData.toString()];
                        switchWorkspace.running = true;
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}
