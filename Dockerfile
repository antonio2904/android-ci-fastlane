#!/bin/bash
FROM ubuntu:20.04
MAINTAINER Antony <antonyleons29@gmail.com>

ENV ANDROID_SDK_URL https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip
ENV ANDROID_API_LEVEL android-30
ENV ANDROID_BUILD_TOOLS_VERSION 33.0.1
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/bin

COPY Gemfile .
COPY Gemfile.lock .
COPY fastlane ./fastlane

RUN apt-get update && \
apt-get install -qqy --no-install-recommends openjdk-17-jdk-headless curl unzip locales \
    build-essential git ruby-full && \
locale-gen en_US.UTF-8 && \
# Configure Bundler
gem install bundler -v 2.4.3 && \
bundle install && \
#Install gitlab release-cli
curl --location --output /usr/local/bin/release-cli "https://gitlab.com/api/v4/projects/gitlab-org%2Frelease-cli/packages/generic/release-cli/latest/release-cli-linux-amd64" && \
chmod +x /usr/local/bin/release-cli && \
# Clean up
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
apt-get autoremove -y && \
apt-get clean

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN mkdir "$ANDROID_HOME" .android && \
    cd "$ANDROID_HOME" && \
    curl -o sdk.zip $ANDROID_SDK_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
# Download Android SDK
yes | sdkmanager --licenses --sdk_root=$ANDROID_HOME && \
sdkmanager --update --sdk_root=$ANDROID_HOME && \
sdkmanager --sdk_root=$ANDROID_HOME "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
#    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools" \
    "extras;android;m2repository" \
    "extras;google;m2repository"