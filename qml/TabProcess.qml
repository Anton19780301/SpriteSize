import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

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

        GridLayout {
            columns: 2
            rowSpacing: 12
            columnSpacing: 15
            Layout.fillWidth: true

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
                onCurrentIndexChanged: sizePresetCombo.currentIndex = 0
            }

            Label {
                text: resizeModeCombo.currentIndex === 0 ? qsTr("Размер спрайта:") : qsTr("Масштаб:")
                font.pointSize: 10
                color: window.isDarkMode ? "#E0E0E0" : "#333333"
            }

            ComboBox {
                id: sizePresetCombo
                Layout.preferredWidth: 160
                // ИСПРАВЛЕНО: Добавили "100%" на первое место в процентном режиме!
                model: resizeModeCombo.currentIndex === 0
                       ? ["64 x 64", "128 x 128", "256 x 256", qsTr("Свой размер")]
                       : ["100%", "75%", "50%", "25%", qsTr("Свой процент")]
                currentIndex: 0
            }

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

            Label {
                text: qsTr("Маска имени:")
                font.pointSize: 10
                color: window.isDarkMode ? "#E0E0E0" : "#333333"
            }

            // ИСПРАВЛЕНО: Объединили маску и стартовый индекс в одну компактную строку
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                TextField {
                    id: renameField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Опционально: walk_## (где # станет 00, 01...)")
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

                // ПОЛЕ НАЧАЛЬНОГО ИНДЕКСА: Показывается только если в маске введена хотя бы одна решетка #
                RowLayout {
                    spacing: 5
                    visible: renameField.text.indexOf("#") !== -1

                    Label {
                        text: qsTr("Старт:")
                        font.pointSize: 9
                        color: window.isDarkMode ? "#BBBBBB" : "#666666"
                    }

                    TextField {
                        id: startIndexField
                        text: "0" // По умолчанию начинаем с нуля!
                        width: 45
                        font.pointSize: 10
                        horizontalAlignment: TextInput.AlignHCenter
                        color: window.isDarkMode ? "#FFFFFF" : "#000000"
                        validator: IntValidator { bottom: 0; top: 999999 }

                        onTextChanged: {
                            if (typeof imageProcessor !== "undefined" && imageProcessor !== null) {
                                let val = parseInt(text)
                                imageProcessor.startIndex = isNaN(val) ? 0 : val
                            }
                        }

                        background: Rectangle {
                            color: window.isDarkMode ? "#21252B" : "#FFFFFF"
                            border.color: startIndexField.activeFocus ? "#2196F3" : (window.isDarkMode ? "#3F444A" : "#CCCCCC")
                            border.width: 1
                            radius: 4
                        }
                    }
                }
            }
        }

        // РЯД РУЧНОГО ВВОДА ПИКСЕЛЕЙ
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

        // РЯД РУЧНОГО ВВОДА ПРОЦЕНТОВ (В процентном режиме "Свой процент" теперь имеет индекс 4, так как мы добавили 100%)
        RowLayout {
            spacing: 10
            visible: resizeModeCombo.currentIndex === 1 && sizePresetCombo.currentIndex === 4
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
                if (resizeModeCombo.currentIndex === 0) {
                    if (sizePresetCombo.currentIndex === 0) { w = 64; h = 64; }
                    else if (sizePresetCombo.currentIndex === 1) { w = 128; h = 128; }
                    else if (sizePresetCombo.currentIndex === 2) { w = 256; h = 256; }
                    else { w = parseInt(customWidth.text); h = parseInt(customHeight.text); }
                }
                else {
                    let pct = 100
                    // ИСПРАВЛЕНО: Индексы сместились из-за добавления 100% на 0-ю позицию
                    if (sizePresetCombo.currentIndex === 0) pct = 100;
                    else if (sizePresetCombo.currentIndex === 1) pct = 75;
                    else if (sizePresetCombo.currentIndex === 2) pct = 50;
                    else if (sizePresetCombo.currentIndex === 3) pct = 25;
                    else pct = parseInt(customPercent.text);
                    w = -pct;
                    h = -pct;
                }
                let selectedFormat = formatCombo.currentText.toUpperCase();
                imageProcessor.startProcessing(w, h, nearestNeighborCheck.checked, selectedFormat);
            }
        }
    }
}