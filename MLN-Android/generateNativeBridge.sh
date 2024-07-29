#!/usr/bin/env bash

# $1: 是否为每个文件生成代码，1：是，其他：否，只生成新代码
gen_every_file=$1
if [ "${gen_every_file}" == "1" ]; then
    only_new=0
else
    only_new=1
fi
modules=('mmui' 'mlnservics')

file_name=generateNativeBridge.sh

for m in ${modules[*]} ; do
    if [ -f ${m}/${file_name} ]; then
        ${m}/${file_name} ${only_new}
        echo ""
    fi
done