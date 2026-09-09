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
            border.color: window.isDarkMode ? "#181A1F" : "#E0E0E0"
        }

        component DarkTabButton: TabButton {
            id: btn
            contentItem: Text {
                text: btn.text
                font.bold: btn.checked
                // Белый текст в темной теме, темно-серый в светлой
                color: window.isDarkMode ? (btn.checked ? "#FFFFFF" : "#999999") : (btn.checked ? "#000000" : "#666666")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            background: Rectangle {
                // Темный фон для активных и пассивных вкладок
                color: btn.checked ? (window.isDarkMode ? "#282C34" : "#FFFFFF") : (window.isDarkMode ? "#21252B" : "#E5E5E5")
                border.color: window.isDarkMode ? "#181A1F" : "#E0E0E0"
                border.width: 1
            }
        }

        // Применяем наш новый красивый шаблон ко всем четырем вкладкам
        DarkTabButton {
            text: qsTr("1. Папка")
        }
        DarkTabButton {
            text: qsTr("2. Сжатие")
        }
        DarkTabButton {
            text: qsTr("3. Настройки")
        }
        DarkTabButton {
            text: qsTr("4. О программе")
        }
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
                text: (typeof imageProcessor !== "undefined"
                       && imageProcessor !== null) ? imageProcessor.statusMessage : qsTr(
                                                         "Инициализация...")
                font.pointSize: 9
                color: window.isDarkMode ? "#ABB2BF" : "#555555"
            }
        }
    }
}
