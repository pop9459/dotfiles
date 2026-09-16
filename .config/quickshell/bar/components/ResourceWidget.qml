import "../theme"
import QtQuick
import Quickshell
import Quickshell.Io

PillWidget {
    id: widget

    property int cpuPercent: -1
    property int ramPercent: -1

    // Gap between an icon and its own percentage.
    property int iconTextSpacing: 4
    // Gap between the CPU block and the RAM block.
    property int blockSpacing: 10

    function refreshResources() {
        resourceProcess.running = false;
        resourceProcess.running = true;
    }

    Process {
        id: resourceProcess

        command: ["sh", "-c", "read -r _ a1 b1 c1 d1 e1 f1 g1 h1 _ < /proc/stat; sleep 0.3; read -r _ a2 b2 c2 d2 e2 f2 g2 h2 _ < /proc/stat; cpu=$(awk -v a1=$a1 -v b1=$b1 -v c1=$c1 -v d1=$d1 -v e1=$e1 -v f1=$f1 -v g1=$g1 -v h1=$h1 -v a2=$a2 -v b2=$b2 -v c2=$c2 -v d2=$d2 -v e2=$e2 -v f2=$f2 -v g2=$g2 -v h2=$h2 'BEGIN{t1=a1+b1+c1+d1+e1+f1+g1+h1;t2=a2+b2+c2+d2+e2+f2+g2+h2;i1=d1+e1;i2=d2+e2;dt=t2-t1;di=i2-i1;if(dt>0)printf \"%.0f\",(1-di/dt)*100;else printf \"0\"}'); ram=$(free | awk '/Mem:/{printf \"%.0f\", $3/$2*100}'); printf \"%s %s\" \"$cpu\" \"$ram\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                const parts = output.split(/\s+/);
                const parsedCpu = parts.length > 0 ? parseInt(parts[0], 10) : NaN;
                const parsedRam = parts.length > 1 ? parseInt(parts[1], 10) : NaN;
                widget.cpuPercent = Number.isNaN(parsedCpu) ? -1 : parsedCpu;
                widget.ramPercent = Number.isNaN(parsedRam) ? -1 : parsedRam;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: widget.refreshResources()
    }

    Component.onCompleted: widget.refreshResources()

    Row {
        anchors.centerIn: parent
        spacing: widget.blockSpacing

        Row {
            spacing: widget.iconTextSpacing

            Text {
                color: widget.accentColor
                text: ""
                font { family: root.fontFamily; pixelSize: root.scaledFontSize; bold: true }
            }

            Text {
                color: widget.accentColor
                text: `${widget.cpuPercent >= 0 ? widget.cpuPercent : "--"}%`
                font { family: root.fontFamily; pixelSize: root.scaledFontSize; bold: true }
            }
        }

        Row {
            spacing: widget.iconTextSpacing

            Text {
                color: widget.accentColor
                text: ""
                font { family: root.fontFamily; pixelSize: root.scaledFontSize; bold: true }
            }

            Text {
                color: widget.accentColor
                text: `${widget.ramPercent >= 0 ? widget.ramPercent : "--"}%`
                font { family: root.fontFamily; pixelSize: root.scaledFontSize; bold: true }
            }
        }
    }
}
