# BUILD NOTES

NDK/CMake and OpenCV tips

- Ensure NDK is installed (SDK Manager -> SDK Tools -> NDK). r26c+ recommended.
- If CMake cannot find OpenCV, verify local.properties contains:

  opencv.dir=C:/path/to/OpenCV-android-sdk

  Gradle passes -DOpenCV_DIR=${opencv.dir}/sdk/native/jni to CMake.

- If linking errors with OpenCV occur:
  - Re-run scripts/setup_opencv_android.(sh|ps1)
  - Clean builds: ./gradlew clean
  - Confirm .so files exist in app/src/main/jniLibs/<abi>

- If Gradle wrapper is missing:
  - Run scripts/bootstrap_gradle_wrapper.(sh|ps1)

- ABI support:
  - The project targets arm64-v8a, armeabi-v7a, x86_64. Adjust in app/build.gradle.kts if needed.

- Windows path issues:
  - Avoid spaces in the OpenCV SDK path where possible.

- Java/Gradle compatibility:
  - Use Java 17+. Android Gradle Plugin 8.5+.
