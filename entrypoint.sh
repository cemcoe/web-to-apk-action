#!/bin/bash
set -e

echo "🟦 Web to APK Action: Start"
echo "Java version:" 
java -version

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

# **Patch Android project to force Java 17 compatibility**
echo "🛠️ Patching Android build.gradle for Java 17 compatibility..."
# 进入 android 目录
cd android
# backup original build.gradle
cp app/build.gradle app/build.gradle.bak || true

# 用 sed 修改 build.gradle compileOptions 中的 sourceCompatibility & targetCompatibility
# 注意：仅在存在 compileOptions 的情况下替换
sed -i "/compileOptions {/,/}/ { 
  s/sourceCompatibility .*/sourceCompatibility JavaVersion.VERSION_17/
  s/targetCompatibility .*/targetCompatibility JavaVersion.VERSION_17/
}" app/build.gradle

# 如果 kotlinOptions 存在，也设 jvmTarget = "17"
sed -i "/kotlinOptions {/,/}/ { 
  s/jvmTarget = .*/jvmTarget = \"17\"/
}" app/build.gradle || true

echo "🔨 Building APK..."
./gradlew assembleRelease

APK_PATH="app/build/outputs/apk/release/app-release.apk"

echo "🎉 APK built: $APK_PATH"
cp $APK_PATH /github/workspace/app-release.apk

echo "✅ Done. Output: app-release.apk"
