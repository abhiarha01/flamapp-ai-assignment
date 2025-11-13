# FlamApp AI Android + OpenCV + OpenGL ES Starter

A complete Android application demonstrating real-time camera processing with OpenCV and OpenGL ES rendering.

## Features

- **Camera2 API Integration**: Real-time camera capture with permission handling
- **Native C++ Processing**: OpenCV-based image processing (grayscale conversion + Canny edge detection)
- **JNI Bridge**: Efficient Kotlin ↔ C++ communication
- **OpenGL ES 2.0**: Hardware-accelerated rendering with custom shaders
- **Toggle View**: Switch between raw camera feed and processed output
- **TypeScript Web Viewer**: Standalone viewer for processed frames with overlay
- **Multi-ABI Support**: arm64-v8a, armeabi-v7a, x86_64

## Requirements

- **Android Studio** (Giraffe 2022.3.1 or newer) with SDK 34
- **NDK** r26+ (install via SDK Manager → SDK Tools → NDK)
- **Java** 17 or newer
- **Git**, **curl**, **unzip** (for setup scripts)
- **Node.js** 18+ (for web viewer)
- **ADB** (Android Platform Tools) for device testing

## Project Structure

```
.
├─ .github/workflows/            # CI/CD workflows
│  └─ android-build.yml          # GitHub Actions build
├─ app/                          # Android application module
│  ├─ src/main/
│  │  ├─ cpp/                    # Native C++ code
│  │  │  ├─ CMakeLists.txt       # CMake build configuration
│  │  │  ├─ processor.h/cpp      # OpenCV processing functions
│  │  │  └─ processor_jni.cpp    # JNI bridge implementation
│  │  ├─ assets/shaders/         # GLSL vertex & fragment shaders
│  │  ├─ java/com/flamapp/ai/    # Kotlin application code
│  │  │  ├─ MainActivity.kt      # Entry point & camera permission
│  │  │  ├─ gl/                  # OpenGL ES components
│  │  │  └─ nativebridge/        # JNI bridge (NativeProcessor)
│  │  ├─ res/                    # Android resources (layouts, themes)
│  │  └─ AndroidManifest.xml     # App manifest & permissions
│  ├─ build.gradle.kts           # App-level build config
│  └─ proguard-rules.pro         # ProGuard/R8 rules
├─ gradle/wrapper/               # Gradle wrapper (bootstrapped)
├─ scripts/                      # Setup & utility scripts
│  ├─ bootstrap_gradle_wrapper   # Downloads Gradle wrapper JAR
│  ├─ setup_opencv_android       # Downloads & configures OpenCV
│  └─ pull_processed_sample      # Pulls processed PNG from device
├─ third_party/                  # External dependencies (git-ignored)
│  └─ OpenCV-android-sdk/        # Downloaded by setup script
├─ web/                          # TypeScript web viewer
│  ├─ src/index.ts               # Viewer logic
│  ├─ assets/                    # Processed images from device
│  ├─ index.html                 # Viewer HTML
│  ├─ package.json               # NPM dependencies
│  └─ tsconfig.json              # TypeScript config
├─ build.gradle.kts              # Root build configuration
├─ settings.gradle.kts           # Gradle project settings
├─ local.properties.example      # Template for local.properties
├─ README.md                     # This file
├─ BUILD_NOTES.md                # Troubleshooting tips
└─ WARP.md                       # Warp AI assistant guidance
```

## Quick Start

### Prerequisites Setup

**1. Configure local.properties** (First time only)

```bash
# Copy the example template
cp local.properties.example local.properties

# Edit local.properties and set your Android SDK path:
# Windows: sdk.dir=C\:\\Users\\YourName\\AppData\\Local\\Android\\Sdk
# macOS:   sdk.dir=/Users/YourName/Library/Android/sdk
# Linux:   sdk.dir=/home/YourName/Android/Sdk
```

**2. Bootstrap Gradle Wrapper** (First time only)

```bash
# Windows (PowerShell)
scripts/bootstrap_gradle_wrapper.ps1

# macOS/Linux
bash scripts/bootstrap_gradle_wrapper.sh
```

This downloads the Gradle wrapper JAR required for building.

**3. Download and Setup OpenCV Android SDK**

```bash
# Windows (PowerShell)
scripts/setup_opencv_android.ps1

# macOS/Linux
bash scripts/setup_opencv_android.sh
```

This will:
- Download OpenCV 4.10.0 Android SDK to `third_party/OpenCV-android-sdk`
- Copy OpenCV AAR to `app/libs/opencv.aar`
- Copy native `.so` files to `app/src/main/jniLibs/<abi>/`
- Automatically set `opencv.dir` in `local.properties`

