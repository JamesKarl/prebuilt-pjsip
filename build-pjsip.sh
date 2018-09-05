#!/bin/bash
CURRENT_DIR=`pwd`

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

function make_target(){
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
