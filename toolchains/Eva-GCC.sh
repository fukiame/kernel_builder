#!/bin/bash

maindir="$(pwd)"
outside="${maindir}/.."

GCC64="${outside}/gcc-arm64"
GCC32="${outside}/gcc-arm"

case $1 in
  "setup" )
    if [[ ! -d "${GCC64}" ]]; then
      curl -LO $(curl -s https://api.github.com/repos/mvaisakh/gcc-build/releases/latest | grep browser_download_url | cut -d'"' -f4 | grep 'gcc-arm64-') gcc-arm64.tar.xz
      tar -xf gcc-arm64.tar.xz
      chmod +x "${GCC64}"/bin/*
    fi
    if [[ ! -d "${GCC32}" ]]; then
      curl -LO $(curl -s https://api.github.com/repos/mvaisakh/gcc-build/releases/latest | grep browser_download_url | cut -d'"' -f4 | grep 'gcc-arm-') gcc-arm.tar.xz
      tar -xf gcc-arm.tar.xz
      chmod +x "${GCC32}"/bin/*
    fi
  ;;

  "build" )
    export PATH="${GCC64}/bin:${GCC32}/bin:/usr/bin:${PATH}"
    make -j$(nproc --all) O=out ARCH=arm64 SUBARCH=arm64 $2
    make -j$(nproc --all) O=out \
      CROSS_COMPILE=aarch64-elf- \
      CROSS_COMPILE_COMPAT=arm-eabi- \
      LD="${GCC64}"/bin/aarch64-elf-ld.lld \
      AR=aarch64-elf-ar \
      AS=aarch64-elf-as \
      NM=aarch64-elf-nm \
      OBJDUMP=aarch64-elf-objdump \
      OBJCOPY=aarch64-elf-objcopy \
      CC=aarch64-elf-gcc \
      2>&1 | tee ${CUR_TOOLCHAIN}.log
    sh ${outside}/ver_toolchain.sh aarch64-elf-gcc aarch64-elf-ld.ldd > ${CUR_TOOLCHAIN}.info
  ;;
esac
