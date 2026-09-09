\# SpriteSize 🎮 🗜️



\*\*SpriteSize\*\* is a lightweight, high-performance desktop utility designed for indie game developers and digital artists. It solves a common modern geymdev pain point: quickly downscaling heavy, high-resolution AI-generated artwork (e.g., 1024x1024) into optimal game-ready sprite dimensions (64x64, 128x128, etc.) while keeping pixels perfectly sharp.



Built natively with \*\*C++17\*\* and \*\*Qt 6 / QML Quick Controls 2\*\*, the app features a sleek modern workflow, robust architecture, and production-ready safety mechanisms.



\---



\## ✨ Key Features



\*   \*\*⚡ Non-Blocking Multithreading:\*\* Heavy image processing tasks are entirely offloaded to background threads using `QtConcurrent`. The GUI remains 100% responsive, showcasing a smooth real-time progress bar.

\*   \*\*👾 Nearest-Neighbor Filtration:\*\* Includes a dedicated "Pixel-Art" mode (`Qt::FastTransformation`) to downscale textures without blurs or artifacts—critical for clean Godot/Unity 2D rendering.

\*   \*\*📦 Time-Stamped Automatic Backups:\*\* Every batch operation automatically seals clean original assets inside a safe, unique `\_backup\_YYYYMMDD\_HHMMSS` directory. Zero chance of accidentally destroying raw assets.

\*   \*\*👁️ Interactive Asset Manager \& Preview:\*\* Live folder scanning outputs a list of matching images with reactive checkboxes. Select a file to view it instantly over an advanced Canvas-drawn transparency checkerboard.

\*   \*\*🌐 Real-Time Dynamic Localization:\*\* Swap interface languages on-the-fly (English / Russian) from the settings tab. Translations are smoothly updated across all components without app restarts.



\---



\## 🛠️ Technical Stack \& Architecture



\*   \*\*Language:\*\* C++17 (Core Logic) + QML / JavaScript (UI Layer)

\*   \*\*Framework:\*\* Qt 6.10+ (Core, Gui, Qml, Quick, QuickControls2, Concurrent, LinguistTools)

\*   \*\*Build System:\*\* CMake (Optimized for decoupled asset pipeline target structures)

\*   \*\*Design Pattern:\*\* Clean Separation of Concerns via C++ Context Properties injection into declarative QML layouts.



\---



\## 🚀 Getting Started (Building from Source)



\### Prerequisites

\*   Windows 10 / 11

\*   Qt SDK 6.5 or newer (Tested up to Qt 6.10.1 MinGW)

\*   CMake 3.16+



\### Compilation Steps

1\. Clone the repository:

&#x20;  ```bash

&#x20;  git clone https://github.com

&#x20;  cd SpriteSize

&#x20;  ```

2\. Open the `CMakeLists.txt` file directly in \*\*Qt Creator\*\*.

3\. Clear CMake Cache and Run CMake Configuration.

4\. Hit \*\*Ctrl + R\*\* to compile and run the application!



\*Note on Localizations:\* The compiled binary automatically looks for physical `spritesize\_en.qm` and `spritesize\_ru.qm` translation sheets inside the application executable path directory.



\---



\## 📄 License \& Crediting Request



This utility is distributed completely free under the \*\*MIT License\*\* — see the \[LICENSE](LICENSE) file for details.



\### 🎮 Note for Game Developers

While the MIT license only legally requires keeping the copyright notices in the raw software files, if you actively use \*\*SpriteSize\*\* to optimize pipelines for a commercial or open-source game project, I would highly appreciate a small mention in your game's final credits! \*(e.g., "Special Thanks / Asset Tools: SpriteSize by Anton")\*. It costs nothing but greatly helps an indie engineer's portfolio!



