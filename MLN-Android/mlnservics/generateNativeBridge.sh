#!/usr/bin/env bash

only_new=$1
function echo_err() {
    echo -e "\033[1;33m${1}\033[0m"
}

basepath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
if [ ! -f ${basepath}/nativeBridgeConfig ]; then
    echo_err "找不到配置文件${basepath}/nativeBridgeConfig"
    exit 1
fi
source ${basepath}/nativeBridgeConfig

. ${basepath}/../gen_import.sh

echo "--------------userdata生成--------------"
gen_classes ${basepath}/.. mlnservics mln/bridge ${only_new}
echo "--------------callback生成--------------"
gen_callback ${basepath}/.. mlnservics mln/bridge ${only_new}