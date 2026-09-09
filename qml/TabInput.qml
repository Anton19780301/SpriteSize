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
        AssetList {
            id: assetListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Показываем список только когда папка выбрана и в ней на C++ стороне нашлись файлы
            visible: typeof imageProcessor !== "undefined" && imageProcessor !== null && imageProcessor.inputPath !== "" && imageProcessor.assetModel.length > 0

        }

        // Заглушка, если папка пуста или не выбрана
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            // ИСПРАВЛЕНО: Теперь мы жестко привязаны к видимости assetListView по его ID, а не по индексам детей
            visible: !assetListView.visible
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
}
