#!/bin/sh

# Create framework and bundle
PRODUCT_NAME="TTCSDK"

# Output directory
OUTPUT_DIR="./Products"

if [ -d "${OUTPUT_DIR}" ]; then
    rm -rf "${OUTPUT_DIR}/*"
else
    mkdir "${OUTPUT_DIR}"
fi

CUR_TIME=$(date "+%Y-%m-%d-%H-%M-%S")

# Target file
SDK=${OUTPUT_DIR}/${CUR_TIME}${PRODUCT_NAME}${CONFIGURATION}.framework

if [[ -d "${SDK}" ]]; then
    rm -rf "${SDK}"
fi

echo "configuration：${CONFIGURATION}"

# Build devices and simulator architectures
echo "iphone"
xcodebuild \
-workspace TTC_SDK_iOS_Demo.xcworkspace \
-scheme TTCSDK \
-configuration "${CONFIGURATION}" \
-sdk iphoneos \
BUILD_DIR="${BUILD_DIR}" \
BUILD_ROOT="${BUILD_ROOT}" \
clean build


echo "simulator"
xcodebuild \
-workspace TTC_SDK_iOS_Demo.xcworkspace \
-scheme TTCSDK \
-configuration "${CONFIGURATION}" \
-sdk iphonesimulator \
BUILD_DIR="${BUILD_DIR}" \
BUILD_ROOT="${BUILD_ROOT}" \
clean build

# Copy framework
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PRODUCT_NAME}.framework" "${SDK}"

# Merge iphone and simulator
echo "merge iphone and simulator"
lipo -create "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" -output "${SDK}/${PRODUCT_NAME}"

# Copy bundle
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/TTCSDKBundle.bundle" "${OUTPUT_DIR}/${CUR_TIME}TTCSDKBundle.bundle"

open "${SDK}"
