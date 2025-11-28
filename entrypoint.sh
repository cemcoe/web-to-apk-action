#!/bin/bash
set -e

echo "🟦 Web to APK Action (Java 21 + SDK 36) Start"
echo "Java version:"
java -version

APP_NAME="${INPUT_APP_NAME}"
APP_ID="${INPUT_APP_ID}"
BUILD_COMMAND="${INPUT_BUILD_COMMAND}"
WEB_DIR="${INPUT_WEB_DIR:-dist}"

echo "⚙️ Running user build command..."
sh -c "$BUILD_COMMAND"

echo "📁 Creating Capacitor wrapper..."
npm init -y
npm install @capacitor/core @capacitor/android

npx cap init "$APP_NAME" "$APP_ID" --web-dir="$WEB_DIR"

echo "📱 Adding Android platform..."
npx cap add android

echo "🔗 Syncing Web assets..."
npx cap sync

cd android

echo "🛠️ Updating compileSdkVersion / targetSdkVersion to 36"
# variables.gradle 中如果有 sdk version 定义，可 patch
if grep -q "compileSdkVersion" variables.gradle; then
  sed -i "s/compileSdkVersion = [0-9]\\+/compileSdkVersion = 36/" variables.gradle
fi
if grep -q "targetSdkVersion" variables.gradle; then
  sed -i "s/targetSdkVersion = [0-9]\\+/targetSdkVersion = 36/" variables.gradle
fi

echo "🔨 Building APK with Gradle + Java 21 + SDK 36..."
./gradlew assembleRelease

APK_PATH="app/build/outputs/apk/release/app-release.apk"

echo "🔍 Searching for generated .apk file..."
# 查找所有 apk 文件（release 或 debug），优先 release
cd ./app/build
pwd
ls ./
APK_FILE=$(find app/build/outputs/apk -type f -name "*.apk" | grep -E "(release|debug)" | head -n 1 || true)

if [ -z "$APK_FILE" ]; then
  echo "❗ No APK file found under app/build/outputs/apk — build might produced .aab or failed silently"
  exit 1
fi

echo "🎉 Found APK: $APK_FILE"
cp "$APK_FILE" /github/workspace/app-release.apk
echo "✅ Done. Output: app-release.apk"

