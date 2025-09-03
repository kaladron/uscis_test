#!/usr/bin/env bash
set -euo pipefail

echo "[postCreate] Starting setup..."

# Ensure Flutter is on PATH (feature installs to /usr/local/flutter)
if ! command -v flutter >/dev/null 2>&1; then
  export PATH="/usr/local/flutter/bin:$PATH"
fi

# Android SDK install (cmdline-tools + build tools) if not present
SDK_ROOT=${ANDROID_SDK_ROOT:-/home/vscode/android-sdk}
mkdir -p "$SDK_ROOT"

if ! command -v sdkmanager >/dev/null 2>&1; then
  echo "Installing Android commandline tools..."
  TMP_DIR=$(mktemp -d)
  curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o "$TMP_DIR/cmdtools.zip"
  unzip -q "$TMP_DIR/cmdtools.zip" -d "$TMP_DIR/cmdtools"
  mkdir -p "$SDK_ROOT/cmdline-tools/latest"
  # Some zip packages wrap cmdline-tools in a folder called 'cmdline-tools'; support both layouts
  if [[ -d "$TMP_DIR/cmdtools/cmdline-tools" ]]; then
    mv "$TMP_DIR/cmdtools/cmdline-tools"/* "$SDK_ROOT/cmdline-tools/latest/" || true
  else
    mv "$TMP_DIR/cmdtools"/* "$SDK_ROOT/cmdline-tools/latest/" || true
  fi
  rm -rf "$TMP_DIR"
  export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$PATH"
fi

export ANDROID_HOME="$SDK_ROOT"
export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$SDK_ROOT/platform-tools:$SDK_ROOT/emulator:$PATH"

yes | sdkmanager --licenses >/dev/null || true
sdkmanager \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "platforms;android-35" \
  "build-tools;35.0.0" \
  "ndk;25.1.8937393" \
  >/dev/null || true

echo "[postCreate] Done."
