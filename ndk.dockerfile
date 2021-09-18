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
    git \
    curl \
    wget \
    sudo \
    # Common, useful
    zip \
    unzip \
    tree \
    jq \
    && apt-get clean
# ------------------------------------------------------
# --- Cleanup and rev num

# Cleaning
RUN apt-get clean
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

# Platform tools
RUN yes | sdkmanager "platform-tools"

# SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.

RUN yes | sdkmanager --update --channel=3
# Please keep all sections in descending order!
# 
# You have multiple versions of the NDK installed and you want to use a specific one. 
# In this case, specify the version using the android.ndkVersion property in 
# the module's build.gradle file, as shown in the following code sample.
# 
# android {
#     ndkVersion "major.minor.build" // e.g.,  ndkVersion "21.3.6528147"
# }

RUN yes | sdkmanager \
    "platforms;android-31" \
    "platforms;android-30" \
    "platforms;android-29" \
    "platforms;android-28" \
    "platforms;android-27" \
    "platforms;android-26" \
    "platforms;android-25" \
    "platforms;android-24" \
    "platforms;android-23" \
    "platforms;android-22" \
    "platforms;android-21" \
    "platforms;android-19" \
    "platforms;android-17" \
    "platforms;android-15" \
    "build-tools;31.0.0" \
    "build-tools;30.0.3" \
    "build-tools;30.0.2" \
    "build-tools;30.0.0" \
    "build-tools;29.0.3" \
    "build-tools;29.0.2" \
    "build-tools;29.0.1" \
    "build-tools;29.0.0" \
    "build-tools;28.0.3" \
    "build-tools;28.0.2" \
    "build-tools;28.0.1" \
    "build-tools;28.0.0" \
    "build-tools;27.0.3" \
    "build-tools;27.0.2" \
    "build-tools;27.0.1" \
    "build-tools;27.0.0" \
    "build-tools;26.0.2" \
    "build-tools;26.0.1" \
    "build-tools;25.0.3" \
    "build-tools;24.0.3" \
    "build-tools;23.0.3" \
    "build-tools;22.0.1" \
    "build-tools;21.1.2" \
    "build-tools;19.1.0" \
    "build-tools;17.0.0" \
    "cmake;3.10.2.4988404" \
    # default ndk version on AGP 7.0 & 4.2
    "ndk;21.4.7075529" \
    # default ndk version on AGP 4.1
    "ndk;21.1.6352462" \
    # default ndk version on AGP 4.0
    "ndk;21.0.6113669" \
    # default ndk version on AGP 4.6
    "ndk;20.0.5594570" \
    # other specified
    "ndk;16.1.4479499"
