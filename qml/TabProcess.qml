import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    //Вспомогательная функция: проверяет, стоит ли хотя бы одна галочка в модели
    function hasCheckedAssets() {
        if (typeof imageProcessor === "undefined" || imageProcessor === null) return false;

        let model = imageProcessor.assetModel
        if (!model || model.length === 0) return false;

        for (let i = 0; i < model.length; i++) {
            if (model[i].checked === true) {
                return true; // Нашли хотя бы один выделенный файл
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
        anchors.margins: 40
        spacing: 20

        Label {
            text: qsTr("Настройки пакетного изменения размера")
            font.bold: true
            font.pointSize: 13
            color: "#333333"
        }

        // Ряд 1: Выбор разрешения
        RowLayout {
            spacing: 15
            Layout.fillWidth: true

            Label {
                text: qsTr("Целевой размер спрайта:")
                font.pointSize: 10
            }

            ComboBox {
                id: sizePresetCombo
                Layout.preferredWidth: 150
                model: ["64 x 64", "128 x 128", "256 x 256", qsTr("Свой размер")]
                currentIndex: 0
            }
        }

        //Поля ручного ввода (появляются ТОЛЬКО если выбран пункт "Свой размер")
        RowLayout {
            spacing: 10
            visible: sizePresetCombo.currentIndex === 3
            Layout.leftMargin: 20

            Label { text: qsTr("Ширина:") }
            TextField {
                id: customWidth
                text: "64"
                width: 60
                font.pointSize: 10
                horizontalAlignment: TextInput.AlignHCenter
                validator: IntValidator { bottom: 1; top: 8192 } // Защита от дурака
                background: Rectangle { border.color: "#CCCCCC"; radius: 4 }
            }

            Label { text: "px  ×  " + qsTr("Высота:") }
            TextField {
                id: customHeight
                text: "64"
                width: 60
                font.pointSize: 10
                horizontalAlignment: TextInput.AlignHCenter
                validator: IntValidator { bottom: 1; top: 8192 }
                background: Rectangle { border.color: "#CCCCCC"; radius: 4 }
            }
            Label { text: "px" }
        }

        //Настройка алгоритма сжатия
        CheckBox {
            id: nearestNeighborCheck
            text: qsTr("Режим Пиксель-Арт (Nearest Neighbor фильтрация)")
            checked: true // По умолчанию включен, так как мы делаем игру на Godot
            font.pointSize: 10

            ToolTip.visible: hovered
            ToolTip.text: qsTr("Сохраняет пиксели четкими при уменьшении. Идеально для 2D пиксельных игр. Отключите, если нужен мягкий рисунок.")
        }

        // Пространство-распорка, выталкивающее элементы вверх, а кнопку вниз
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
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // Главная управляющая кнопка "СТАРТ"
        Button {
            id: startBtn
            Layout.fillWidth: true
            Layout.preferredHeight: 50
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
                color: startBtn.enabled ? "#FFFFFF" : "#888888"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: startBtn.enabled ? (startBtn.down ? "#1976D2" : "#2196F3") : "#E0E0E0"
                border.color: startBtn.enabled ? "#1976D2" : "#CCCCCC"
                border.width: 1
                radius: 6
            }

            onClicked: {
                startBtn.text = qsTr("ОБРАБОТКА...")

                let w = 64
                let h = 64

                // Вычисляем размеры на основе выбранного пресета
                if (sizePresetCombo.currentIndex === 0) { w = 64; h = 64; }
                else if (sizePresetCombo.currentIndex === 1) { w = 128; h = 128; }
                else if (sizePresetCombo.currentIndex === 2) { w = 256; h = 256; }
                else {
                    w = parseInt(customWidth.text)
                    h = parseInt(customHeight.text)
                }

                // Передаем параметры в наше тяжелое C++ ядро
                imageProcessor.startProcessing(w, h, nearestNeighborCheck.checked)
            }
        }
    }
}
