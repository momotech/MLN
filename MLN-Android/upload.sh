#!/usr/bin/env bash

PACKAGE=('mlncore' 'mlnservics' 'yoga' 'mmui')
VERSION=mmui_1.0.0
function inform() {
    echo "usage: ./upload.sh <option>"
    echo "options:"
    echo "  -D: Debug mode(build so with debug info), Default: Release mode(build so without debug info)"
    echo "  -a: arm type. Default: all"
    echo "      v7: armeabi-v7a"
    echo "      v8: arm64-v8a"
    echo "      all: armeabi-v7a and arm64-v8a"
    echo "      sep: upload 2 package, one with armeabi-v7a another arm64-v8a"
    echo "  -b: version name will be like ${VERSION}name, Default: beta_1"
    echo "      -b name --> ${VERSION}name"
    echo "      -b 0 --> ${VERSION}"
    echo "  -h: help"
}

# debug mode, default false
D=0
# commit automatic, default false
c=0
# release version mode, default false
b=beta_1
arm=all
while getopts "hDcb:a:" optname
do
    case "$optname" in
        "h")
            inform
            exit
            ;;
        "D")
            D=1
            ;;
        "c")
            c=1
            ;;
        "b")
            b=$OPTARG
            ;;
        "a")
            arm=$OPTARG
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

echo "------------------uploading ${#PACKAGE[*]} package: ${PACKAGE[*]}------------------"
sleep 1s

for pack in ${PACKAGE[*]} ; do
    cmd="./upload.sh "
    if [[ ${D} -eq 1 ]]; then
        cmd="${cmd}-D "
    fi
    cmd="${cmd}-a ${arm} -b ${b}"
    cd ${pack}
    sed -i '' "s/VERSION=.*/VERSION=${VERSION}/g" upload.sh
    echo "======================================================"
    echo "-------------------upload ${pack} --------------------"
    echo "======================================================"
    ${cmd}
    uploadResult=$?
    cd ../
    if [[ $uploadResult -ne 0 ]]; then
        echo upload ${pack} failed!!! code: $uploadResult
        echo revert build.gradle file!!!
        git checkout -- ../build.gradle
        exit $uploadResult
    fi
done