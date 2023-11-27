#!/usr/bin/env bash

only_new=$1
function echo_err() {
    echo -e "\033[1;33m${1}\033[0m"
}

basepath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
if [ ! -f ${basepath}/nativeBridge.config ]; then
    echo_err "找不到配置文件${basepath}/nativeBridge.config"
    exit 1
fi

. ${basepath}/../parseConfig.sh ${basepath}/nativeBridge.config ${basepath}/temp.config
source ${basepath}/temp.config
rm -f ${basepath}/temp.config

. ${basepath}/../gen_import.sh

echo "--------------userdata生成--------------"
gen_classes ${basepath}/.. mlnservics mln/bridge ${only_new}
echo "--------------callback生成--------------"
gen_callback ${basepath}/.. mlnservics mln/bridge ${only_new}
echo "--------------cmakelist生成--------------"
gen_cmakelists ${basepath}/src/main/jni/mln/CMakeLists.txt "bridge/"