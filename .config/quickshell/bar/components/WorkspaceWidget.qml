import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PillWidget {
    id: widget

    // The content of the workspace widget is a horizontal row of workspace indicators
    RowLayout {
        id: workspaceRow

        height: widget.contentItem.height
        spacing: widget.textMargin
    
        Repeater {
            model: Hyprland.workspaces

            // Each workspace is represented as a colored rectangle with its ID number
            delegate: Rectangle {
                required property var modelData // The workspace object from the model
                property bool isActive: Hyprland.focusedWorkspace?.id === modelData.id // Check if this workspace is the currently focused one

                color: isActive ? widget.accentColor : Colors.base
                implicitHeight: widget.contentItem.height
                implicitWidth: implicitHeight

                // Number indicating workspace ID
                Text {
                    anchors.centerIn: parent
                    color: isActive ?  Colors.base : widget.accentColor
                    text: String(modelData.id)
                    font.family: root.fontFamily
                    font.pixelSize: root.scaledFontSize
                    font.bold: true
                }

            }

        }

    }

}
