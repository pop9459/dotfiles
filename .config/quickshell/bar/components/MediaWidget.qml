import "../theme"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

PillWidget {
    id: widget

    // Same trick as WifiWidget.qml: PillWidget's own implicitWidth is derived
    // from contentRoot.childrenRect, which is circular under an animated
    // width. Compute width explicitly from leaf implicitWidths instead.
    width: widget.hasPlayer
        ? (artArea.width + spectrumRow.width + spectrumRow.spacing
            + (widget.hasTrackInfo ? (6 + titleClip.width) : 0)
            + (padding * 2) + (extraSideMargin ? extraSideMarginSize : 0))
        : 0

    Behavior on width {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    opacity: widget.isPlaying ? 1.0 : 0.6
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    property var playerList: Mpris.players.values
    property var activePlayer: null

    readonly property bool hasPlayer: widget.activePlayer !== null
    readonly property string trackTitle: widget.hasPlayer ? widget.activePlayer.trackTitle : ""
    readonly property string trackArtist: widget.hasPlayer ? widget.activePlayer.trackArtist : ""
    readonly property string trackArtUrl: widget.hasPlayer ? widget.activePlayer.trackArtUrl : ""
    readonly property bool isPlaying: widget.hasPlayer ? widget.activePlayer.isPlaying : false
    readonly property bool hasTrackInfo: widget.hasPlayer && widget.trackTitle.length > 0

    property var barLevels: Array(9).fill(0)

    function pickActivePlayer() {
        for (const p of widget.playerList)
            if (p.isPlaying)
                return p;
        return widget.playerList.length > 0 ? widget.playerList[0] : null;
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
                const parts = line.split(";").map(v => parseInt(v, 10));
                if (parts.length === widget.barLevels.length && !parts.some(Number.isNaN))
                    widget.barLevels = parts;
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 6

        Item {
            id: artArea

            width: height
            height: root.barHeight - padding * 2

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

        Row {
            id: spectrumRow

            spacing: 2
            height: root.barHeight - padding * 2
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: widget.barLevels.length

                delegate: Rectangle {
                    width: 3
                    height: Math.max(2, (widget.barLevels[index] / 7) * spectrumRow.height)
                    anchors.bottom: parent.bottom
                    color: widget.accentColor

                    Behavior on height {
                        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                    }
                }
            }
        }

        Item {
            id: titleClip

            clip: true
            height: titleLabel.height
            width: widget.hasTrackInfo ? Math.min(titleLabel.implicitWidth, 180) : 0

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
    }
}
