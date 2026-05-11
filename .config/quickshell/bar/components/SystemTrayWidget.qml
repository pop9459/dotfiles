import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

PillWidget {
    id: widget

    property int iconSize: root.scaledFontSize

    RowLayout {
        height: widget.contentItem.height
        spacing: 0

        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: trayItem

                required property var modelData

                implicitHeight: widget.contentItem.height
                implicitWidth: implicitHeight
                color: trayMouseArea.containsMouse ? Colors.surface1 : Colors.base
                radius: 0

                function showMenu(x, y) {
                    if (!modelData.hasMenu)
                        return;

                    const clickPos = trayItem.mapToItem(root, x, y);
                    modelData.display(root, Math.round(clickPos.x), Math.round(clickPos.y));
                }

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: widget.iconSize
                    source: {
                        const icon = modelData.icon;

                        if (!icon || icon.length === 0)
                            return Quickshell.iconPath("image-missing");
                        if (icon.startsWith("image://"))
                            return icon;

                        return Quickshell.iconPath(icon, "image-missing");
                    }
                }

                MouseArea {
                    id: trayMouseArea

                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            if (modelData.onlyMenu)
                                trayItem.showMenu(mouse.x, mouse.y);
                            else
                                modelData.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            trayItem.showMenu(mouse.x, mouse.y);
                        }
                    }
                }
            }
        }
    }
}
