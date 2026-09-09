#include "processor.h"
#include <QDir>
#include <QFileInfo>
#include <QImage>
#include <QVariantMap>
#include <QUrl>
#include <QtConcurrent>
#include <QDateTime>

ImageProcessor::ImageProcessor(QObject *parent) : QObject(parent) {}

void ImageProcessor::setInputPath(const QString &path) {
    if (m_inputPath != path) {
        m_inputPath = path;
        emit inputPathChanged();
        scanDirectory();
    }
}

void ImageProcessor::scanDirectory() {
    m_assetModel.clear();

    QDir dir(m_inputPath);
    if (!dir.exists()) {
        m_statusMessage = tr("Указанная папка не существует!");
        emit statusMessageChanged();
        emit assetModelChanged();
        return;
    }

    QStringList filters;
    filters << "*.png" << "*.jpg" << "*.jpeg" << "*.webp" << "*.bmp";
    QFileInfoList files = dir.entryInfoList(filters, QDir::Files);

    if (files.isEmpty()) {
        m_statusMessage = tr("Папка открыта. Поддерживаемых текстур не найдено.");
    } else {
        m_statusMessage = tr("Успешно открыто. Обнаружено текстур: %1").arg(files.size());
    }
    emit statusMessageChanged(); // Оповещаем QML статус-бар

    for (const QFileInfo &fileInfo : files) {
        QVariantMap asset;
        asset["fileName"] = fileInfo.fileName();
        // Превращаем локальный путь в URL-формат (file:///...) для элемента Image в QML
        asset["fileUrl"] = QUrl::fromLocalFile(fileInfo.filePath()).toString();
        asset["checked"] = true; // По умолчанию все галочки проставлены

        m_assetModel.append(asset);
    }

    emit assetModelChanged();
}

void ImageProcessor::toggleAssetSelection(int index, bool selected) {
    if (index >= 0 && index < m_assetModel.size()) {
        QVariantMap asset = m_assetModel[index].toMap();
        asset["checked"] = selected;
        m_assetModel[index] = asset;
    }
}

void ImageProcessor::setStatusMessage(const QString &message) {
    if (m_statusMessage != message) {
        m_statusMessage = message;
        emit statusMessageChanged();
    }
}

void ImageProcessor::setAllAssetsChecked(bool checked) {
    if (m_assetModel.isEmpty()) return;

    for (int i = 0; i < m_assetModel.size(); ++i) {
        QVariantMap asset = m_assetModel[i].toMap();
        asset["checked"] = checked;
        m_assetModel[i] = asset;
    }

    emit assetModelChanged();
}

void ImageProcessor::startProcessing(int targetWidth, int targetHeight, bool useNearestNeighbor, const QString &targetFormat) {
    m_progress = 1;
    emit progressChanged();
    m_statusMessage = tr("Запущено пакетное сжатие ассетов...");
    emit statusMessageChanged();
    QtConcurrent::run(&ImageProcessor::processTask, this, targetWidth, targetHeight, useNearestNeighbor, targetFormat);
}

void ImageProcessor::processTask(int targetWidth, int targetHeight, bool useNearestNeighbor, const QString &targetFormat) {
    QDir dir(m_inputPath);
    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    QString backupDirName = QString("_backup_%1").arg(timestamp);

    if (!dir.exists(backupDirName)) dir.mkdir(backupDirName);
    QDir backupDir(dir.filePath(backupDirName));

    int processedCount = 0;
    Qt::TransformationMode mode = useNearestNeighbor ? Qt::FastTransformation : Qt::SmoothTransformation;

    for (int i = 0; i < m_assetModel.size(); ++i) {
        QVariantMap asset = m_assetModel.at(i).toMap();
        if (!asset["checked"].toBool()) continue;

        QString fileName = asset["fileName"].toString();
        QString origFilePath = dir.filePath(fileName);
        QString backupFilePath = backupDir.filePath(fileName);

        QFile::copy(origFilePath, backupFilePath);

        QImage img;
        if (img.load(backupFilePath)) {
            QImage scaledImg = img.scaled(targetWidth, targetHeight, Qt::IgnoreAspectRatio, mode);

            // Вычисляем выходной путь и формат
            QString finalFilePath = origFilePath;
            QString saveFormat = QFileInfo(fileName).suffix().toUpper(); // По умолчанию формат оригинала

            if (targetFormat != "ORIGINAL") {
                saveFormat = targetFormat;
                QFileInfo info(origFilePath);
                finalFilePath = info.absolutePath() + "/" + info.baseName() + "." + targetFormat.toLower();
            }

            if (scaledImg.save(finalFilePath, saveFormat.toLatin1().constData(), 90)) {
                processedCount++;
                if (targetFormat != "ORIGINAL" && origFilePath != finalFilePath) {
                    QFile::remove(origFilePath);
                }
            }
        }

        m_progress = static_cast<int>(((i + 1) * 100) / m_assetModel.size());
        emit progressChanged();
        QThread::msleep(30);
    }

    m_progress = 100;
    emit progressChanged();
    m_statusMessage = tr("Сжатие и конвертация завершены! Обработано: %1").arg(processedCount);
    emit statusMessageChanged();
    emit processingFinished(processedCount, tr("Обработка успешно завершена!"));
    scanDirectory();
}

