#!/bin/bash

PROJECT_DIR="$(pwd)"

DIR="${PROJECT_DIR}/Build"
DIR_DEVICE="${DIR}/Release-iphoneos"
DIR_SIM="${DIR}/Debug-iphonesimulator"
DIR_OUT="${DIR}/RestKit"

cd $DIR_DEVICE

for LIB_FILENAME in *.a; do

	#echo "-output ${DIR_OUT}/${LIB_FILENAME} -create ${DIR_DEVICE}/${LIB_FILENAME} -arch i386 ${DIR_SIM}/${LIB_FILENAME}"
	
	lipo -output ${DIR_OUT}/${LIB_FILENAME} -create ${DIR_DEVICE}/${LIB_FILENAME} -arch i386 ${DIR_SIM}/${LIB_FILENAME}

done