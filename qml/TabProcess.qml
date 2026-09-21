import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Вспомогательная функция: проверяет, стоит ли хотя бы одна галочка в модели
    function hasCheckedAssets() {
        if (typeof imageProcessor === "undefined" || imageProcessor === null) return false;

        let model = imageProcessor.assetModel
        if (!model || model.length === 0) return false;

        for (let i = 0; i < model.length; i++) {
            if (model[i].checked === true) {
                return true;
            }
        }
        return false;
    }

    Connections {
        target: imageProcessor
        function onProcessingFinished(totalProcessed, message) {
            startBtn.text = qsTr("СЖАТЬ ТЕКСТУРЫ")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 35
        spacing: 15

        Label {
            text: qsTr("Настройки пакетного изменения размера")
            font.bold: true
            font.pointSize: 13
            color: window.isDarkMode ? "#FFFFFF" : "#333333"
        }

        // КОМПАКТНАЯ СЕТКА НАСТРОЕК (Экономит место по вертикали)
        GridLayout {
            columns: 2
            rowSpacing: 12
            columnSpacing: 15
            Layout.fillWidth: true

            // Строка 1: Размер
            Label {
                text: qsTr("Размер спрайта:")
                font.pointSize: 10
                color: window.isDarkMode ? "#E0E0E0" : "#333333"
            }

            ComboBox {
                id: sizePresetCombo
                Layout.preferredWidth: 160
                model: ["64 x 64", "128 x 128", "256 x 256", qsTr("Свой размер")]
                currentIndex: 0
            }

            // Строка 2: Формат
            Label {
                text: qsTr("Выходной формат:")
                font.pointSize: 10
                color: window.isDarkMode ? "#E0E0E0" : "#333333"
            }

            ComboBox {
                id: formatCombo
                Layout.preferredWidth: 160
                model: ["Original", "PNG", "WEBP", "JPG", "BMP"]
                currentIndex: 0
            }

            // Строка 3: Переименование
            Label {
                text: qsTr("Маска имени:")
                font.pointSize: 10
                color: window.isDarkMode ? "#E0E0E0" : "#333333"
            }

            TextField {
                id: renameField
                Layout.fillWidth: true
                placeholderText: qsTr("Опционально: walk_# (где # — номер)")
                font.pointSize: 10
                selectByMouse: true

                // ИСПРАВЛЕНО: Четкие, контрастные цвета для текста в обеих темах
                color: window.isDarkMode ? "#FFFFFF" : "#000000"
                placeholderTextColor: window.isDarkMode ? "#888888" : "#999999"

                onTextChanged: {
                    if (typeof imageProcessor !== "undefined" && imageProcessor !== null) {
                        imageProcessor.renameMask = text.trim()
                    }
                }

                background: Rectangle {
                    color: window.isDarkMode ? "#21252B" : "#FFFFFF"
                    border.color: renameField.activeFocus ? "#2196F3" : (window.isDarkMode ? "#3F444A" : "#CCCCCC")
                    border.width: 1
                    radius: 4
                }
            }
        }

        // Ряд ручного ввода (появляется ТОЛЬКО при выборе "Свой размер")
        RowLayout {
            spacing: 10
            visible: sizePresetCombo.currentIndex === 3
            Layout.leftMargin: 5
            Layout.topMargin: 5

            Label { text: qsTr("Ширина:"); color: window.isDarkMode ? "#E0E0E0" : "#333333" }
            TextField {
                id: customWidth
                text: "64"
                width: 55
                font.pointSize: 10
                horizontalAlignment: TextInput.AlignHCenter
                color: window.isDarkMode ? "#FFFFFF" : "#000000"
                validator: IntValidator { bottom: 1; top: 8192 }
                background: Rectangle { color: window.isDarkMode ? "#21252B" : "#FFFFFF"; border.color: "#CCCCCC"; radius: 4 }
            }

            Label { text: "px  ×  " + qsTr("Высота:"); color: window.isDarkMode ? "#E0E0E0" : "#333333" }
            TextField {
                id: customHeight
                text: "64"
                width: 55
                font.pointSize: 10
                horizontalAlignment: TextInput.AlignHCenter
                color: window.isDarkMode ? "#FFFFFF" : "#000000"
                validator: IntValidator { bottom: 1; top: 8192 }
                background: Rectangle { color: window.isDarkMode ? "#21252B" : "#FFFFFF"; border.color: "#CCCCCC"; radius: 4 }
            }
            Label { text: "px"; color: window.isDarkMode ? "#E0E0E0" : "#333333" }
        }

        // Настройка алгоритма сжатия
        CheckBox {
            id: nearestNeighborCheck
            text: qsTr("Режим Пиксель-Арт (Nearest Neighbor фильтрация)")
            checked: true
            font.pointSize: 10
            Layout.topMargin: 5

            // Фикс цвета текста чекбокса для темной темы
            contentItem: Text {
                text: parent.text
                font: parent.font
                color: window.isDarkMode ? "#E0E0E0" : "#333333"
                leftPadding: parent.indicator.width + parent.spacing
                verticalAlignment: Text.AlignVCenter
            }

            ToolTip.visible: hovered
            ToolTip.text: qsTr("Сохраняет пиксели четкими при уменьшении. Идеально для 2D пиксельных игр. Отключите, если нужен мягкий рисунок.")
        }

        // Пространство-распорка, удерживающее всё наверху
        Item {
            Layout.fillHeight: true
        }

        // Индикатор выполнения (Progress Bar)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            visible: typeof imageProcessor !== "undefined" && imageProcessor !== null &&
                     imageProcessor.progress > 0 && !startBtn.enabled

            ProgressBar {
                id: processProgressBar
                Layout.fillWidth: true
                from: 0
                to: 100
                value: (typeof imageProcessor !== "undefined" && imageProcessor !== null) ? imageProcessor.progress : 0
            }

            Label {
                text: qsTr("Обработка ассетов... ") + ((typeof imageProcessor !== "undefined" && imageProcessor !== null) ? imageProcessor.progress : 0) + "%"
                font.pointSize: 9
                color: window.isDarkMode ? "#ABB2BF" : "#666666"
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // Главная управляющая кнопка "СТАРТ"
        Button {
            id: startBtn
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            text: qsTr("СЖАТЬ ТЕКСТУРЫ")
            font.bold: true
            font.pointSize: 11

            enabled: (typeof imageProcessor !== "undefined" && imageProcessor !== null) &&
                     imageProcessor.inputPath !== "" &&
                     root.hasCheckedAssets() &&
                     (imageProcessor.progress === 0 || imageProcessor.progress === 100)

            contentItem: Text {
                text: startBtn.text
                font: startBtn.font
                color: startBtn.enabled ? "#FFFFFF" : (window.isDarkMode ? "#5C6370" : "#888888")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: startBtn.enabled ? (startBtn.down ? "#1976D2" : "#2196F3") : (window.isDarkMode ? "#282C34" : "#E0E0E0")
                border.color: startBtn.enabled ? "#1976D2" : (window.isDarkMode ? "#3E4451" : "#CCCCCC")
                border.width: 1
                radius: 6
            }

            onClicked: {
                startBtn.text = qsTr("ОБРАБОТКА...")

                let w = 64, h = 64
                if (sizePresetCombo.currentIndex === 0) { w = 64; h = 64; }
                else if (sizePresetCombo.currentIndex === 1) { w = 128; h = 128; }
                else if (sizePresetCombo.currentIndex === 2) { w = 256; h = 256; }
                else { w = parseInt(customWidth.text); h = parseInt(customHeight.text); }

                let selectedFormat = formatCombo.currentText.toUpperCase()

                imageProcessor.startProcessing(w, h, nearestNeighborCheck.checked, selectedFormat)
            }
        }
    }
}
