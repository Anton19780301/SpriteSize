#include "processor.h"
#include <QDir>
#include <QFileInfo>
#include <QImage>
#include <QVariantMap>
#include <QUrl>

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

void ImageProcessor::startProcessing(int targetWidth, int targetHeight, bool useNearestNeighbor) {
    m_progress = 0;
    emit progressChanged();

    QDir dir(m_inputPath);
    if (!dir.exists()) {
        m_statusMessage = tr("Ошибка: указанная папка не существует!");
        emit statusMessageChanged();
        emit processingFinished(0, tr("Указанная папка не существует!"));
        return;
    }

    if (m_assetModel.isEmpty()) {
        m_statusMessage = tr("Ошибка: нет файлов для обработки.");
        emit statusMessageChanged();
        emit processingFinished(0, tr("Нет файлов для обработки."));
        return;
    }

    m_statusMessage = tr("Запущено пакетное сжатие ассетов...");
    emit statusMessageChanged();

    // Создаем изолированную подпапку для бэкапов исходников
    QString backupDirName = "_backup";
    if (!dir.exists(backupDirName)) {
        dir.mkdir(backupDirName);
    }
    QDir backupDir(dir.filePath(backupDirName));

    int processedCount = 0;
    // Выбираем алгоритм: FastTransformation (Nearest Neighbor) для пиксель-арта, Smooth для гладких ИИ-картинок
    Qt::TransformationMode mode = useNearestNeighbor ? Qt::FastTransformation : Qt::SmoothTransformation;

    for (int i = 0; i < m_assetModel.size(); ++i) {
        QVariantMap asset = m_assetModel.at(i).toMap();

        //Если пользователь снял галочку с текстуры, полностью её игнорируем
        if (!asset["checked"].toBool()) {
            continue;
        }

        QString fileName = asset["fileName"].toString();
        QString origFilePath = dir.filePath(fileName);
        QString backupFilePath = backupDir.filePath(fileName);

        //делаем бэкап, копируя оригинальный файл (если его там еще нет)
        if (!backupDir.exists(fileName)) {
            QFile::copy(origFilePath, backupFilePath);
        }

        //загружаем изображение из папки бэкапа, чтобы не жать уже пережатый файл
        QImage img;
        if (img.load(backupFilePath)) {
            QImage scaledImg = img.scaled(targetWidth, targetHeight, Qt::IgnoreAspectRatio, mode);
            // Сохраняем результат обратно в рабочую папку проекта
            if (scaledImg.save(origFilePath)) {
                processedCount++;
            }
        }

        // Двигаем шкалу прогресс-бара
        m_progress = static_cast<int>(((i + 1) * 100) / m_assetModel.size());
        emit progressChanged();
    }

    m_statusMessage = tr("Сжатие завершено! Успешно обработано файлов: %1").arg(processedCount);
    emit statusMessageChanged();
    emit processingFinished(processedCount, tr("Обработка успешно завершена!"));
    scanDirectory();
}
