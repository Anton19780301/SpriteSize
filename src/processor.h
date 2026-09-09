#ifndef PROCESSOR_H
#define PROCESSOR_H

#include <QObject>
#include <QString>
#include <QVariantList>

class ImageProcessor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString inputPath READ inputPath WRITE setInputPath NOTIFY inputPathChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QVariantList assetModel READ assetModel NOTIFY assetModelChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)

public:
    explicit ImageProcessor(QObject *parent = nullptr);

    QString inputPath() const { return m_inputPath; }
    void setInputPath(const QString &path);

    int progress() const { return m_progress; }
    QVariantList assetModel() const { return m_assetModel; }

    Q_INVOKABLE void scanDirectory();
    Q_INVOKABLE void toggleAssetSelection(int index, bool selected);
    Q_INVOKABLE void startProcessing(int targetWidth, int targetHeight, bool useNearestNeighbor);

    QString statusMessage() const { return m_statusMessage; }
    void setStatusMessage(const QString &message);

signals:
    void inputPathChanged();
    void progressChanged();
    void assetModelChanged();
    void processingFinished(int totalProcessed, const QString &message);
    void statusMessageChanged();

private:
    QString m_inputPath;
    int m_progress = 0;
    QVariantList m_assetModel; // Хранит список QVariantMap (словарей) с данными файлов
    QString m_statusMessage = "Программа готова к работе";
};

#endif // PROCESSOR_H
