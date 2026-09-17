import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

PillWidget {
    id: widget

    // Gap between each block in the content row (art, spectrum, title).
    property int contentSpacing: 6

    // widget lives inside a RowLayout (leftRow in shell.qml), which manages
    // its children's actual "width" imperatively - binding "width" directly
    // fights that and can get silently clobbered whenever the layout
    // repolishes (e.g. a sibling's implicitWidth changes), leaving this
    // pill stuck open even with no active player. Drive Layout.preferredWidth
    // instead, which RowLayout is designed to read.
    // Row always reserves contentSpacing between every pair of its three
    // children (even when titleClip is collapsed to width 0), so both gaps
    // must be counted here to match what Row actually renders.
    Layout.preferredWidth: widget.hasPlayer
        ? (artArea.width + widget.contentSpacing + spectrumRow.width
            + widget.contentSpacing + titleClip.width
            + (padding * 2) + (extraSideMargin ? extraSideMarginSize : 0))
        : 0

    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    property var playerList: Mpris.players.values
    property var activePlayer: null

    readonly property bool hasPlayer: widget.activePlayer !== null
    readonly property string trackTitle: widget.hasPlayer ? widget.activePlayer.trackTitle : ""
    readonly property string trackArtist: widget.hasPlayer ? widget.activePlayer.trackArtist : ""
    readonly property string trackArtUrl: widget.hasPlayer ? widget.activePlayer.trackArtUrl : ""
    readonly property bool isPlaying: widget.hasPlayer ? widget.activePlayer.isPlaying : false
    readonly property bool hasTrackInfo: widget.hasPlayer && widget.trackTitle.length > 0

    property var barLevels: Array(16).fill(0)

    // Only an actually-playing player counts as "having a source" - a
    // paused/stopped player should make the widget disappear entirely
    // rather than fall back to showing it dimmed.
    function pickActivePlayer() {
        for (const p of widget.playerList)
            if (p.isPlaying)
                return p;
        return null;
    }

    function refreshActivePlayer() {
        widget.activePlayer = widget.pickActivePlayer();
    }

    Connections {
        target: Mpris.players
        function onValuesChanged() { widget.refreshActivePlayer(); }
    }

    Repeater {
        model: widget.playerList
        delegate: Item {
            Connections {
                target: modelData
                function onIsPlayingChanged() { widget.refreshActivePlayer(); }
            }
        }
    }

    Component.onCompleted: widget.refreshActivePlayer()

    Process {
        id: cavaProcess

        command: ["cava", "-p", Quickshell.env("HOME") + "/.config/cava/config"]
        running: widget.hasPlayer
        stdout: SplitParser {
            onRead: (line) => {
                // Each frame ends with a trailing bar_delimiter before the
                // newline, so split() would otherwise yield one extra empty
                // element at the end.
                const parts = line.split(";").filter(v => v.length > 0).map(v => parseInt(v, 10));
                if (parts.length === widget.barLevels.length && !parts.some(Number.isNaN))
                    widget.barLevels = parts;
            }
        }
    }

    Row {
        anchors.centerIn: parent
        height: root.barHeight - padding * 2
        spacing: widget.contentSpacing

        Item {
            id: artArea

            // Same size as the workspace squares in WorkspaceWidget.qml.
            width: widget.contentItem.height
            height: widget.contentItem.height
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            Image {
                id: albumArt

                anchors.fill: parent
                source: widget.trackArtUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: widget.trackArtUrl.length > 0 && status !== Image.Error
            }

            Text {
                anchors.centerIn: parent
                visible: !albumArt.visible
                color: widget.accentColor
                text: "󰝚"

                font {
                    family: root.fontFamily
                    pixelSize: root.scaledFontSize
                    bold: true
                }
            }
        }

        Item {
            id: titleClip

            clip: true
            height: titleLabel.height
            width: widget.hasTrackInfo ? Math.min(titleLabel.implicitWidth, 180) : 0
            anchors.verticalCenter: parent.verticalCenter

            Behavior on width {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }

            Text {
                id: titleLabel

                color: widget.accentColor
                text: widget.trackArtist.length > 0 ? `${widget.trackTitle} — ${widget.trackArtist}` : widget.trackTitle
                elide: Text.ElideRight
                width: 180

                font {
                    family: root.fontFamily
                    pixelSize: root.scaledFontSize
                    bold: true
                }
            }
        }

        Row {
            id: spectrumRow

            spacing: 1
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: widget.barLevels.length

                delegate: Rectangle {
                    width: 2
                    height: Math.max(2, (widget.barLevels[index] / 7) * spectrumRow.height)
                    anchors.bottom: parent.bottom
                    color: widget.accentColor

                    Behavior on height {
                        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                    }
                }
            }
        }
    }
}
