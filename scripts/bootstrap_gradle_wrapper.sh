#!/usr/bin/env bash
set -euo pipefail

# Bootstrap Gradle wrapper jar by downloading Gradle distribution and extracting the wrapper jar
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
DIST_VERSION="8.7"
DIST_ZIP="gradle-${DIST_VERSION}-bin.zip"
DIST_URL="https://services.gradle.org/distributions/${DIST_ZIP}"
TMP_DIR="${ROOT_DIR}/.gradle-bootstrap"

mkdir -p "${ROOT_DIR}/gradle/wrapper" "${TMP_DIR}"

if [ -f "${WRAPPER_JAR}" ]; then
  echo "Gradle wrapper already present: ${WRAPPER_JAR}"
  exit 0
fi

echo "Downloading ${DIST_URL} ..."
cd "${TMP_DIR}"
curl -fL -o "${DIST_ZIP}" "${DIST_URL}"

unzip -q -o "${DIST_ZIP}"

CAND1="gradle-${DIST_VERSION}/lib/plugins/gradle-wrapper-${DIST_VERSION}.jar"
CAND2="gradle-${DIST_VERSION}/lib/gradle-wrapper-${DIST_VERSION}.jar"

if [ -f "${CAND1}" ]; then
  cp "${CAND1}" "${WRAPPER_JAR}"
elif [ -f "${CAND2}" ]; then
  cp "${CAND2}" "${WRAPPER_JAR}"
else
  echo "Could not locate gradle-wrapper-${DIST_VERSION}.jar in distribution" >&2
  exit 1
fi

echo "Bootstrapped ${WRAPPER_JAR}"
