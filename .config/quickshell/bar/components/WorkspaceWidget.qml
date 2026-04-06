import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../theme"

PillWidget {
    id: widget

    property int badgeSize: 28
    property int spacingSize: widget.padding
    readonly property var visibleWorkspaces: Hyprland.workspaces.values
        .filter(w => w && w.id > 0)
        .sort((a, b) => a.id - b.id)
    
    RowLayout {
        anchors.centerIn: parent
        spacing: widget.spacingSize

        Repeater {
            model: widget.visibleWorkspaces
            Rectangle {
                property var ws: modelData
                property int wsId: ws.id
                property bool isActive: Hyprland.focusedWorkspace?.id === wsId
                
                width: widget.badgeSize
                height: widget.badgeSize

                color: isActive ? widget.accentColor : Colors.base 
                
                Text {
                    anchors.centerIn: parent

                    text: wsId
                    color: isActive ? Colors.base : widget.accentColor
                    font { family: root.fontFamily; pixelSize: root.scaledFontSize; bold: true }
                    
                    Layout.alignment: Qt.AlignVCenter 
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + wsId)
                    }
                }
            }
        }
    }
}