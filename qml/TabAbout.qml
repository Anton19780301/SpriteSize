import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 15

        // Логотип/Название проекта
        Label {
            text: "SpriteSize"
            font.bold: true
            font.pointSize: 24
            color: "#0d6efd" // Красивый геймдев-синий цвет
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: qsTr("Версия 1.0 (Open Source)")
            font.italic: true
            font.pointSize: 10
            color: "#666666"
            Layout.alignment: Qt.AlignHCenter
        }

        // Декоративный разделитель
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#E0E0E0"
            Layout.topMargin: 5
            Layout.bottomMargin: 10
        }

        // Описание утилиты
        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pointSize: 10
            color: "#444444"
            lineHeight: 1.3
            text: qsTr("SpriteSize — это легковесная и быстрая утилита для пакетного сжатия текстур, созданная специально для инди-разработчиков и игровых дизайнеров. Она позволяет мгновенно оптимизировать тяжелые ИИ-арты высокого разрешения (1024х1024 и более) под размеры игровых спрайтов (например, 64х64) с использованием алгоритма «Ближайший сосед» для сохранения идеальной четкости пикселей.")
        }

        Item { Layout.fillHeight: true } // Выталкивает кнопку к нижнему краю

        // Кнопка ссылки на GitHub репозиторий
        Button {
            id: githubBtn
            text: "🔗  " + qsTr("Открыть проект на GitHub")
            font.bold: true
            font.pointSize: 10
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 240
            Layout.preferredHeight: 40

            contentItem: Text {
                text: githubBtn.text
                font: githubBtn.font
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: githubBtn.hovered ? "#24292e" : "#333333" // Цвета в стиле GitHub
                radius: 6
                border.color: "#24292e"
            }

            // Открывает ссылку в стандартном браузере операционной системы
            onClicked: {
                Qt.openUrlExternally("https://github.com")
            }
        }
    }
}
