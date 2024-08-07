#!/usr/bin/env bash
#
# wrapper providing almost the same amount of verbosity as the main github actions workflow

sln=$(readlink -f "$0")
spath=$(dirname "$sln")
echo $spath

export OLDDIR=$(pwd)
cd $spath

source ./priv_env

RUN_ID=$(shuf -ern4 {0..9} | sha1sum - | head -c 8)
RUN_START=$(date +"%s")
#ALT_RECIPENT=$1
#if [ ! -z $ALT_RECIPENT ]; then
#  CHAT_ID="$ALT_RECIPENT"
#fi
bash tg_utils.sh msg "$RUN_ID: run started"

if [ ! -z "$NOTE" ]; then
  bash tg_utils.sh msg "$NOTE"
fi
if [ ! -z "$VERBOSE" ]; then
  bash tg_utils.sh msg "host: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2)%nlfree disk space: $(df --sync -BM --output=avail / | grep -v Avail)"
  bash tg_utils.sh msg "cloning kernel source%nlrepo: $kernel_repo%nlbranch: $kernel_branch"
fi

if [ ! -d kernel ]; then
  git clone ${kernel_repo} -b ${kernel_branch} kernel || exit 1
  cd kernel
else
  cd kernel || exit 1
  git reset --hard
  git checkout ${kernel_branch}
  git fetch origin ${kernel_branch}
  git reset --hard origin/${kernel_branch}
fi

source ../env
bash ../tg_utils.sh msg "kernel name: ${kernel_name}%nlkernel ver: ${kernel_ver}%nlkernel head commit: ${kernel_head}%nldefconfig: ${defconfig}"

case $PATCH_KSU in
  "both" )
    bash ../tg_utils.sh msg "running compilation script(s): $COMPILERS"
    bash ../build.sh "$COMPILERS"
    bash ../tg_utils.sh msg "KernelSU patching enabled, patching"
    bash ../ksu/applyPatches.sh || exit 1
    bash ../tg_utils.sh msg "running compilation script(s): $COMPILERS"
    bash ../build.sh "$COMPILERS"
  ;;
  "" )
    bash ../tg_utils.sh msg "running compilation script(s): $COMPILERS"
    bash ../build.sh "$COMPILERS"
  ;;
  * )
    bash ../tg_utils.sh msg "KernelSU patching enabled, patching"
    bash ../ksu/applyPatches.sh || exit 1
    bash ../tg_utils.sh msg "running compilation script(s): $COMPILERS"
    bash ../build.sh "$COMPILERS"
  ;;
esac

if [[ $(ls *.log) ]]; then
  for file in *.log ; do
    if [ -e "${file}.info" ]; then
      bash ../tg_utils.sh up "${file}" "$(cat "${file}.info")"
      export RES=0
    fi
  done
fi
if [[ $(ls *.zip) ]]; then
  for file in *.zip ; do
    bash ../tg_utils.sh up "${file}" "$(cat "${file}.info")"
    export RES=1
  done
fi

rm *.zip*
if [[ ! -z "$1" ]]; then rm -rf out; fi

RUN_END=$(date +"%s")
WDIFF=$((RUN_END - RUN_START))
[ "$RES" = "0" ] && bash ../tg_utils.sh msg "$RUN_ID: run failed in $((WDIFF / 60))m, $((WDIFF % 60))s" || bash ../tg_utils.sh msg "$RUN_ID: run ended in $((WDIFF / 60))m, $((WDIFF % 60))s"

cd "$OLDDIR"
