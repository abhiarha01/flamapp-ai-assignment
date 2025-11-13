# Release Notes

Version 1.0.0 (Initial)

Implemented:
- Android app scaffold (Kotlin) with Camera2 preview and GLSurfaceView
- JNI + C++ OpenCV processing (grayscale + Canny)
- CMake + NDK integration
- OpenGL ES 2.0 shader assets
- OpenCV Android SDK setup scripts (download + jniLibs + opencv.aar)
- Demo processed frame saved via JNI
- Web TypeScript viewer with overlay
- Gradle wrapper bootstrap scripts

Deferred / Notes:
- Real-time processed rendering path uses a placeholder renderer; wiring ImageReader -> JNI -> GL texture can be iterated further
- Add real screenshots
