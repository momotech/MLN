#!/bin/bash

function inform() {
    echo "usage: ./addr2line.sh [option] ..."
    echo "options:"
    echo "  -x: x64 mode"
    echo "  -h: help"
}

x=0
while getopts "hx" optname
do
    case "$optname" in
        "h")
            inform
            exit
            ;;
        "x")
            x=1
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

work_path=`pwd`
cd ${NDK_PATH}/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin
so_path="${work_path}/sdk/src/main/libs/"
params=$@
if [[ $x -eq 1 ]]; then
    so_path="${so_path}arm64-v8a/libluajapi.so"
    params=${params#* }
else
    so_path="${so_path}armeabi-v7a/libluajapi.so"
fi
./aarch64-linux-android-addr2line -e ${so_path} $params