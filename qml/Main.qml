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

    footer: ToolBar {
        id: statusBar
        height: 25

        background: Rectangle {
            color: "#F5F5F5" // Светло-серый аккуратный фон
            border.color: "#E0E0E0"
            border.width: 1
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15

            // Текст статуса, связанный с C++
            Label {
                id: statusText
                // Защита от null на этапе инициализации приложения
                text: (typeof imageProcessor !== "undefined" && imageProcessor !== null)
                      ? imageProcessor.statusMessage
                      : qsTr("Инициализация...")
                font.pointSize: 9
                color: "#555555"
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // Маленький индикатор, если идет процесс (опционально, для красоты)
            BusyIndicator {
                height: 16
                width: 16
                running: typeof imageProcessor !== "undefined" && imageProcessor !== null && imageProcessor.progress > 0 && imageProcessor.progress < 100
                visible: running
            }
        }
    }
}

