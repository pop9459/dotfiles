import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell

// Reusable pill-style container (rectangular with colored border)
Rectangle {
    id: widgetFrame

    property int pillIndex: 0
    property color accentColor: Colors.cycleColor(pillIndex)
    property int padding: 5
    property int textMargin: 5
    readonly property alias contentItem: contentRoot
    default property alias contentData: contentRoot.data

    color: Colors.base
    border.color: accentColor
    border.width: root.borderWidth
    radius: 0
    implicitWidth: contentRoot.childrenRect.width + (padding * 2)
    implicitHeight: root.barHeight

    Item {
        id: contentRoot

        anchors.fill: parent
        anchors.margins: padding
    }

}
