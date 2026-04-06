import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: clockContainer
    
    color: Colors.base
    border.color: Colors.yellow  // Third in cycle (blue, green, yellow, red)
    border.width: 2
    radius: 0
    
    implicitWidth: timeText.implicitWidth + 20
    implicitHeight: 34
    
    property string currentTime: Qt.formatTime(new Date(), "hh:mm")
    
    Timer {
        interval: 1000  // Update every second
        running: true
        repeat: true
        onTriggered: {
            clockContainer.currentTime = Qt.formatTime(new Date(), "hh:mm")
        }
    }
    
    Text {
        id: timeText
        anchors.centerIn: parent
        text: currentTime
        color: Colors.yellow
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 16
        font.weight: Font.Black
    }
}
