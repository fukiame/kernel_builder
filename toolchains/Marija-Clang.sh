#!/bin/bash

maindir="$(pwd)"
outside="${maindir}/.."

dir="${outside}/MarijaClang"

case $1 in
  "setup" )
    # Clone compiler
    if [[ ! -d "${dir}" ]]; then
      mkdir ${dir} && cd ${dir}
      curl -Lo a.tar.gz "$(curl -s https://api.github.com/repos/fukiame/Marija-Clang/releases/latest | grep browser_download_url | cut -d'"' -f4 | grep tar.gz)"
      tar -zxf a.tar.gz
    fi
  ;;

  "build" )
    export PATH="${dir}/bin:/usr/bin:${PATH}"
    make -j$(nproc --all) O=out CC=clang LD=ld.lld ARCH=arm64 SUBARCH=arm64 $2
    make -j$(nproc --all) O=out \
      CROSS_COMPILE="aarch64-linux-gnu-" \
      CROSS_COMPILE_ARM32="arm-linux-gnueabi-" \
      CROSS_COMPILE_COMPAT="arm-linux-gnueabi-" \
      CC=clang \
      LD=ld.lld \
      NM=llvm-nm \
      AR=llvm-ar \
      STRIP=llvm-strip \
      OBJCOPY=llvm-objcopy \
      OBJDUMP=llvm-objdump \
      READELF=llvm-readelf \
      LLVM_IAS=1 \
      HOSTCC=clang \
      HOSTCXX=clang++ \
      HOSTLD=ld.lld \
      HOSTAR=llvm-ar \
      2>&1 | tee ${CUR_TOOLCHAIN}.log
    sh ${outside}/ver_toolchain.sh clang ld.lld > ${CUR_TOOLCHAIN}.info
  ;;
esac
