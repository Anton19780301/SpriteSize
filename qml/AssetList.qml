import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Храним URL выбранной картинки для предпросмотра
    property string previewUrl: ""

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        // ЛЕВАЯ ЧАСТЬ: Список файлов с чекбоксами
        ScrollView {
            SplitView.fillWidth: true
            SplitView.minimumWidth: 200
            clip: true

            ListView {
                id: listView
                // Безопасная проверка существования объекта С++ модели
                model: (typeof imageProcessor !== "undefined" && imageProcessor !== null) ? imageProcessor.assetModel : null
                spacing: 2

                delegate: Rectangle {
                    id: delegateRect
                    width: listView.width
                    height: 35
                    color: modelData.fileUrl === root.previewUrl ? "#E3F2FD" : (index % 2 === 0 ? "#FFFFFF" : "#F9F9F9")
                    border.color: "#E0E0E0"
                    border.width: 1
                    radius: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        CheckBox {
                            id: assetCheckBox
                            checked: modelData.checked
                            Layout.alignment: Qt.AlignVCenter

                            onCheckedChanged: {
                                if (typeof imageProcessor !== "undefined" && imageProcessor !== null) {
                                    imageProcessor.toggleAssetSelection(index, checked)
                                }
                            }
                            onClicked: root.previewUrl = modelData.fileUrl
                        }

                        Label {
                            text: modelData.fileName
                            font.pointSize: 10
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            elide: Text.ElideRight
                            color: "#333333"
                        }
                    }

                    TapHandler {
                        onTapped: {
                            root.previewUrl = modelData.fileUrl
                        }
                    }
                }
            }
        }

        // ПРАВАЯ ЧАСТЬ: Предпросмотр текстуры
        Rectangle {
            id: previewContainer
            SplitView.preferredWidth: 200
            SplitView.minimumWidth: 120
            color: "#ECEFF1"
            border.color: "#CFD8DC"
            border.width: 1

            Canvas {
                anchors.fill: parent
                opacity: 0.05
                visible: previewImage.status === Image.Ready
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.fillStyle = "#000000";
                    for (var x = 0; x < width; x += 12) {
                        for (var y = 0; y < height; y += 12) {
                            if ((Math.floor(x / 12) + Math.floor(y / 12)) % 2 === 0) {
                                ctx.fillRect(x, y, 12, 12);
                            }
                        }
                    }
                }
                // Перерисовываем шахматку при изменении размеров контейнера
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
            }

            // Само изображение превью
            Image {
                id: previewImage // ИСПРАВЛЕНО: ID жестко зафиксирован
                anchors.fill: parent
                anchors.margins: 10
                source: root.previewUrl
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
                smooth: false // Nearest Neighbor фильтрация для четких пикселей в превью
            }

            // Заглушка, если ничего не выбрано
            Label {
                anchors.centerIn: parent
                text: qsTr("Кликните на файл\nдля превью")
                horizontalAlignment: Text.AlignHCenter
                color: "#78909C"
                font.pointSize: 9
                // ИСПРАВЛЕНО: previewImage теперь гарантированно объявлен выше и доступен для проверки статуса
                visible: previewImage.status !== Image.Ready
            }
        }
    }
}
