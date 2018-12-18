#!/bin/sh

PRODUCT_NAME="TTCSDK"

UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

rm -rf "./TTCFramework/${PRODUCT_NAME}.framework"
rm -rf "./TTCFramework/${PRODUCT_NAME}.bundle"

mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

echo "编译环境：${CONFIGURATION}"

#build devices and simulator architectures
echo "编译真机"
xcodebuild \
-workspace TTC_SDK_iOS_Demo.xcworkspace \
-scheme TTCSDK \
-configuration "${CONFIGURATION}" \
-sdk iphoneos \
-UseModernBuildSystem=NO \
ONLY_ACTIVE_ARCH=NO \
BUILD_DIR="${BUILD_DIR}" \
BUILD_ROOT="${BUILD_ROOT}" \
clean build

echo "编译模拟器"
xcodebuild \
-workspace TTC_SDK_iOS_Demo.xcworkspace \
-scheme TTCSDK \
-configuration "${CONFIGURATION}" \
-sdk iphonesimulator \
-UseModernBuildSystem=NO \
ONLY_ACTIVE_ARCH=NO \
BUILD_DIR="${BUILD_DIR}" \
BUILD_ROOT="${BUILD_ROOT}" \
clean build

#拷备framework
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PRODUCT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}"

SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PRODUCT_NAME}.framework/Modules/${PRODUCT_NAME}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework/Modules/${PRODUCT_NAME}.swiftmodule"
fi

echo "合并真机与模拟器"

# 合成真机和模拟器
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"

# 复制到目录下
cp -R "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework" "./TTCFramework/${PRODUCT_NAME}.framework"
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/TTCSDKBundle.bundle" "./TTCFramework/${PRODUCT_NAME}.bundle"

# 打开文件夹
open "${PROJECT_DIR}"
