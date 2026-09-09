import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 650
    height: 450
    minimumWidth: 500
    minimumHeight: 400
    visible: true
    title: qsTr("SpriteSize - Пакетное сжатие текстур")

    header: TabBar {
        id: mainTabBar
        currentIndex: mainStackLayout.currentIndex
        width: parent.width

        TabButton { text: qsTr("1. Папка") }
        TabButton { text: qsTr("2. Сжатие") }
        TabButton { text: qsTr("3. Настройки") }
        TabButton { text: qsTr("4. О программе") }
    }

    StackLayout {
        id: mainStackLayout
        anchors.fill: parent
        currentIndex: mainTabBar.currentIndex

        TabInput {
            id: tabInput
        }

        TabProcess {
            id: tabProcess
        }

        TabSettings {
            id: tabSettings
        }

        TabAbout {
            id: tabAbout
        }
    }
}
