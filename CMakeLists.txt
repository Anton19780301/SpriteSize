cmake_minimum_required(VERSION 3.22)

project(SpriteSize VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Concurrent
    LinguistTools
)

# Включает современные политики Qt для CMake.
# Для qt_add_qml_module это особенно важно.
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(spritesize
    src/main.cpp
    src/processor.cpp
    src/processor.h
    src/translator.cpp
    src/translator.h
    resources.qrc
)

set(TS_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/i18n/spritesize_en.ts
    ${CMAKE_CURRENT_SOURCE_DIR}/i18n/spritesize_ru.ts
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

target_link_libraries(spritesize PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Concurrent
)

if(WIN32)
    set_target_properties(spritesize PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()

