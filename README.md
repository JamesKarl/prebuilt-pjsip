# build pjsip

## 注意事项

1. NDK 版本非常重要，高版本版本不过。r10e是可以编译通过的。

2. Android SDK版本也有关系。高版本的SDK中tools/android工具与低版本不同，编译依赖低版本的工具。 24.4.1的SDK是可以编译通过的。

3. 如果需要视频支持，运行configure-android的时候要指定--with-openh264 和 --with-libyuv选项

## BUILD ENVVIRONMENT

1. Ubuntu 14.04 64bit

2. Android SDK version 24.4.1 (http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz)

3. NDK version r10e (https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip)

4. PjSip Verson 2.7.2

5. Install Swig

6. set environment varable ANDROID_NDK_ROOT

## Build Guide

1. official guide (https://trac.pjsip.org/repos/wiki/Getting-Started/Android)

## Build Steps

1. create config_site.h with the following content.

```c
/* Activate Android specific settings in the 'config_site_sample.h' */
#define PJ_CONFIG_ANDROID 1
#define PJMEDIA_HAS_VIDEO 1
#include <pj/config_site_sample.h>


2. download openh264 source code and build

3. download libyuv source code and build

4. run configure-android

```sh
TARGET_ABI=armeabi-v7a ./configure-android --use-ndk-cflags --with-openh264=/Users/me/openh264/android
