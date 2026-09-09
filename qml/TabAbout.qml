import QtQuick
import QtQuick.Controls

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        anchors.margins: 20
        color: "#f5f5f5"
        border.color: "#e0e0e0"
        border.width: 1
        radius: 4

        Label {
            anchors.centerIn: parent
            font.pointSize: 14
            color: "#666666"
            text: qsTr("О программе SpriteSize")
        }
    }
}
