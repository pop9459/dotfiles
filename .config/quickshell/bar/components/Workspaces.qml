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
    property var workspaceBuffer: []
    
    // Timer to refresh workspaces periodically
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            refreshWorkspaces.running = true;
        }
    }
    
    // Get workspace list and active workspace
    Process {
        id: refreshWorkspaces
        command: ["bash", "-c", "hyprctl workspaces -j | jq -r '.[].id' | sort -n | tr '\\n' ',' && echo && hyprctl activeworkspace -j | jq -r '.id'"]
        running: false
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            property int lineCount: 0
            
            onRead: function(data) {
                if (data.trim() !== "") {
                    if (lineCount === 0) {
                        // First line: comma-separated workspace IDs
                        var wsIds = data.trim().split(',').map(Number).filter(function(n) { return !isNaN(n); });
                        if (wsIds.length > 0) {
                            workspaceData = wsIds;
                        }
                        lineCount = 1;
                    } else {
                        // Second line: active workspace ID
                        var activeId = parseInt(data.trim());
                        if (!isNaN(activeId)) {
                            activeWorkspace = activeId;
                        }
                        lineCount = 0;
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
