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

void ImageProcessor::startProcessing(int targetWidth, int targetHeight, bool useNearestNeighbor, const QString &targetFormat) {
    m_progress = 1;
    emit progressChanged();
    m_statusMessage = tr("Запущено пакетное сжатие ассетов...");
    emit statusMessageChanged();
    QtConcurrent::run(&ImageProcessor::processTask, this, targetWidth, targetHeight, useNearestNeighbor, targetFormat, m_renameMask);
}

void ImageProcessor::processTask(int targetWidth, int targetHeight, bool useNearestNeighbor, const QString &targetFormat, const QString &renameMask) {
    QDir dir(m_inputPath);
    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    QString backupDirName = QString("_backup_%1").arg(timestamp);

    if (!dir.exists(backupDirName)) dir.mkdir(backupDirName);
    QDir backupDir(dir.filePath(backupDirName));

    int processedCount = 0;
    int fileIndex = 1;
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
            // --- РАСШИРЕНИЕ: ВЫЧИСЛЕНИЕ РАЗМЕРОВ (БЕЗ СЛОМА СТАРЫХ СПОСОБОВ) ---
            int finalWidth = targetWidth;
            int finalHeight = targetHeight;

            // Если пришло отрицательное число — значит включен процентный режим
            if (targetWidth < 0) {
                int percent = qAbs(targetWidth); // Получаем чистый процент (например, 50 из -50)
                finalWidth = (img.width() * percent) / 100;
                finalHeight = (img.height() * percent) / 100;

                // Защита, чтобы картинка не сжалась в 0 пикселей
                if (finalWidth < 1) finalWidth = 1;
                if (finalHeight < 1) finalHeight = 1;
            }

            // Теперь scaled использует finalWidth и finalHeight, сохраняя логику для обоих режимов
            QImage scaledImg = img.scaled(finalWidth, finalHeight, Qt::IgnoreAspectRatio, mode);
            // ------------------------------------------------------------------

            // 1. Вычисляем целевое расширение
            QString targetExt = (targetFormat != "ORIGINAL") ? targetFormat.toLower() : QFileInfo(fileName).suffix().toLower();
            QString saveFormat = (targetFormat != "ORIGINAL") ? targetFormat : QFileInfo(fileName).suffix().toUpper();

            // 2. РЕАЛИЗАЦИЯ МАССОВОГО ПЕРЕИМЕНОВАНИЯ (Код остался нетронутым)
            QString newFileName = fileName;

            if (!renameMask.isEmpty()) {
                QString maskCopy = renameMask;

                // Считаем сколько решеток '#' ввел пользователь (например, ##)
                int hashCount = maskCopy.count('#');
                if (hashCount > 0) {
                    // Форматируем число с ведущими нулями под количество решеток (например, 1 -> "01")
                    QString numberStr = QString("%1").arg(fileIndex, hashCount, 10, QChar('0'));
                    // Заменяем блок решеток на наше число
                    int firstHash = maskCopy.indexOf('#');
                    maskCopy.replace(firstHash, hashCount, numberStr);
                    newFileName = maskCopy + "." + targetExt;
                } else {
                    // Если решеток нет, просто пишем маску и число в конец (например, TX_Building1)
                    newFileName = renameMask + QString::number(fileIndex) + "." + targetExt;
                }
                fileIndex++;
            } else if (targetFormat != "ORIGINAL") {
                // Если переименования нет, но меняется формат, просто меняем расширение
                newFileName = QFileInfo(fileName).baseName() + "." + targetExt;
            }

            QString finalFilePath = dir.filePath(newFileName);

            if (scaledImg.save(finalFilePath, saveFormat.toLatin1().constData(), 90)) {
                processedCount++;
                // Если новое имя или путь отличаются от исходного, зачищаем старый файл в рабочей папке
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

