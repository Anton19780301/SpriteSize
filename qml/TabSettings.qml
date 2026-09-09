import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 25

        Label {
            text: qsTr("Настройки программы")
            font.bold: true
            font.pointSize: 13
            color: window.isDarkMode ? "#FFFFFF" : "#333333"
        }

        // Выбор Языка
        RowLayout {
            spacing: 20
            Layout.fillWidth: true

            Label {
                text: qsTr("Язык интерфейса (Language):")
                font.pointSize: 10
                color: window.isDarkMode ? "#BBBBBB" : "#555555"
            }

            ComboBox {
                id: langCombo
                Layout.preferredWidth: 150
                model: ["Русский", "English"]
                currentIndex: (typeof appTranslator !== "undefined" && appTranslator !== null && appTranslator.currentLanguage === "en") ? 1 : 0

                onActivated: function(index) {
                    if (typeof appTranslator === "undefined" || appTranslator === null) return;
                    if (index === 0) appTranslator.selectLanguage("ru")
                    else appTranslator.selectLanguage("en")
                }
            }
        }

        // ТЁМНАЯ ТЕМА (НОВОЕ)
        RowLayout {
            spacing: 20
            Layout.fillWidth: true

            Label {
                text: qsTr("Тема оформления:")
                font.pointSize: 10
                color: window.isDarkMode ? "#BBBBBB" : "#555555"
            }

            Switch {
                id: themeSwitch
                text: window.isDarkMode ? qsTr("Тёмная") : qsTr("Светлая")
                checked: window.isDarkMode
                onCheckedChanged: {
                    window.isDarkMode = checked
                }
            }
        }

        // Информационная плашка
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: window.isDarkMode ? "#2D3238" : "#F5F5F5"
            border.color: window.isDarkMode ? "#3F444A" : "#E0E0E0"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    font.pointSize: 9
                    color: window.isDarkMode ? "#AAAAAA" : "#666666"
                    text: qsTr("Настройки темы и языка применяются мгновенно ко всем вкладкам приложения.")
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
