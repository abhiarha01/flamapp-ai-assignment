# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

FlamApp AI is an Android application that integrates real-time camera processing using:
- Kotlin with Camera2 API for camera capture
- Native C++ image processing via JNI using OpenCV (grayscale + Canny edge detection)
- OpenGL ES 2.0 for real-time rendering
- TypeScript web viewer for processed frame visualization

**Key Requirements:**
- Android Studio (Giraffe or newer) with SDK 34
- NDK r26+
- Java 17+
- Node.js 18+ (for web viewer)
- OpenCV Android SDK (downloaded via setup script)

## Essential Commands

### Initial Setup (First Time Only)

**Bootstrap Gradle Wrapper:**
```powershell
# Windows
scripts/bootstrap_gradle_wrapper.ps1

# macOS/Linux
bash scripts/bootstrap_gradle_wrapper.sh
```

**Setup OpenCV Android SDK:**
```powershell
# Windows
scripts/setup_opencv_android.ps1

# macOS/Linux
bash scripts/setup_opencv_android.sh
```

This downloads OpenCV to `third_party/OpenCV-android-sdk`, copies the AAR to `app/libs/opencv.aar`, native `.so` files to `app/src/main/jniLibs/<abi>/`, and sets `opencv.dir` in `local.properties`.

### Android Build Commands

**Build debug APK:**
```bash
./gradlew assembleDebug
```

**Build release APK:**
```bash
./gradlew assembleRelease
```

**Install to connected device:**
```bash
./gradlew installDebug
```

**Clean build:**
```bash
./gradlew clean
```

**Build native C++ only (useful for iterating on JNI code):**
```bash
./gradlew :app:externalNativeBuildDebug
```

### Web Viewer Commands

**Navigate to web directory first:**
```bash
cd web
```

**Install dependencies:**
```bash
npm install
```

**Build TypeScript:**
```bash
npm run build
```

**Run development server:**
```bash
npm run dev
```
Opens at http://localhost:5173

**Pull processed sample from device:**
```powershell
# Windows (from project root)
scripts/pull_processed_sample.ps1

# macOS/Linux
bash scripts/pull_processed_sample.sh
```

This pulls the processed image from the device's external files directory to `web/assets/processed_sample.png`.

## Architecture

### High-Level Data Flow

```
[Camera2 API] → [SurfaceTexture] → [OpenGL ES Renderer]
      ↓                                      ↑
[Image Bytes (demo)] → [JNI] → [C++ OpenCV Processing] → [PNG save]
```

### Component Architecture

**1. Kotlin Layer (`app/src/main/java/com/flamapp/ai/`)**
- **MainActivity**: Entry point, handles camera permissions, manages GLFrameView, saves demo processed frame
- **gl/GLFrameView**: Custom GLSurfaceView that wraps Camera2 capture and GL rendering
- **gl/GLRenderer**: OpenGL ES 2.0 renderer (currently basic, shader integration deferred)
- **nativebridge/NativeProcessor**: JNI bridge to native C++ processing (`loadLibrary("native-processor")`)

**2. Native Layer (`app/src/main/cpp/`)**
- **processor.h/cpp**: Core OpenCV processing functions
  - `process_rgba()`: Converts RGBA → grayscale → Canny edges → RGBA output
  - `save_png()`: Saves processed frames as PNG files
- **processor_jni.cpp**: JNI bindings exposing `processRgba()` to Kotlin
- **CMakeLists.txt**: CMake configuration linking OpenCV, requires `-DOpenCV_DIR` passed from Gradle

**3. OpenGL ES Integration**
- Shaders located in `app/src/main/assets/shaders/` (simple.vert, simple.frag)
- Real-time processed rendering path is a placeholder—full integration of ImageReader → JNI → GL texture is deferred

**4. Web Viewer (`web/`)**
- TypeScript-based viewer displaying processed frames with overlay (FPS, resolution)
- Uses `http-server` for local development
- Processed images expected at `web/assets/processed_sample.png`

### Build System Integration

