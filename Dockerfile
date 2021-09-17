FROM adoptopenjdk:11.0.11_9-jdk-hotspot-focal

ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
# Preserved for backwards compatibility
ENV ANDROID_HOME /opt/android-sdk-linux

# ------------------------------------------------------
# --- Install required tools
# Base (non android specific) tools
# Dependencies to execute Android builds
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    unzip \
    git \
    curl \
    wget \
    rsync \
    sudo \
    expect \
    # Common, useful
    build-essential \
    zip \
    unzip \
    tree \
    clang \
    imagemagick \
    groff \
    jq \
    awscli

# ------------------------------------------------------
# --- Download Android Command line Tools into $ANDROID_SDK_ROOT

RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O android-commandline-tools.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -q android-commandline-tools.zip -d /tmp/ \
    && mv /tmp/cmdline-tools/ ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm android-commandline-tools.zip && ls -la ${ANDROID_SDK_ROOT}/cmdline-tools/latest/

ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  sdkmanager --list

# Accept licenses before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN yes | sdkmanager --licenses

RUN touch /root/.android/repositories.cfg

# Emulator and Platform tools
RUN yes | sdkmanager "platform-tools"

# SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.

RUN yes | sdkmanager --update --channel=3
# Please keep all sections in descending order!
RUN yes | sdkmanager \
    "platforms;android-31" \
    "platforms;android-30" \
    "platforms;android-29" \
    "platforms;android-28" \
    "platforms;android-27" \
    "platforms;android-26" \
    "build-tools;31.0.0" \
    "build-tools;30.0.3" \
    "build-tools;29.0.3" \
    "build-tools;28.0.3" \
    "build-tools;27.0.3" \
    "build-tools;26.0.2"

ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION r21e

# ------------------------------------------------------
# --- Android NDK

# download
RUN mkdir /opt/android-ndk-tmp && \
    cd /opt/android-ndk-tmp && \
    wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# uncompress
    unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# move to its final location
    mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
# remove temp dir
    cd ${ANDROID_NDK_HOME} && \
    rm -rf /opt/android-ndk-tmp

# add to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}

# ------------------------------------------------------
# --- Cleanup and rev num

# Cleaning
RUN apt-get clean
