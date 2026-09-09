#include "translator.h"
#include <QGuiApplication>
#include <QDir>

Translator::Translator(QQmlApplicationEngine *engine, QObject *parent)
    : QObject(parent), m_engine(engine)
{
    m_translator = new QTranslator(this);
}

void Translator::selectLanguage(const QString &language) {
    if (m_currentLang == language) return;

    qApp->removeTranslator(m_translator);

    // Файлы .qm лежат в ресурсах по пути, заданному CMake
    QString qmPath = QString(":/qt/qml/SpriteSize/i18n/spritesize_%1.qm").arg(language);

    // Если по первому пути не нашлось, проверяем альтернативный корень
    if (!QFile::exists(qmPath)) {
        qmPath = QString(":/SpriteSize/i18n/spritesize_%1.qm").arg(language);
    }

    if (m_translator->load(qmPath)) {
        qApp->installTranslator(m_translator);
        m_currentLang = language;
        emit languageChanged();

        // Магия Qt 6: заставляем QML перерисовать все строки с qsTr()
        if (m_engine) {
            m_engine->retranslate();
        }
    }
}
