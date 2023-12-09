#!/bin/bash

maindir="$(pwd)"
outside="${maindir}/.."

GCC64="${outside}/gcc64"
GCC32="${outside}/gcc32"

case $1 in
  "setup" )
    if [[ ! -d "${GCC64}" ]]; then
      git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 "${GCC64}"
      chmod +x "${GCC64}"/bin/*
    fi
    if [[ ! -d "${GCC32}" ]]; then
      git clone --depth=1 https://github.com/mvaisakh/gcc-arm "${GCC32}"
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
    sh ${outside}/ver_toolchain.sh gcc ld > ${CUR_TOOLCHAIN}.info
  ;;
esac
