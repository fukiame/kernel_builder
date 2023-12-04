#!/bin/bash
#
# idk lmao

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/env"

pack() {
  if [ ! -d ${zipper} ]; then
    git clone https://github.com/${zipper_repo} -b ${zipper_branch} "${zipper}"
    cd "${zipper}" || exit 1
  else
    cd "${zipper}" || exit 1
    git reset --hard
    git checkout ${zipper_branch}
    git fetch origin ${zipper_branch}
    git reset --hard origin/${zipper_branch}
  fi
  cp -af "${out_image}" "${zipper}"
  cc "${zipper}/dtbtool.c" -o "${maindir}/out/arch/arm64/boot/dts/dtbtool"
  cd "${maindir}/out/arch/arm64/boot/dts"
  ./dtbtool -v -s 2048 -o dt.img
  cp -af "${out_dt}" "${zipper}/dt.img"
  if [ -e ${maindir}/banner_append ]; then
    cat ${maindir}/banner_append >> ${zipper}/banner
  fi
  zip -r9 "$1" ./* -x .git README.md ./*placeholder
  cd "${maindir}"
}

# build
for toolchain in $1; do
  #rm -rf out

  bash -x "${outside}/toolchains/${toolchain}.sh" setup

  BUILD_START=$(date +"%s")
  export CUR_TOOLCHAIN="${toolchain}"

  bash -x "${outside}/toolchains/${toolchain}.sh" build ${defconfig}

  if [ -e "${out_image}" ]; then
    BUILD_END=$(date +"%s")
    DIFF=$((BUILD_END - BUILD_START))
    pack ${zip_name}
    echo "build succeeded in $((DIFF / 60))m, $((DIFF % 60))s" > "${zip_name}.info"
    echo "md5: $(md5sum "${zip_name}" | cut -d' ' -f1)" >> "${zip_name}.info"
    echo "compiler: $(cat ${toolchain}.info)" >> "${zip_name}.info"
  else
    BUILD_END=$(date +"%s")
    DIFF=$((BUILD_END - BUILD_START))
    echo "build failed in $((DIFF / 60))m, $((DIFF % 60))s" > "${toolchain}.log.info"
    echo "compiler: $(cat ${toolchain}.info)" >> "${toolchain}.log.info"
  fi
done
