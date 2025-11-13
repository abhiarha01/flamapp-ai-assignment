# FlamApp AI Android + OpenCV + OpenGL ES Starter

An Android starter repository integrating:
- Kotlin app with Camera2 capture and toggle between raw vs processed view
- Native C++ image processing via JNI using OpenCV (grayscale + Canny)
- OpenGL ES 2.0 renderer for real-time display
- TypeScript web viewer for a saved processed frame

Requirements:
- Android Studio (Giraffe or newer) with SDK 34
- NDK r26+ (installed via SDK Manager)
- Java 17+
- Git, curl, unzip
- Node.js 18+ (for the web viewer)
- ADB (Android Platform Tools)

Project structure

```
.
├─ app/                       # Android application module
│  ├─ src/main/cpp/           # C++ sources (OpenCV processing + JNI)
│  ├─ src/main/assets/shaders # GLSL shaders
│  └─ src/main/java           # Kotlin sources
├─ gradle/                    # Gradle wrapper config (bootstrapped by script)
├─ scripts/                   # Helper scripts
│  ├─ bootstrap_gradle_wrapper.(sh|ps1)
│  ├─ setup_opencv_android.(sh|ps1)
│  └─ pull_processed_sample.(sh|ps1)
├─ third_party/               # OpenCV SDK (downloaded by script)
└─ web/                       # Web viewer (TypeScript)
```

Quick start

1) Bootstrap Gradle wrapper (first time only)
- Windows (PowerShell):
  - scripts/bootstrap_gradle_wrapper.ps1
- macOS/Linux:
  - bash scripts/bootstrap_gradle_wrapper.sh

2) Download and integrate OpenCV Android SDK
- Windows (PowerShell):
  - scripts/setup_opencv_android.ps1
- macOS/Linux:
  - bash scripts/setup_opencv_android.sh

This will:
- Download OpenCV Android SDK to third_party/OpenCV-android-sdk
- Copy OpenCV AAR to app/libs/opencv.aar
- Copy native .so files to app/src/main/jniLibs/<abi>/
- Write opencv.dir=<absolute sdk path> to local.properties

3) Build Android app
- ./gradlew assembleDebug

Notes:
- The wrapper jar is fetched by scripts/bootstrap_gradle_wrapper.*; if ./gradlew fails with missing wrapper, run the script again.
- If CMake cannot find OpenCV, ensure local.properties contains opencv.dir pointing to the SDK root (the directory with sdk/ inside it).

4) Run the app
- Install on a device: ./gradlew installDebug
- Launch "FlamApp AI". On first launch, the app saves one demo processed frame (processed_sample.png) into its external files directory.

5) Copy the processed frame to the web viewer
- With the device connected and ADB authorized:
  - Windows (PowerShell): scripts/pull_processed_sample.ps1
  - macOS/Linux: bash scripts/pull_processed_sample.sh

This copies the image to web/assets/processed_sample.png.

6) Web viewer
- cd web
- npm install
- npm run build
- npm run dev
- Open http://localhost:5173 to view the image with an overlay (FPS and resolution).

Architecture

```
[Kotlin Camera2] -> [SurfaceTexture] -> [OpenGL ES Renderer]
        |                                  ^
        v                                  |
  [Image Bytes (demo)] -> [JNI] -> [C++ OpenCV: Gray + Canny] -> [PNG save]
```

Troubleshooting
- If Gradle wrapper is missing: run scripts/bootstrap_gradle_wrapper.(sh|ps1)
- If OpenCV not found: run scripts/setup_opencv_android.(sh|ps1) and verify local.properties opencv.dir
- NDK/CMake errors: see BUILD_NOTES.md

Screenshots
- Placeholder: app screenshot and web viewer screenshot (to be added)

License
- MIT
