#!/bin/bash

maindir="$(pwd)"
outside="${maindir}/.."

dir="${outside}/proton-clang-master"

case $1 in
  "setup" )
    # Clone compiler
    if [[ ! -d "${dir}" ]]; then
	  curl -Lo a.tar.gz "https://github.com/kdrag0n/proton-clang/archive/master.tar.gz"
	  tar -zxf a.tar.gz
    fi
  ;;

  "build" )
    export PATH="${dir}/bin:/usr/bin:${PATH}"
    export bin64="aarch64-linux-gnu"
    export bin32="arm-linux-gnueabi"
    make -j$(nproc --all) O=out CC=clang LD=ld.lld ARCH=arm64 SUBARCH=arm64 $2
    make -j$(nproc --all) O=out \
      CROSS_COMPILE="$bin64-" \
      CROSS_COMPILE_ARM32="$bin32-" \
      CROSS_COMPILE_COMPAT="$bin32-" \
      CC=clang \
      LD="$bin64-ld" \
      LDGOLD="$bin64-ld.gold" \
      HOSTLD="$dir/bin/ld" \
      LDCOMPAT="$dir/bin/$bin32-ld" \
      2>&1 | tee ${CUR_TOOLCHAIN}.log
    sh ${outside}/ver_toolchain.sh clang ld > ${CUR_TOOLCHAIN}.info
  ;;
esac
