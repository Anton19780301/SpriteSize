#ifndef PROCESSOR_H
#define PROCESSOR_H
#include <QObject>

class ImageProcessor : public QObject {
    Q_OBJECT
public:
    explicit ImageProcessor(QObject *parent = nullptr) : QObject(parent) {}
};
#endif
