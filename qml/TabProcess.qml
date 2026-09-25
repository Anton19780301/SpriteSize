import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Проверка: выделена ли хотя бы одна галочка в списке файлов
    function hasCheckedAssets() {
        if (typeof imageProcessor === "undefined" || imageProcessor === null) return false;
        let model = imageProcessor.assetModel;
        if (!model || model.length === 0) return false;
        for (let i = 0; i < model.length; i++) {
            if (model[i].checked === true) return true;
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

        // СЕТКА НАСТРОЕК
        GridLayout {
            columns: 2
            rowSpacing: 12
            columnSpacing: 15
            Layout.fillWidth: true

            // Строка 1: Выбор режима (Пиксели или Проценты)
            Label {
                text: qsTr("Режим изменения:")
                font.pointSize: 10
                color: window.isDarkMode ? "#E0E0E0" : "#333333"
            }

            ComboBox {
                id: resizeModeCombo
                Layout.preferredWidth: 160
                model: [qsTr("Фиксированный размер"), qsTr("Пропорционально (%)")]
                currentIndex: 0
            }

            // Строка 2: Выбор пресета (Подменяется динамически)
            Label {
                text: resizeModeCombo.currentIndex === 0 ? qsTr("Размер спрайта:") : qsTr("Масштаб:")
                font.pointSize: 10
                color: window.isDarkMode ? "#E0E0E0" : "#333333"
            }

            ComboBox {
                id: sizePresetCombo
                Layout.preferredWidth: 160
                // Подменяем модель на лету в зависимости от выбранного режима
                model: resizeModeCombo.currentIndex === 0
                       ? ["64 x 64", "128 x 128", "256 x 256", qsTr("Свой размер")]
                       : ["75%", "50%", "25%", qsTr("Свой процент")]
                currentIndex: 0
            }

            // Строка 3: Формат файлов
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

            // Строка 4: Массовое переименование
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

        // ПОДБЛОК А: Ручной ввод пикселей (Показывается только в режиме пикселей при выборе "Свой размер")
        RowLayout {
            spacing: 10
            visible: resizeModeCombo.currentIndex === 0 && sizePresetCombo.currentIndex === 3
            Layout.leftMargin: 5

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

        // ПОДБЛОК Б: Ручной ввод процентов (Показывается только в режиме процентов при выборе "Свой процент")
        RowLayout {
            spacing: 10
            visible: resizeModeCombo.currentIndex === 1 && sizePresetCombo.currentIndex === 3
            Layout.leftMargin: 5

            Label { text: qsTr("Масштабировать до:"); color: window.isDarkMode ? "#E0E0E0" : "#333333" }
            TextField {
                id: customPercent
                text: "50"
                width: 55
                font.pointSize: 10
                horizontalAlignment: TextInput.AlignHCenter
                color: window.isDarkMode ? "#FFFFFF" : "#000000"
                validator: IntValidator { bottom: 1; top: 100 }
                background: Rectangle { color: window.isDarkMode ? "#21252B" : "#FFFFFF"; border.color: "#CCCCCC"; radius: 4 }
            }
            Label { text: "%"; color: window.isDarkMode ? "#E0E0E0" : "#333333" }
        }

        // Выбор алгоритма фильтрации
        CheckBox {
            id: nearestNeighborCheck
            text: qsTr("Режим Пиксель-Арт (Nearest Neighbor фильтрация)")
            checked: true
            font.pointSize: 10
            Layout.topMargin: 5

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

        Item { Layout.fillHeight: true }

        // Индикатор прогресса
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

        // Главная кнопка запуска операции
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

                let w = 64
                let h = 64

                // ЕСЛИ ВЫБРАН РЕЖИМ ПИКСЕЛЕЙ (0):
                if (resizeModeCombo.currentIndex === 0) {
                    if (sizePresetCombo.currentIndex === 0) { w = 64; h = 64; }
                    else if (sizePresetCombo.currentIndex === 1) { w = 128; h = 128; }
                    else if (sizePresetCombo.currentIndex === 2) { w = 256; h = 256; }
                    else { w = parseInt(customWidth.text); h = parseInt(customHeight.text); }}
                else {let pct = 50
                    if (sizePresetCombo.currentIndex === 0) pct = 75;
                    else if (sizePresetCombo.currentIndex === 1) pct = 50;
                    else if (sizePresetCombo.currentIndex === 2) pct = 25;
                    else pct = parseInt(customPercent.text);
                    w = -pct;h = -pct;
                }
                let selectedFormat = formatCombo.currentText.toUpperCase();
                imageProcessor.startProcessing(w, h, nearestNeighborCheck.checked, selectedFormat);
            }
        }
    }
}