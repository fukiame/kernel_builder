#!/bin/bash

maindir="$(pwd)"
outside="${maindir}/.."

dir="${outside}/NeutronClang"

case $1 in
  "setup" )
    # Clone compiler
    if [[ ! -d "${dir}" ]]; then
      mkdir ${dir} && cd ${dir}
      curl -LO "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman"
      if ! bash antman -S=latest &>/dev/null; then
        exit 1
      fi
    fi
  ;;

  "build" )
    export PATH="${dir}/bin:/usr/bin:${PATH}"
    export bin64="aarch64-linux-gnu"
    export bin32="arm-linux-gnueabi"
    make -j$(nproc --all) O=out CC=clang ARCH=arm64 SUBARCH=arm64 $2
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
