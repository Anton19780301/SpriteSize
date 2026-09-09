cmake_minimum_required(VERSION 3.16)

# Имя проекта оставляем SpriteSize
project(SpriteSize VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick LinguistTools QuickControls2 Concurrent)

# Настройка стандартов путей ресурсов (убирает предупреждение QTP0001)
qt_standard_project_setup()

# ИСПРАВЛЕНО: Называем исполняемый файл spritesize (с маленькой буквы),
# чтобы линкер Linux не конфликтовал с именем папки репозитория "SpriteSize"
add_executable(spritesize
    src/main.cpp
    src/processor.cpp
    src/processor.h
    src/translator.cpp
    src/translator.h
)

# --- БЛОК ПЕРЕВОДА (ИСПРАВЛЕНО ДЛЯ WINDOWS CI) ---
# ИСПРАВЛЕНО: Убрали абсолютные пути CMAKE_CURRENT_SOURCE_DIR.
# Относительные пути страхуют парсер метатипов Qt от падения на Windows-серверах
set(TS_FILES
    "i18n/spritesize_en.ts"
    "i18n/spritesize_ru.ts"
)

qt_add_translations(spritesize
    TS_FILES ${TS_FILES}
    QM_FILES_OUTPUT_VARIABLE QM_FILES
)

if(QM_FILES)
    target_sources(spritesize PRIVATE ${QM_FILES})
endif()
# ------------------------------------------------

# Передаем наш QML модуль исполняемому файлу spritesize
qt_add_qml_module(spritesize
    URI SpriteSize
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/TabInput.qml
        qml/TabProcess.qml
        qml/TabSettings.qml
        qml/TabAbout.qml
        qml/AssetList.qml
)

target_link_libraries(spritesize PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Concurrent
)

if(WIN32)
    set_target_properties(spritesize PROPERTIES WIN32_EXECUTABLE ON)
endif()
