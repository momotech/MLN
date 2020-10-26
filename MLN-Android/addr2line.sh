#!/bin/bash

MODULE=('mlncore' 'mlnservics' 'mmui')
ARM=('armeabi-v7a' 'arm64-v8a')
SO_FILE=('libluajapi.so' 'libmlnbridge.so' 'libmmuibridge.so')

function inform() {
    echo "usage: ./addr2line.sh [option] ..."
    echo "options:"
    echo "  -x: x32 mode"
    echo "  -m: module, default 0"
    for (( i = 0; i < ${#MODULE[*]}; i++ )); do
        echo "     ${i} for ${MODULE[${i}]}"
    done
    echo "  -h: help"
}

x=${ARM[1]}
m=0
idx=0
while getopts "hxm:" optname
do
    case "$optname" in
        "h")
            inform
            exit
            ;;
        "x")
            x=${ARM[0]}
            let idx=idx+1
            ;;
        "m")
            m=$OPTARG
            let idx=idx+2
            ;;
        "?")
            echo "Unknown option $OPTARG"
            inform
            exit
            ;;
        ":")
            echo "No argument value for option $OPTARG"
            inform
            exit
            ;;
        *)
            inform
            exit
            ;;
    esac
done

if [ ${m} -ge ${#MODULE[*]} ]; then
    inform
    exit 1
fi

work_path=`pwd`
ndkDir=""
while read line; do
  if [[ "${line:0:1}" == "#" ]]; then
      continue
  fi
  if [ "${line:0:7}" == "ndk.dir" ]; then
      ndkDir=${line:8}
      break
  fi
done < ./local.properties

cd ${ndkDir}/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin
so_path="${work_path}/${MODULE[${m}]}/src/main/libs"
params=($@)
params=(${params[@]:idx})
so_path="${so_path}/${x}/${SO_FILE[${m}]}"

./aarch64-linux-android-addr2line -e ${so_path} ${params[*]}