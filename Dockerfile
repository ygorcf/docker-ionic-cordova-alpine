FROM node:lts-alpine4.14

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk/
ENV ANDROID_SDK_ROOT=/opt/android-sdk-linux/
ENV ANDROID_HOME=${ANDROID_SDK_ROOT}
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV GRADLE_PATH=/opt/gradle
ENV GRADLE_VERSION=7.2
ENV PATH=$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/extras/google/instantapps:${NPM_CONFIG_PREFIX}/bin/:${GRADLE_PATH}/gradle-${GRADLE_VERSION}/bin/

RUN apk update && \
    apk upgrade && \
    apk add --no-cache openjdk11 curl unzip python3 make g++ vips-dev android-tools && \
    mkdir -p ${ANDROID_HOME} && \
    curl -SLo /tmp/sdk-tools-linux.zip https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip && \
    unzip /tmp/sdk-tools-linux.zip -d ${ANDROID_HOME} && \
    rm -v /tmp/sdk-tools-linux.zip && \
    mkdir -p ~/.android/ && touch ~/.android/repositories.cfg && \
    yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses && \
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install "tools" "platform-tools" "platforms;android-30" "build-tools;30.0.3" && \
    curl -SLo /tmp/gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    mkdir -p ${GRADLE_PATH} && \
    unzip -d ${GRADLE_PATH}/ /tmp/gradle.zip && \
    rm -v /tmp/gradle.zip

COPY --chown=node:node . /code/
WORKDIR /code
USER node
RUN npm install -g @ionic/cli cordova cordova-res && \
    npm install && \
    ionic cordova platform add android@10.0.1
    # platforms/android/gradlew wrapper --gradle-version=7.2 --distribution-type=bin
