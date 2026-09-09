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
            color: "#333333"
        }

        // Блок выбора локализации
        RowLayout {
            spacing: 20
            Layout.fillWidth: true

            Label {
                text: qsTr("Язык интерфейса (Language):")
                font.pointSize: 10
                color: "#555555"
            }

            ComboBox {
                id: langCombo
                Layout.preferredWidth: 150
                model: ["Русский", "English"]

                // Безопасно выставляем текущий индекс на основе данных из C++
                currentIndex: (typeof appTranslator !== "undefined" && appTranslator !== null && appTranslator.currentLanguage === "en") ? 1 : 0

                // Срабатывает, когда пользователь выбирает пункт из списка
                onActivated: function(index) {
                    if (typeof appTranslator === "undefined" || appTranslator === null) return;

                    if (index === 0) {
                        appTranslator.selectLanguage("ru")
                    } else {
                        appTranslator.selectLanguage("en")
                    }
                }
            }
        }

        // Информационная плашка под настройками
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#F5F5F5"
            border.color: "#E0E0E0"
            border.width: 1
            radius: 4
            Layout.topMargin: 10

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    font.pointSize: 9
                    color: "#666666"
                    text: qsTr("Смена языка происходит мгновенно для всех элементов интерфейса. Перевод подхватывается из бинарных файлов локализации Qt Linguist (.qm).")
                }
            }
        }

        // Распорка (Spacer), которая выталкивает все настройки к верхнему краю экрана
        Item {
            Layout.fillHeight: true
        }
    }
}
