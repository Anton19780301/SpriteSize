#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "processor.h"
#include "translator.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");
    QQmlApplicationEngine engine;
    ImageProcessor processor;
    Translator translator(&engine, &processor);

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
