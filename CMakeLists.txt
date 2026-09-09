cmake_minimum_required(VERSION 3.16)
project(SpriteSize VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)


find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick LinguistTools QuickControls2 Concurrent)


qt_standard_project_setup()

add_executable(SpriteSize
    src/main.cpp
    src/processor.cpp
    src/processor.h
    src/translator.cpp
    src/translator.h
)

# --- БЛОК ПЕРЕВОДА ---
set(TS_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/i18n/spritesize_en.ts"
    "${CMAKE_CURRENT_SOURCE_DIR}/i18n/spritesize_ru.ts"
)

qt_add_translations(SpriteSize
    TS_FILES ${TS_FILES}
    QM_FILES_OUTPUT_VARIABLE QM_FILES
)

if(QM_FILES)
    target_sources(SpriteSize PRIVATE ${QM_FILES})
endif()
# ------------------------------------------------

qt_add_qml_module(SpriteSize
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

target_link_libraries(SpriteSize PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Concurrent
)

if(WIN32)
    set_target_properties(SpriteSize PROPERTIES WIN32_EXECUTABLE ON)
endif()
