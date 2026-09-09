#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle> // 1. Подключаем заголовочный файл стилей
#include "processor.h"
#include "translator.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 2. Устанавливаем универсальный стиль ("Basic" или "Fusion") до загрузки QML
    // Это разрешит кастомизацию фонов (background) и текстовых элементов (contentItem)
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    ImageProcessor processor;
    Translator translator(&engine);

    engine.rootContext()->setContextProperty("imageProcessor", &processor);
    engine.rootContext()->setContextProperty("appTranslator", &translator);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [](QObject *obj, const QUrl &objUrl) {
                         if (!obj)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.loadFromModule("SpriteSize", "Main");

    return app.exec();
}
