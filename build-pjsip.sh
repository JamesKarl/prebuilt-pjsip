#!/bin/bash
CURRENT_DIR=`pwd`

NDKLEVEL=21

ROOT=/home/jameskarl/sip/pjsip

PJSIP_ROOT=$ROOT/pjproject-2.7.2
OPEN_H264=$ROOT/openh264
LIBYUV=$ROOT/libyuv-android/
DEST_ROOT=$ROOT/output

################################################################
APP_SWIG_ROOT=$PJSIP_ROOT/pjsip-apps/src/swig
APP_SWIG_OUTPUT=$APP_SWIG_ROOT/java/output
APP_SWIG_ANDROID_SRC=$APP_SWIG_ROOT/java/android/app/src/main/java
APP_SWIG_ANDROID_SO=$APP_SWIG_ROOT/java/android/app/src/main/jniLibs

DEST_JAR_LIBS=$DEST_ROOT/libs
DEST_SO_LIBS=$DEST_ROOT/src/main/jniLibs

DEST_LIBYUV=$DEST_ROOT/libyuv/jni/out/Release
DEST_LIBYUV_JNI_LIBS=$DEST_ROOT/libyuv/jniLibs

SO_NAME=libpjsua2.so
JAR_NAME=pjsip.jar
JAR_SRC_NAME=pjsip-src.jar

## https://github.com/cisco/openh264
##supported target: armeabi, armeabi-v7a, arm64-v8a, x86, x86_64, mips, mips64, 
function make_open_h264() {
	cd $OPEN_H264
	local target=$1


	local architecture=arm #default armeabi-v7a

	if [ "$target" = "armeabi-v7a" ] ; then
		architecture=arm
	elif [ "$target" = "arm64-v8a" ] ; then
		architecture=arm64
	else
		architecture=$target
	fi

	#ARCH: Currently arm, arm64, x86 and x86_64 are supported, the default is arm. 
	#	   mips and mips64 can also be used, but there's no specific optimization for those architectures.)

	# By default these commands build for the armeabi-v7a ABI. 
	# To build for the other android ABIs, add ARCH=arm64, ARCH=x86, ARCH=x86_64, ARCH=mips or ARCH=mips64. 
	# To build for the older armeabi ABI (which has armv5te as baseline), add APP_ABI=armeabi (ARCH=arm is implicit). 
	# To build for 64-bit ABI, such as arm64, explicitly set NDKLEVEL to 21 or higher.
	# NDKLEVEL specifies android api level, the default is 12

	echo make OS=android NDKROOT=$ANDROID_NDK_ROOT TARGET=android-28 NDKLEVEL=$NDKLEVEL ARCH=$architecture
	make OS=android NDKROOT=$ANDROID_NDK_ROOT TARGET=android-28 NDKLEVEL=$NDKLEVEL ARCH=$architecture

	echo cp $OPEN_H264/libopenh264.so  $DEST_SO_LIBS/$target
	mkdir -p $DEST_SO_LIBS/$target
	cp $OPEN_H264/libopenh264.so  $DEST_SO_LIBS/$target
}

# will build all targets.
#target support: armeabi, armeabi-v7a, arm64-v8a, x86, x86_64
function make_libyuv() {
	cd $LIBYUV
	ndk-build

	mkdir -p $DEST_LIBYUV
	mkdir -p $DEST_LIBYUV_JNI_LIBS

	echo cp -r $LIBYUV/libs/* $DEST_LIBYUV_JNI_LIBS
	cp -r $LIBYUV/libs/* $DEST_LIBYUV_JNI_LIBS
}

#target support: armeabi, armeabi-v7a, arm64-v8a, x86, x86_64
function prepare_libyuv() {
	local target=$1

	echo cp $DEST_LIBYUV_JNI_LIBS/$target/libyuv.so $DEST_LIBYUV
	mkdir -p $DEST_LIBYUV
	cp $DEST_LIBYUV_JNI_LIBS/$target/libyuv.so $DEST_LIBYUV

	mkdir -p $DEST_SO_LIBS/$target
	cp $DEST_LIBYUV_JNI_LIBS/$target/libyuv.so  $DEST_SO_LIBS/$target
}

#target support: armeabi, armeabi-v7a, arm64-v8a, x86, x86_64, mips, mips64
function make_target(){
	make_open_h264 $1
	prepare_libyuv $1

	cd $PJSIP_ROOT
	local target=$1
	TARGET_ABI=$target ./configure-android --use-ndk-cflags --with-openh264=$OPEN_H264 --with-libyuv=$DEST_ROOT/libyuv/jni
	make dep && make clean && make


	## build pjsua app
	cd $APP_SWIG_ROOT
	make


	## copy pjsip.jar	
	cd $APP_SWIG_OUTPUT
	jar cf $JAR_NAME org
	echo cp $APP_SWIG_OUTPUT/$JAR_NAME $DEST_JAR_LIBS
	mkdir -p $DEST_JAR_LIBS
	cp $APP_SWIG_OUTPUT/$JAR_NAME $DEST_JAR_LIBS

	## copy pjsip-src.jar
	cd $APP_SWIG_ANDROID_SRC
	jar cf $JAR_SRC_NAME org
	echo cp $APP_SWIG_OUTPUT/$JAR_SRC_NAME $DEST_JAR_LIBS
	mkdir -p $DEST_JAR_LIBS
	cp $APP_SWIG_OUTPUT/$JAR_SRC_NAME $DEST_JAR_LIBS

	## copy libpjsua2.so
	echo cp $APP_SWIG_ANDROID_SO/armeabi/$SO_NAME $DEST_SO_LIBS/$target
	mkdir -p $DEST_SO_LIBS/$target
	cp $APP_SWIG_ANDROID_SO/armeabi/$SO_NAME $DEST_SO_LIBS/$target
}

#make libyuv only once.
make_libyuv

##supported target: armeabi, armeabi-v7a, arm64-v8a, x86, x86_64 
make_target armeabi
make_target armeabi-v7a
make_target arm64-v8a
make_target x86
make_target x86_64

cd $CURRENT_DIR
echo '========THE END========'
