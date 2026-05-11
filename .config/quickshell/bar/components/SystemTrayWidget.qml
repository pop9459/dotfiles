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

                function showMenu() {
                    if (modelData.menu) {
                        trayMenuAnchor.open();
                        return;
                    }

                    if (typeof modelData.secondaryActivate === "function")
                        modelData.secondaryActivate();
                }

                QsMenuAnchor {
                    id: trayMenuAnchor

                    anchor.window: root
                    anchor.item: trayItem
                    menu: modelData.menu
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
                                trayItem.showMenu();
                            else
                                modelData.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            trayItem.showMenu();
                        }
                    }
                }
            }
        }
    }
}