### Building the Android App

**Build debug APK:**

```bash
./gradlew assembleDebug
```

**Install on connected device:**

```bash
./gradlew installDebug
```

**Launch the app:**
- Open "FlamApp AI" on your device
- Grant camera permission when prompted
- Use toggle button to switch between raw/processed view
- A demo processed frame is saved to device on first launch

### Testing the Web Viewer

**1. Pull processed image from device:**

```bash
# Windows (PowerShell)
scripts/pull_processed_sample.ps1

# macOS/Linux
bash scripts/pull_processed_sample.sh
```

This copies the processed image to `web/assets/processed_sample.png`.

**2. Run web viewer:**

```bash
cd web
npm install
npm run build
npm run dev
```

Open http://localhost:5173 to view the processed frame with overlay.

### Common Issues

- **Gradle wrapper missing**: Run `scripts/bootstrap_gradle_wrapper.*` again
- **OpenCV not found**: Verify `local.properties` contains `opencv.dir` pointing to the SDK root
- **CMake errors**: Ensure NDK r26+ is installed via Android Studio SDK Manager
- **ADB issues**: Enable USB debugging and authorize your computer on the device

See [BUILD_NOTES.md](BUILD_NOTES.md) for detailed troubleshooting.

## Architecture

### High-Level Data Flow

```
┌──────────────────┐
│  Camera2 API     │
│  (Kotlin)        │
└────────┬─────────┘
         │
         │ Camera frames
         │
         v
┌──────────────────┐      ┌──────────────────┐
│ SurfaceTexture  │─────>│  OpenGL ES 2.0  │
│  (GL texture)   │      │   Renderer       │
└────────┬─────────┘      └────────┬─────────┘
         │                        │
         │ Demo frame             │ Display
         │                        │
         v                        v
┌──────────────────┐      ┌──────────────────┐
│  JNI Bridge      │      │    Screen        │
│ (Kotlin↔C++)   │      └──────────────────┘
└────────┬─────────┘
         │
         │ RGBA bytes
         │
         v
┌──────────────────┐
│ C++ OpenCV      │
│ Processor       │
│                 │
│ 1. Grayscale    │
│ 2. Canny edges  │
└────────┬─────────┘
         │
         │ Processed RGBA
         │
         v
┌──────────────────┐
│  PNG save to     │
│  device storage  │
└────────┬─────────┘
         │
         │ ADB pull
         │
         v
┌──────────────────┐
│  Web Viewer      │
│  (TypeScript)    │
└──────────────────┘
```

### Component Breakdown

#### 1. Kotlin Layer (`app/src/main/java/com/flamapp/ai/`)

- **MainActivity.kt**: Application entry point
  - Manages camera permissions
  - Initializes GLFrameView
  - Saves demo processed frame on startup
  
- **gl/GLFrameView.kt**: Custom GLSurfaceView
  - Wraps Camera2 capture session
  - Manages SurfaceTexture for camera preview
  - Handles processed view toggle
  
- **gl/GLRenderer.kt**: OpenGL ES 2.0 renderer
  - Renders camera frames using SurfaceTexture
  - Loads and applies GLSL shaders
  - Currently uses placeholder shader (future: apply processed texture)
  
- **nativebridge/NativeProcessor.kt**: JNI bridge
  - Loads native library: `System.loadLibrary("native-processor")`
  - Exposes `processRgba()` method to call C++ processing

#### 2. Native C++ Layer (`app/src/main/cpp/`)

- **processor.h/cpp**: Core OpenCV processing
  - `process_rgba()`: RGBA → Grayscale → Canny edge detection → RGBA
  - `save_png()`: Saves processed frame as PNG using cv::imwrite()
  
- **processor_jni.cpp**: JNI implementation
  - `Java_com_flamapp_ai_nativebridge_NativeProcessor_processRgba()`
  - Marshals Java byte arrays to/from C++ vectors
  - Calls OpenCV processing functions
  
- **CMakeLists.txt**: CMake build configuration
  - Links OpenCV static/shared libraries
  - Configures include paths for OpenCV headers
  - Builds `libnative-processor.so` for target ABIs

#### 3. OpenGL ES Integration

- **Shaders** (`app/src/main/assets/shaders/`)
  - `simple.vert`: Vertex shader (position + texture coords)
  - `simple.frag`: Fragment shader (texture sampling)
  
