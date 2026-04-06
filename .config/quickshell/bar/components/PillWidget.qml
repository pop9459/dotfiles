import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

// Reusable pill-style container (rectangular with colored border)
Rectangle {
    id: widget

    property int pillIndex: 0
    property color accentColor: Colors.cycleColor(pillIndex)
    property int padding: 3
    default property alias contentData: contentRoot.data
    
    color: Colors.base
    border.color: accentColor
    border.width: 2
    radius: 0
    implicitWidth: contentRoot.childrenRect.width + (padding * 2) + (border.width * 2)
    implicitHeight: contentRoot.childrenRect.height + (padding * 2) + (border.width * 2)

    Item {
        id: contentRoot
        anchors.fill: parent
        anchors.margins: widget.padding
    }
}
