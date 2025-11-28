#!/bin/bash
set -e

echo "🟦 Web to APK Action Start"
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

echo "🔨 Building APK (assembleRelease)..."
./gradlew assembleRelease

echo "🔍 Searching for generated .apk file..."
# 查找所有 apk 文件（release 或 debug），优先 release
APK_FILE=$(find app/build/outputs/apk -type f -name "*.apk" | grep -E "(release|debug)" | head -n 1 || true)

if [ -z "$APK_FILE" ]; then
  echo "❗ No APK file found under app/build/outputs/apk — build might produced .aab or failed silently"
  exit 1
fi

echo "🎉 Found APK: $APK_FILE"
cp "$APK_FILE" /github/workspace/app-release.apk
echo "✅ Done. Output: app-release.apk"
