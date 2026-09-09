#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QObject>
#include <QTranslator>
#include <QQmlApplicationEngine>

class Translator : public QObject
{
    Q_OBJECT
    // Позволяет QML узнавать текущий язык (например, для ComboBox)
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)

public:
    explicit Translator(QQmlApplicationEngine *engine, QObject *parent = nullptr);

    QString currentLanguage() const { return m_currentLang; }

    // Метод для вызова из QML при смене языка в настройках
    Q_INVOKABLE void selectLanguage(const QString &language);

signals:
    void languageChanged();

private:
    QQmlApplicationEngine *m_engine = nullptr;
    QTranslator *m_translator = nullptr;
    QString m_currentLang = "ru"; // По умолчанию запускаемся на русском
};

#endif // TRANSLATOR_H
