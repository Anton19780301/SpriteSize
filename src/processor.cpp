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

    // Передаем m_startIndex шестым параметром в поток
    QtConcurrent::run(&ImageProcessor::processTask, this, targetWidth, targetHeight, useNearestNeighbor, targetFormat, m_renameMask, m_startIndex);
}

void ImageProcessor::processTask(int targetWidth, int targetHeight, bool useNearestNeighbor, const QString &targetFormat, const QString &renameMask, int startIndex) {
    QDir dir(m_inputPath);
    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    QString backupDirName = QString("_backup_%1").arg(timestamp);

    if (!dir.exists(backupDirName)) dir.mkdir(backupDirName);
    QDir backupDir(dir.filePath(backupDirName));

    int processedCount = 0;
    int fileIndex = startIndex; // ИСПРАВЛЕНО: Теперь счетчик инициализируется кастомным индексом из QML!
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
            int finalWidth = targetWidth;
            int finalHeight = targetHeight;

            if (targetWidth < 0) {
                int percent = qAbs(targetWidth);
                finalWidth = (img.width() * percent) / 100;
                finalHeight = (img.height() * percent) / 100;

                if (finalWidth < 1) finalWidth = 1;
                if (finalHeight < 1) finalHeight = 1;
            }

            QImage scaledImg = img.scaled(finalWidth, finalHeight, Qt::IgnoreAspectRatio, mode);

            QString targetExt = (targetFormat != "ORIGINAL") ? targetFormat.toLower() : QFileInfo(fileName).suffix().toLower();
            QString saveFormat = (targetFormat != "ORIGINAL") ? targetFormat : QFileInfo(fileName).suffix().toUpper();

            QString newFileName = fileName;

            if (!renameMask.isEmpty()) {
                QString maskCopy = renameMask;
                int hashCount = maskCopy.count('#');
                if (hashCount > 0) {
                    QString numberStr = QString("%1").arg(fileIndex, hashCount, 10, QChar('0'));
                    int firstHash = maskCopy.indexOf('#');
                    maskCopy.replace(firstHash, hashCount, numberStr);
                    newFileName = maskCopy + "." + targetExt;
                } else {
                    newFileName = renameMask + QString::number(fileIndex) + "." + targetExt;
                }
                fileIndex++;
            } else if (targetFormat != "ORIGINAL") {
                newFileName = QFileInfo(fileName).baseName() + "." + targetExt;
            }

            QString finalFilePath = dir.filePath(newFileName);

            if (scaledImg.save(finalFilePath, saveFormat.toLatin1().constData(), 90)) {
                processedCount++;
                if (origFilePath != finalFilePath) {
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

