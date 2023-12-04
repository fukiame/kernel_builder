#!/bin/bash

maindir="$(pwd)"
outside="${maindir}/.."

gcc64="${outside}/los_gcc49_64"
gcc="${outside}/los_gcc49"

case $1 in
  "setup" )
    if [ ! -d $gcc64 ]; then
    git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 $gcc64
    fi
    if [ ! -d $gcc ]; then
    git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 $gcc
    fi
  ;;

  "build" )
    export PATH="$gcc64/bin:$gcc/bin:/usr/bin:${PATH}"
    make -j$(nproc --all) O=out ARCH=arm64 SUBARCH=arm64 $2
    make -j$(nproc --all) O=out \
      CROSS_COMPILE="aarch64-linux-android-" \
      CROSS_COMPILE_ARM32="arm-linux-androideabi-" \
      CONFIG_NO_ERROR_ON_MISMATCH=y \
      CONFIG_DEBUG_SECTION_MISMATCH=y \
      2>&1 | tee ${CUR_TOOLCHAIN}.log
    sh ${outside}/ver_toolchain.sh aarch64-linux-android-gcc aarch64-linux-android-ld > ${CUR_TOOLCHAIN}.info
  ;;
esac
