#pragma once

#include <QObject>
#include <QTranslator>
#include "processor.h"
#include <QQmlApplicationEngine>

class Translator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)

public:

    explicit Translator(QQmlApplicationEngine *engine, ImageProcessor *processor, QObject *parent = nullptr);
    QString currentLanguage() const { return m_currentLang; }
    Q_INVOKABLE void selectLanguage(const QString &language);

signals:
    void languageChanged();

private:
    QQmlApplicationEngine *m_engine = nullptr;
    QTranslator *m_translator = nullptr;
    QString m_currentLang = "ru"; // По умолчанию запускаемся на русском
    ImageProcessor *m_processor = nullptr;

};