- **Note**: Real-time processed rendering (ImageReader → JNI → GL texture pipeline) is planned for future iteration. Currently, rendering shows camera preview directly.

#### 4. Web Viewer (`web/`)

- **index.ts**: TypeScript logic
  - Loads processed image from assets
  - Updates overlay with image dimensions
  
- **index.html**: Viewer interface
  - Displays processed frame
  - Shows overlay with metadata (FPS, resolution)
  
- **Build**: TypeScript → JavaScript (`npm run build` → `dist/index.js`)

### Build System Flow

```
Gradle
  │
  ├─> Reads local.properties (sdk.dir, opencv.dir)
  │
  ├─> Invokes CMake with -DOpenCV_DIR=${opencv.dir}/sdk/native/jni
  │
  └─> CMake
       │
       ├─> find_package(OpenCV REQUIRED)
       │
       ├─> Compiles processor.cpp, processor_jni.cpp
       │
       ├─> Links OpenCV libs (libopencv_core.so, libopencv_imgproc.so, etc.)
       │
       └─> Outputs libnative-processor.so for arm64-v8a, armeabi-v7a, x86_64
```

### Key Technologies

- **Language**: Kotlin (Android), C++17 (Native), TypeScript (Web)
- **Build**: Gradle 8.7, CMake 3.22.1, NPM
- **Android**: Camera2 API, OpenGL ES 2.0, JNI, Material Design
- **Native**: OpenCV 4.10.0, NDK r26+
- **Web**: TypeScript 5.6, http-server

## Development Commands

### Android

```bash
# Clean build
./gradlew clean

# Build debug APK
./gradlew assembleDebug

# Build release APK
./gradlew assembleRelease

# Install on device
./gradlew installDebug

# Build native code only (C++/JNI)
./gradlew :app:externalNativeBuildDebug

# Run lint checks
./gradlew lint

# Generate dependency report
./gradlew :app:dependencies
```

### Web Viewer

```bash
cd web

# Install dependencies
npm install

# Build TypeScript
npm run build

# Run dev server
npm run dev
```

## Project Limitations

- **Real-time Processing**: Currently, the app saves a demo processed frame but does not apply OpenCV processing to the live camera feed in real-time. The GL renderer displays the raw camera preview.
  - **Future Work**: Implement ImageReader → JNI processing → GL texture update pipeline for frame-by-frame processing.
  
- **ABI Support**: Limited to arm64-v8a, armeabi-v7a, x86_64. Other ABIs (x86, mips) not supported.
  
- **OpenCV Setup**: OpenCV SDK must be downloaded manually via setup scripts. Not fetched automatically by Gradle due to size (~150MB) and licensing considerations.
  
- **Shader Complexity**: Current shaders are minimal (passthrough). Advanced effects require shader customization.

## CI/CD

This project includes a GitHub Actions workflow (`.github/workflows/android-build.yml`) that:
- Builds the debug APK on every push/PR
- Runs lint checks
- Uploads build artifacts
- Uses NDK 26.1.10909125 and CMake 3.22.1

To enable CI for your fork:
1. Push to GitHub
2. Go to Actions tab
3. Enable workflows if disabled
4. Update badge URL in README.md with your repository path

## Contributing

Contributions are welcome! Areas for improvement:

1. **Real-time Processing Pipeline**: Implement frame-by-frame OpenCV processing with GL texture updates
2. **Additional Filters**: Add more OpenCV processing options (blur, thresholding, feature detection)
3. **Performance Optimization**: Optimize JNI calls and memory management
4. **UI Enhancements**: Add filter selection, parameter controls, FPS display
5. **Testing**: Add unit tests for native code and instrumented tests for Android components
6. **Documentation**: Expand inline documentation and add video tutorials

### Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

For detailed troubleshooting, see [BUILD_NOTES.md](BUILD_NOTES.md).

**Quick fixes:**

- **Gradle wrapper missing**: `bash scripts/bootstrap_gradle_wrapper.sh`
- **OpenCV not found**: Check `local.properties` contains valid `opencv.dir` path
- **CMake errors**: Install NDK r26+ via Android Studio SDK Manager
- **JNI linking errors**: Run `scripts/setup_opencv_android.*` to copy `.so` files
- **Permission denied**: Enable USB debugging on device and authorize computer

## Screenshots

_To be added: Android app screenshot showing camera preview with toggle button, and web viewer screenshot._

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [OpenCV](https://opencv.org/) - Computer vision library
- Android Camera2 API documentation
- OpenGL ES 2.0 specification

---

**Need help?** Check [WARP.md](WARP.md) for AI assistant guidance or open an issue.
