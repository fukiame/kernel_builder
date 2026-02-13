#!/bin/bash
#
# shellcheck disable=SC2154,SC2155,SC1090
# hdjsjfjjwufbeizihfjejzf

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

curl -LSs "https://raw.githubusercontent.com/backslashxx/KernelSU/refs/heads/master/kernel/setup.sh" | bash -
git add . && git commit -am "drivers: KernelSU"
KSU_git_ver=$(cd KernelSU && git rev-list --count HEAD)
KSU_ver=$((KSU_git_ver + 30000))

if [ "$ksu_use_tamper" == "true" ] ; then
  echo "CONFIG_KSU_TAMPER_SYSCALL_TABLE=y" >> "${defconfig_file}"
else
patchesdir="$outside/ksu/patches/$(echo "$kernel_ver" | cut -d. -f1,2)"
if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    git am "$patch_file"
  done
else
  echo "patching ksu failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi
fi

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-ks${KSU_ver}\"/" "${defconfig_file}"

grep 'CONFIG_LOCALVERSION=' "${defconfig_file}"

echo -e " \nincludes backslashxx's KernelSU fork, ver ${KSU_ver}" >> banner_append

