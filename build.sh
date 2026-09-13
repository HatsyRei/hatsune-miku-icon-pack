#!/usr/bin/env bash
#
# Clean build helper for the Miku icon pack.
#
# Usage:
#   ./build.sh              # regenerate assets + clean + assemble release APK
#   ./build.sh debug        # regenerate assets + clean + assemble debug APK
#   ./build.sh install      # release build, then install to a connected device
set -euo pipefail

cd "$(dirname "$0")"

# --- Toolchain -------------------------------------------------------------
if [[ -z "${JAVA_HOME:-}" || ! -x "${JAVA_HOME:-}/bin/java" ]]; then
  if [[ -x "$HOME/.local/jdks/jdk-21/bin/java" ]]; then
    export JAVA_HOME="$HOME/.local/jdks/jdk-21"
  elif [[ -x /usr/lib/jvm/java-21-openjdk-amd64/bin/java ]]; then
    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
  fi
fi

if [[ -z "${ANDROID_HOME:-}" || ! -d "${ANDROID_HOME:-}" ]]; then
  if [[ -d "$HOME/android-sdk" ]]; then
    export ANDROID_HOME="$HOME/android-sdk"
  elif [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
  fi
fi
export ANDROID_SDK_ROOT="${ANDROID_HOME:-}"
export PATH="${JAVA_HOME:+$JAVA_HOME/bin:}${ANDROID_HOME:-}/platform-tools:$PATH"

echo "JAVA_HOME=${JAVA_HOME:-<unset>}"
echo "ANDROID_HOME=${ANDROID_HOME:-<unset (relying on local.properties)>}"

# --- Assets ----------------------------------------------------------------
# Drawables and drawable.xml are derived from miku-hyoromo/, so regenerate them
# before every build rather than trusting what is checked in.
echo "==> regenerating icon assets"
tools/upscale.sh
tools/gen_launcher_icon.sh
tools/gen_drawable_xml.py

# --- Build -----------------------------------------------------------------
TARGET="${1:-release}"
case "$TARGET" in
  debug)           GRADLE_TASK="clean :app:assembleDebug" ;;
  release|install) GRADLE_TASK="clean :app:assembleRelease" ;;
  *)
    echo "Unknown target '$TARGET' (expected: debug | release | install)" >&2
    exit 2
    ;;
esac

echo "==> ./gradlew $GRADLE_TASK --no-daemon"
# shellcheck disable=SC2086
./gradlew $GRADLE_TASK --no-daemon

if [[ "$TARGET" == "install" ]]; then
  APK="app/build/outputs/apk/release/app-release.apk"
  echo "==> adb install -r $APK"
  adb install -r "$APK"
fi

echo "Done."
