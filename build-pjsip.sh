#!/bin/bash
CURRENT_DIR=`pwd`

NDKLEVEL=19

PJSIP_ROOT=/home/jameskarl/sip/pjsip/pjproject-2.7.2
OPEN_H264=/home/jameskarl/sip/pjsip/openh264
LIBYUV=/home/jameskarl/sip/pjsip/libyuv
DEST_ROOT=/home/jameskarl/sip/pjsip/output

################################################################
APP_SWIG_ROOT=$PJSIP_ROOT/pjsip-apps/src/swig
APP_SWIG_OUTPUT=$APP_SWIG_ROOT/java/output
APP_SWIG_ANDROID_SRC=$APP_SWIG_ROOT/java/android/app/src/main/java
APP_SWIG_ANDROID_SO=$APP_SWIG_ROOT/java/android/app/src/main/jniLibs

DEST_JAR_LIBS=$DEST_ROOT/libs
DEST_SO_LIBS=$DEST_ROOT/src/main/jniLibs

SO_NAME=libpjsua2.so
JAR_NAME=pjsip.jar
JAR_SRC_NAME=pjsip-src.jar

## https://github.com/cisco/openh264
function make_open_h264() {
	cd $OPEN_H264
	local target=$1

	architecture=arm
	if [ "$target" = "armeabi" ] ; then
		architecture=armeabi
	fi 

	#ARCK: Currently arm, arm64, x86 and x86_64 are supported, the default is arm. 
	#	   mips and mips64 can also be used, but there's no specific optimization for those architectures.)

	# By default these commands build for the armeabi-v7a ABI. 
	# To build for the other android ABIs, add ARCH=arm64, ARCH=x86, ARCH=x86_64, ARCH=mips or ARCH=mips64. 
	# To build for the older armeabi ABI (which has armv5te as baseline), add APP_ABI=armeabi (ARCH=arm is implicit). 
	# To build for 64-bit ABI, such as arm64, explicitly set NDKLEVEL to 21 or higher.
	# NDKLEVEL specifies android api level, the default is 12

	make OS=android NDKROOT=$ANDROID_NDK_ROOT TARGET=android-$NDKLEVEL NDKLEVEL=$NDKLEVEL 

	echo cp $OPEN_H264/libopenh264.so  $DEST_SO_LIBS/$target
	mkdir -p $DEST_SO_LIBS/$target
	cp $OPEN_H264/libopenh264.so  $DEST_SO_LIBS/$target
}

function make_libyuv() {
	cd $LIBYUV
	make -f linux.mk
}

function make_target(){
	make_open_h264 $1
	make_libyuv

	cd $PJSIP_ROOT
	local target=$1
	TARGET_ABI=$target ./configure-android --use-ndk-cflags --with-openh264=$OPEN_H264 --with-libyuv=$LIBYUV
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

#make_target armeabi
make_target armeabi-v7a

cd $CURRENT_DIR
echo '========THE END========'
