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

    // ФЛАГ ТЁМНОЙ ТЕМЫ (По умолчанию тёмная, так как мы в геймдеве!)
    property bool isDarkMode: true

    // Красим задний фон самого приложения
    background: Rectangle {
        color: window.isDarkMode ? "#1E2227" : "#FFFFFF"
    }

    header: TabBar {
        id: mainTabBar
        currentIndex: mainStackLayout.currentIndex
        width: parent.width

        background: Rectangle {
            color: window.isDarkMode ? "#21252B" : "#F0F0F0"
        }

        TabButton {
            text: qsTr("1. Папка")
            contentItem: Text { text: parent.text; color: window.isDarkMode ? "#FFFFFF" : "#000000"; horizontalAlignment: Text.AlignHCenter }
        }
        TabButton {
            text: qsTr("2. Сжатие")
            contentItem: Text { text: parent.text; color: window.isDarkMode ? "#FFFFFF" : "#000000"; horizontalAlignment: Text.AlignHCenter }
        }
        TabButton {
            text: qsTr("3. Настройки")
            contentItem: Text { text: parent.text; color: window.isDarkMode ? "#FFFFFF" : "#000000"; horizontalAlignment: Text.AlignHCenter }
        }
        TabButton {
            text: qsTr("4. О программе")
            contentItem: Text { text: parent.text; color: window.isDarkMode ? "#FFFFFF" : "#000000"; horizontalAlignment: Text.AlignHCenter }
        }
    }

    StackLayout {
        id: mainStackLayout
        anchors.fill: parent
        currentIndex: mainTabBar.currentIndex

        TabInput { id: tabInput }
        TabProcess { id: tabProcess }
        TabSettings { id: tabSettings }
        TabAbout { id: tabAbout }
    }

    footer: ToolBar {
        id: statusBar
        height: 25

        background: Rectangle {
            color: window.isDarkMode ? "#21252B" : "#F5F5F5"
            border.color: window.isDarkMode ? "#181A1F" : "#E0E0E0"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            Label {
                text: (typeof imageProcessor !== "undefined" && imageProcessor !== null) ? imageProcessor.statusMessage : qsTr("Инициализация...")
                font.pointSize: 9
                color: window.isDarkMode ? "#ABB2BF" : "#555555"
            }
        }
    }
}
