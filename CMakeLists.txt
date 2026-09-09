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

add_executable(spritesize
    src/main.cpp
    src/processor.cpp
    src/processor.h
    src/translator.cpp
    src/translator.h
    resources.qrc
)


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

if(NOT TARGET Qt6::QImageFormatsPlugin)
    add_library(Qt6::QImageFormatsPlugin MODULE IMPORTED)
    # Используем твой физический путь (симлинк C:\Qt)
    set_target_properties(Qt6::QImageFormatsPlugin PROPERTIES
        IMPORTED_LOCATION "C:/Qt/6.11.2/mingw_64/plugins/imageformats/qwebp.dll" # или qtiff.dll, подставится вся папка
    )
endif()

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
