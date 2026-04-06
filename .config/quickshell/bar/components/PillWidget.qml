import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

// Reusable pill-style container (rectangular with colored border)
Rectangle {
    id: pill
    
    property int pillIndex: 0  // For color cycling
    property color borderColor: Colors.cycleColor(pillIndex)
    property alias contentItem: contentLoader.sourceComponent
    
    color: Colors.base
    border.color: borderColor
    border.width: 2
    radius: 0  // No rounded corners
    
    // Consistent padding
    implicitWidth: contentLoader.item ? contentLoader.item.implicitWidth + 8 : 32
    implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight + 8 : 32
    
    Loader {
        id: contentLoader
        anchors.fill: parent
        anchors.margins: 4
    }
    
    // Smooth transitions
    Behavior on border.color {
        ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
    }
    
    Behavior on color {
        ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
    }
}
