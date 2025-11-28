#!/bin/bash
set -e

echo "🟦 Web to APK Action: Start"

APP_NAME="${INPUT_APP_NAME}"
APP_ID="${INPUT_APP_ID}"
BUILD_COMMAND="${INPUT_BUILD_COMMAND}"
WEB_DIR="${INPUT_WEB_DIR}"

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

echo "🔨 Building APK..."
cd android
./gradlew assembleRelease

APK_PATH="app/build/outputs/apk/release/app-release.apk"

echo "🎉 APK built: $APK_PATH"

cp $APK_PATH /github/workspace/app-release.apk

echo "✅ Done. Output: app-release.apk"
