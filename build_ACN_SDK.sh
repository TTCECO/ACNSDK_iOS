#!/bin/sh

PRODUCT_NAME="ACNSDK"

# UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

rm -rf "./ACNFramework/${PRODUCT_NAME}.framework"
rm -rf "./ACNFramework/${PRODUCT_NAME}.bundle"

# mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

echo "编译环境：${CONFIGURATION}"

#build devices and simulator architectures
echo "编译真机"

xcodebuild \
-workspace ACN_SDK_iOS_Demo.xcworkspace \
-scheme ACNSDK \
-configuration "${CONFIGURATION}" \
-sdk iphoneos \
ONLY_ACTIVE_ARCH=NO \
BUILD_DIR="${BUILD_DIR}" \
BUILD_ROOT="${BUILD_ROOT}" \
clean build

# echo "编译模拟器"
# xcodebuild \
# -workspace ACN_SDK_iOS_Demo.xcworkspace \
# -scheme ACNSDK \
# -configuration "${CONFIGURATION}" \
# -sdk iphonesimulator \
# -UseModernBuildSystem=NO \
# ONLY_ACTIVE_ARCH=NO \
# BUILD_DIR="${BUILD_DIR}" \
# BUILD_ROOT="${BUILD_ROOT}" \
# clean build

if [ $? -ne 0 ]; then
    echo "xcodebuild failed"
    exit 1
fi

#拷备framework
# cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PRODUCT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}"
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PRODUCT_NAME}.framework" "${PROJECT_DIR}"

# SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PRODUCT_NAME}.framework/Modules/${PRODUCT_NAME}.swiftmodule/."
# if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
# cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework/Modules/${PRODUCT_NAME}.swiftmodule"
# fi

# echo "合并真机与模拟器"

# 合成真机和模拟器
# lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"

# 复制到目录下
# cp -R "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework" "./ACNFramework/${PRODUCT_NAME}.framework"
# cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/ACNSDKBundle.bundle" "./ACNFramework/${PRODUCT_NAME}.bundle"

# 打开文件夹
open "${PROJECT_DIR}"
