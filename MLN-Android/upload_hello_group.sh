#!/usr/bin/env bash

PACKAGE=('annotation' 'mlncore' 'HotReload' 'mlnservics')
DEFAULT_PACKAGE=('mlncore' 'mlnservics')
VERSION=hello_group_1.0
function inform() {
    echo "usage: ./upload_hello_group.sh <option> [-p <packages>]"
    echo "options:"
    echo "  -D: Debug mode(build so with debug info), Default: Release mode(build so without debug info)"
    echo "  -b: version name will be like ${VERSION}name, Default: beta_1"
    echo "      -b name --> ${VERSION}name"
    echo "      -b 0 --> ${VERSION}"
    echo "  -p: packages to upload, Default: ${DEFAULT_PACKAGE[*]}"
    echo "      all: ${PACKAGE[*]}"
    echo "  -s: open statistic, Default: not open"
    echo "  -c: commit and push"
    echo "  -u: do NOT upload so symbols to rifle, default upload"
    echo "  -a: arm type. Default: all"
    echo "      v7: armeabi-v7a"
    echo "      v8: arm64-v8a"
    echo "      all: armeabi-v7a and arm64-v8a"
    echo "      sep: upload 2 package, one with armeabi-v7a another arm64-v8a"
    echo "  -h: help"
}

# 拷贝符号表
# $1: module名称
function copy_so_symbols() {
    local _path="build/intermediates/cmake/release/obj"
    local _out="./release_so_symbols"
    local _module=$1
    if [ ! -d ${_module}/${_path} ]; then
        echo "${_module}/${_path} not a directory"
        return
    fi
    if [ ! -d $_out ]; then
        mkdir $_out
    fi
    cp -rf ${_module}/${_path} ${_out}/
}

# 开关plugin：armeabi.compat
# compat_plugin 0 ： 关
function compat_plugin() {
#    local open=$1
#    if [ $open -ne 0 ]; then
#        # 开
#        sed -i '' "s/[\/]*\(.*armeabi.compat\)/\1/g" upload_maven.gradle
#    else
#        sed -i '' "s/[\/]*\(.*armeabi.compat\)/\/\/\1/g" upload_maven.gradle
#    fi
  echo ""
}

# debug mode, default false
D=0
# commit automatic, default false
c=0
# statistic
s=0
# release version mode, default false
b=beta_1
u=1
arm=all
options=($@)
idx=0
packages=(${DEFAULT_PACKAGE[@]})
while getopts "hDucsb:a:p" optname
do
    case "$optname" in
        "h")
            inform
            exit 0
            ;;
        "D")
            let idx=idx+1
            D=1
            ;;
        "c")
            let idx=idx+1
            c=1
            ;;
        "u")
            let idx=idx+1
            u=0
            ;;
        "s")
            let idx=idx+1
            s=1
            ;;
        "b")
            let idx=idx+2
            b=$OPTARG
            ;;
        "a")
            let idx=idx+2
            arm=$OPTARG
            ;;
        "p")
            let idx=idx+1
            packages=(${options[@]:idx})
            break
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

if [ ${#packages[*]} -eq 0 ]; then
    echo "packages is empty"
    inform
    exit 1
fi
echo "------------------uploading ${#packages[*]} package: ${packages[*]}------------------"
sleep 1s

if [ $u -eq 1 ]; then
    sed -i '' "s/upload_symbols.*/upload_symbols = true/g" ./build.gradle
else
    sed -i '' "s/upload_symbols.*/upload_symbols = false/g" ./build.gradle
fi

compat_plugin 1
for pack in ${packages[*]} ; do
    cmd="./upload_hello_group.sh "
    if [[ ${D} -eq 1 ]]; then
        cmd="${cmd}-D "
    fi
    if [ "${pack}" == "HotReload" ]; then
        cmd="${cmd}-b ${b}"
    else
        cmd="${cmd}-a ${arm} -b ${b}"
    fi
    cd ${pack}
    if [ $? -ne 0 ]; then
        echo "upload ${pack} failed! no such package!"
        echo "all packages: ${PACKAGE[*]}"
        compat_plugin 0
        exit 1
    fi
    sed -i '' "s/VERSION=.*/VERSION=${VERSION}/g" upload_hello_group.sh
    echo "======================================================"
    echo "-------------------upload ${pack} --------------------"
    echo "======================================================"
    ${cmd}
    uploadResult=$?
    cd ../
    if [[ $uploadResult -ne 0 ]]; then
        echo upload ${pack} failed!!! code: $uploadResult
        echo revert build.gradle file!!!
        git checkout -- build.gradle
        sed -i '' "s/upload_symbols.*/upload_symbols = false/g" ./build.gradle
        compat_plugin 0
        exit $uploadResult
    fi
    if [ "${pack}" == "mlncore" ]; then
        echo " >> copy so"
        ./copySo.sh
    fi
    echo " >> copy symbol so"
    copy_so_symbols ${pack}
done

compat_plugin 0
sed -i '' "s/upload_symbols.*/upload_symbols = false/g" ./build.gradle
if [ $c -eq 1 ]; then
  git add build.gradle
  git add *.so
  git add *.h
  git commit -m "打包:${b}"
  git push
  git checkout -f
fi