**Gradle → CMake → OpenCV:**
- `app/build.gradle.kts` reads `opencv.dir` from `local.properties`
- Passes `-DOpenCV_DIR=${opencv.dir}/sdk/native/jni` to CMake
- CMake's `find_package(OpenCV REQUIRED)` locates OpenCV config
- Native library `libnative-processor.so` built for arm64-v8a, armeabi-v7a, x86_64

**Key Build Files:**
- `build.gradle.kts` (root): Android Gradle Plugin 8.5.0, Kotlin 1.9.24
- `app/build.gradle.kts`: App config, NDK ABI filters, CMake externalNativeBuild
- `local.properties`: Must contain `opencv.dir=<path>` (set by setup script)

## Development Workflows

### Modifying C++ Processing Logic

1. Edit files in `app/src/main/cpp/`
2. Rebuild native code: `./gradlew :app:externalNativeBuildDebug`
3. Install updated APK: `./gradlew installDebug`

### Adding New Native Functions

1. Declare in `processor.h`
2. Implement in `processor.cpp`
3. Add JNI binding in `processor_jni.cpp`
4. Expose in `NativeProcessor.kt` as `external fun`
5. Rebuild and test

### Updating OpenGL Shaders

1. Edit shader files in `app/src/main/assets/shaders/`
2. Shaders are loaded at runtime—no recompilation needed for shader changes
3. Reinstall APK: `./gradlew installDebug`

### Testing Processed Output

1. Run app on device (saves demo frame automatically on first launch)
2. Pull image: `scripts/pull_processed_sample.ps1` (or .sh)
3. View in web browser: `cd web && npm run dev`

## Troubleshooting

**Gradle wrapper missing:**
- Run `scripts/bootstrap_gradle_wrapper.ps1` (or .sh)

**OpenCV not found (CMake error):**
- Verify `local.properties` contains `opencv.dir=<absolute-path-to-OpenCV-android-sdk>`
- Re-run `scripts/setup_opencv_android.ps1` (or .sh)
- Ensure path has no spaces (Windows limitation)

**Linking errors with OpenCV:**
- Confirm `.so` files exist in `app/src/main/jniLibs/<abi>/libopencv_*.so`
- Clean build: `./gradlew clean`
- Re-run setup script

**NDK/CMake version issues:**
- Install NDK r26+ via Android Studio SDK Manager
- CMake version 3.22.1 specified in `app/build.gradle.kts`

**ADB not finding device:**
- Ensure USB debugging enabled on device
- Check device authorization: `adb devices`
- For `pull_processed_sample` scripts, device must be connected and authorized

## Important Project Constraints

- **ABI Support**: Project targets arm64-v8a, armeabi-v7a, x86_64 (configured in `app/build.gradle.kts` ndk.abiFilters)
- **Java Version**: Requires Java 17+
- **OpenCV Integration**: OpenCV must be manually downloaded via setup scripts; not fetched automatically by Gradle
- **local.properties**: Git-ignored file containing `opencv.dir`—must be set up per development machine
- **Real-time Processing**: Current implementation saves demo frames; full real-time GL texture update from processed frames is deferred

## Code Patterns

**JNI Bridge Pattern:**
```kotlin
// Kotlin side
object NativeProcessor {
    init { System.loadLibrary("native-processor") }
    external fun processRgba(inputRgba: ByteArray, width: Int, height: Int, savePath: String? = null): ByteArray
}

// C++ side (processor_jni.cpp)
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_flamapp_ai_nativebridge_NativeProcessor_processRgba(...)
```

**OpenCV Processing Pattern:**
```cpp
// processor.cpp
std::vector<uint8_t> process_rgba(const uint8_t* rgba, int width, int height) {
    cv::Mat src_rgba(height, width, CV_8UC4, const_cast<uint8_t*>(rgba));
    cv::Mat gray, edges;
    cv::cvtColor(src_rgba, gray, cv::COLOR_RGBA2GRAY);
    cv::Canny(gray, edges, 100, 200);
    // Convert back to RGBA for display
    // ...
    return output_vector;
}
```

**Camera2 → SurfaceTexture → GL:**
- Camera2 outputs to SurfaceTexture
- SurfaceTexture backed by OpenGL texture ID
- GLRenderer updates texture via `updateTexImage()` on each frame
