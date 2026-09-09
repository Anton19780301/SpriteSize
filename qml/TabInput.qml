import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: root

    // Диалоговое окно выбора папки
    FolderDialog {
        id: folderDialog
        title: qsTr("Выберите рабочую папку с текстурами")

        onSelectedFolderChanged: {
            let rawPath = folderDialog.selectedFolder.toString()
            let cleanPath = ""

            if (rawPath.startsWith("file:///")) {
                cleanPath = rawPath.replace("file:///", "")
            } else {
                cleanPath = rawPath.replace("file:", "")
            }

            let finalPath = decodeURIComponent(cleanPath)

            // 1. Записываем путь в визуальное поле
            pathTextField.text = finalPath

            // 2. ИСПРАВЛЕНО: Передаем путь в C++ класс! Это мгновенно запустит scanDirectory() в C++
            imageProcessor.inputPath = finalPath
        }
    }

    // Основная разметка интерфейса
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        // Приветственный / Информационный блок
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pointSize: 11
            color: "#444444"
            text: qsTr("Шаг 1: Укажите рабочую директорию. Программа просканирует её на наличие изображений. Перед обработкой внутри этой папки автоматически создастся резервная копия исходных файлов.")
        }

        // Ряд с полем ввода и кнопкой "Обзор"
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: pathTextField
                Layout.fillWidth: true
                placeholderText: qsTr("Путь к папке проекта или текстурам...")
                readOnly: true
                selectByMouse: true
                font.pointSize: 10

                background: Rectangle {
                    border.color: pathTextField.text ? "#4CAF50" : "#CCCCCC"
                    border.width: 1
                    radius: 4
                }
            }

            Button {
                id: browseButton
                text: qsTr("Обзор...")
                font.pointSize: 10
                onClicked: folderDialog.open()

                contentItem: Text {
                    text: browseButton.text
                    font: browseButton.font
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: browseButton.down ? "#0b5ed7" : "#0d6efd"
                    radius: 4
                }
            }
        }

        // Умный список с превью (добавили ID, чтобы безопасно ссылаться ниже)
        // Контейнер для списка и кнопок массового выделения
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            // Показываем блок только когда папка выбрана и в ней есть файлы
            visible: typeof imageProcessor !== "undefined" && imageProcessor !== null &&
                     imageProcessor.inputPath !== "" && imageProcessor.assetModel.length > 0

            // Ряд с кнопками управления галочками
            RowLayout {
                spacing: 10
                Layout.fillWidth: true

                Button {
                    text: qsTr("☑ Выбрать все")
                    font.pointSize: 9
                    onClicked: imageProcessor.setAllAssetsChecked(true)
                }

                Button {
                    text: qsTr("☐ Снять все")
                    font.pointSize: 9
                    onClicked: imageProcessor.setAllAssetsChecked(false)
                }

                Item { Layout.fillWidth: true } // Распорка, чтобы сдвинуть кнопки влево
            }

            // Сам список с превью (занимает всё оставшееся место)
            AssetList {
                id: assetListView
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }


        // Заглушка, если папка пуста или не выбрана
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !assetListView.parent.visible
            color: "#FFF3E0"
            border.color: "#FFE0B2"
            border.width: 1
            radius: 4

            Label {
                anchors.centerIn: parent
                font.bold: true
                color: "#E65100"
                text: (typeof imageProcessor !== "undefined" && imageProcessor !== null && imageProcessor.inputPath !== "")
                      ? qsTr("В папке не обнаружено поддерживаемых текстур (PNG, JPG, WebP)")
                      : qsTr("Рабочая папка не выбрана")
            }
        }
    }

    DropArea {
        id: folderDropArea
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#0d6efd"
            opacity: parent.containsDrag ? 0.15 : 0.0
            border.color: "#0d6efd"
            border.width: parent.containsDrag ? 3 : 0
            radius: 4

            Behavior on opacity { NumberAnimation { duration: 150 } }

            Label {
                anchors.centerIn: parent
                text: qsTr("Перетащите папку сюда для сканирования")
                font.bold: true
                font.pointSize: 16
                color: "#0b5ed7"
                visible: folderDropArea.containsDrag
            }
        }

        onDropped: function(drop) {
            if (drop.hasUrls && drop.urls.length > 0) {
                let rawPath = drop.urls[0].toString()
                let cleanPath = ""
                if (rawPath.startsWith("file:///")) {
                    cleanPath = rawPath.replace("file:///", "")
                } else {
                    cleanPath = rawPath.replace("file:", "")
                }

                let finalPath = decodeURIComponent(cleanPath)
                pathTextField.text = finalPath
                imageProcessor.inputPath = finalPath
                drop.acceptProposedAction()
            }
        }
    }
}
