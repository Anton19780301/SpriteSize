#include "translator.h"
#include <QGuiApplication>
#include <QFile>
#include <QDir>
#include <QCoreApplication>

Translator::Translator(QQmlApplicationEngine *engine, ImageProcessor *processor, QObject *parent)
    : QObject(parent), m_engine(engine), m_processor(processor)
{
    m_translator = new QTranslator(this);
}

void Translator::selectLanguage(const QString &language) {
    if (m_currentLang == language && m_translator->isEmpty() == false) return;

    qApp->removeTranslator(m_translator);

    QString appDir = QCoreApplication::applicationDirPath();
    QDir dir(appDir);
    QString qmFileName = QString("spritesize_%1.qm").arg(language);
    QString qmPath = dir.filePath(qmFileName);

    if (m_translator->load(qmPath)) {
        qApp->installTranslator(m_translator);
        m_currentLang = language;
        if (m_engine) {
            m_engine->retranslate();
        }
        if (m_processor) {
            m_processor->setStatusMessage(tr("Язык интерфейса успешно изменен"));
        }
    } else {
        if (m_processor) {
            m_processor->setStatusMessage(tr("Ошибка: файл локализации %1 не найден на диске!").arg(qmFileName));
        }
    }
}
