import "../theme"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Desktop widget (below windows, above the wallpaper) showing whether the
// services listed in services.json are up. Edit services.json to add/remove
// services - it's watched and reloaded live. Check types are implemented in
// scripts/check_service.sh.
PanelWindow {
    id: monitor

    property string preferredScreen: "DP-1"
    property string fontFamily: "JetBrainsMono Nerd Font Propo"
    property int fontSize: 16
    property int borderWidth: 2
    property int padding: 12
    property int outerMargin: 10 // Same as hyprland's gaps_out, like the bar

    property var services: []
    property int defaultInterval: 60
    property int upCount: 0
    property int downCount: 0

    readonly property color accentColor: {
        if (monitor.downCount > 0)
            return Colors.red;
        if (monitor.services.length > 0 && monitor.upCount === monitor.services.length)
            return Colors.green;
        return Colors.blue;
    }

    function parseConfig(text) {
        try {
            const config = JSON.parse(text);
            monitor.defaultInterval = config.interval || 60;
            monitor.services = Array.isArray(config.services) ? config.services : [];
        } catch (e) {
            // Keep the last good list while the file is mid-edit/malformed.
            console.warn("ServiceMonitor: failed to parse services.json:", e);
        }
    }

    function recount() {
        let up = 0;
        let down = 0;
        for (let i = 0; i < rowRepeater.count; i++) {
            const item = rowRepeater.itemAt(i);
            if (!item)
                continue;
            if (item.status === "up")
                up++;
            else if (item.status === "down")
                down++;
        }
        monitor.upCount = up;
        monitor.downCount = down;
    }

    screen: {
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === monitor.preferredScreen)
                return screens[i];
        }
        return screens.length > 0 ? screens[0] : null;
    }

    anchors {
        bottom: true
        right: true
    }
    margins {
        bottom: monitor.outerMargin
        right: monitor.outerMargin
    }

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-services"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    color: "transparent"
    visible: monitor.services.length > 0
    implicitWidth: frame.width
    implicitHeight: frame.height

    FileView {
        path: Quickshell.shellPath("services.json")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: monitor.parseConfig(text())
    }

    Rectangle {
        id: frame

        width: 280
        height: content.implicitHeight + monitor.padding * 2
        color: Colors.base
        border.color: monitor.accentColor
        border.width: monitor.borderWidth
        radius: 0

        Behavior on border.color {
            ColorAnimation { duration: 300 }
        }

        Column {
            id: content

            anchors.fill: parent
            anchors.margins: monitor.padding
            spacing: 8

            // Header: title + up/total count
            Item {
                width: parent.width
                height: titleText.implicitHeight

                Text {
                    id: titleText

                    color: monitor.accentColor
                    text: "󰒋  SERVICES"
                    font { family: monitor.fontFamily; pixelSize: monitor.fontSize; bold: true; letterSpacing: 1 }

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }

                Text {
                    anchors.right: parent.right
                    color: monitor.accentColor
                    text: `${monitor.upCount}/${monitor.services.length}`
                    font { family: monitor.fontFamily; pixelSize: monitor.fontSize; bold: true }

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.surface1
            }

            Repeater {
                id: rowRepeater

                model: monitor.services
                onItemAdded: Qt.callLater(monitor.recount)
                onItemRemoved: Qt.callLater(monitor.recount)

                delegate: ServiceRow {
                    required property var modelData

                    width: content.width
                    name: modelData.name || modelData.target || ""
                    icon: modelData.icon || ""
                    type: modelData.type || ""
                    target: modelData.target || ""
                    user: modelData.user === true
                    intervalSeconds: modelData.interval || monitor.defaultInterval
                    fontFamily: monitor.fontFamily
                    fontSize: monitor.fontSize
                    onStatusChanged: monitor.recount()
                }
            }
        }
    }
}
