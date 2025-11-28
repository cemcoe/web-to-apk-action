FROM ubuntu:22.04

# 基础工具
RUN apt-get update && apt-get install -y \
  curl wget unzip git nodejs npm openjdk-17-jdk \
  && rm -rf /var/lib/apt/lists/*

# Node 基础
RUN npm install -g @capacitor/cli

# Android SDK
ENV ANDROID_HOME=/usr/local/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0/

RUN mkdir -p $ANDROID_HOME && cd $ANDROID_HOME && \
  wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O tools.zip && \
  unzip tools.zip && rm tools.zip && \
  mkdir -p cmdline-tools/latest && \
  mv cmdline-tools/* cmdline-tools/latest/ || true

# 不交互安装 SDK
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
