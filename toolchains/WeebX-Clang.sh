#!/bin/bash

maindir="$(pwd)"
outside="${maindir}/.."

dir="${outside}/WeebXClang"

case $1 in
  "setup" )
    # Clone compiler
    if [[ ! -d "${dir}" ]]; then
      mkdir ${dir} && cd ${dir}
	  curl -Lo a.tar.gz "https://github.com/XSans0/WeebX-Clang/releases/download/WeebX-Clang-20.0.0git-release/WeebX-Clang-20.0.0git.tar.gz"
	  tar -zxf a.tar.gz
    fi
  ;;

  "build" )
    export PATH="${dir}/bin:/usr/bin:${PATH}"
    make -j$(nproc --all) O=out ARCH=arm64 SUBARCH=arm64 $2
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
