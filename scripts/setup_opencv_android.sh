#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SDK_DIR="${ROOT_DIR}/third_party/OpenCV-android-sdk"
AAR_OUT_DIR="${ROOT_DIR}/app/libs"
JNILIBS_DIR="${ROOT_DIR}/app/src/main/jniLibs"
OPENCV_VERSION="4.10.0"
ZIP_NAME="opencv-${OPENCV_VERSION}-android-sdk.zip"
URL="https://github.com/opencv/opencv/releases/download/${OPENCV_VERSION}/${ZIP_NAME}"
TMP_DIR="${ROOT_DIR}/.opencv-download"

mkdir -p "${TMP_DIR}" "${AAR_OUT_DIR}" "${JNILIBS_DIR}"

if [ ! -d "${SDK_DIR}" ]; then
  echo "Downloading OpenCV Android SDK ${OPENCV_VERSION} ..."
  cd "${TMP_DIR}"
  curl -fL -o "${ZIP_NAME}" "${URL}"
  unzip -q -o "${ZIP_NAME}"
  mv opencv-*-android-sdk "${SDK_DIR}"
fi

echo "Copying OpenCV AAR to app/libs ..."
AAR_SRC="${SDK_DIR}/sdk/java"
AAR_FILE=$(ls -1 "${AAR_SRC}"/*.aar | head -n1)
cp -f "${AAR_FILE}" "${AAR_OUT_DIR}/opencv.aar"

echo "Copying JNI libs to jniLibs ..."
for ABI in arm64-v8a armeabi-v7a x86_64; do
  mkdir -p "${JNILIBS_DIR}/${ABI}"
  cp -rf "${SDK_DIR}/sdk/native/libs/${ABI}/"*.so "${JNILIBS_DIR}/${ABI}/" || true
  cp -rf "${SDK_DIR}/sdk/native/3rdparty/libs/${ABI}/"*.so "${JNILIBS_DIR}/${ABI}/" || true
done

# Write opencv.dir to local.properties
LOCAL_PROPS="${ROOT_DIR}/local.properties"
if ! grep -q '^opencv.dir=' "${LOCAL_PROPS}" 2>/dev/null; then
  echo "opencv.dir=${SDK_DIR//\\/\/}" >> "${LOCAL_PROPS}"
else
  sed -i.bak -E "s|^opencv.dir=.*$|opencv.dir=${SDK_DIR//\\/\/}|" "${LOCAL_PROPS}"
fi

echo "OpenCV SDK setup complete."
