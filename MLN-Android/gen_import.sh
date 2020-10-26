#!/usr/bin/env bash

function gen_classes() {
    local mlncgenPath=$1
    local module=$2
    local jni=$3
    local only_new=$4
    local len=${#classes[*]}
    if [ ${len} -ne ${#out_files[*]} ]; then
        echo_err "classes长度和out_files长度不相同！"
        exit 1
    fi
    local cmd=''
    if [ $only_new -eq 1 ]; then
        for (( i = 0; i < ${len}; i++ )); do
            if [ -f "${module}/src/main/jni/${jni}/${out_files[${i}]}" ]; then
                continue
            fi
            cmd="java -jar ${mlncgenPath}/mlncgen.jar -module ${module} -class ${classes[${i}]} -jni ${jni} -name ${out_files[${i}]}"
            $cmd
        done
    else
        for (( i = 0; i < ${len}; i++ )); do
            cmd="java -jar ${mlncgenPath}/mlncgen.jar -module ${module} -class ${classes[${i}]} -jni ${jni} -name ${out_files[${i}]}"
            $cmd
        done
    fi
}

function gen_callback() {
    local mlncgenPath=$1
    local module=$2
    local jni=$3
    local only_new=$4
    local len=${#callback_classes[*]}
    if [ ${len} -ne ${#callback_out_files[*]} ]; then
        echo_err "callback_classes长度和callback_out_files长度不相同！"
        exit 1
    fi
    local cmd=''
    if [ $only_new -eq 1 ]; then
        for (( i = 0; i < ${len}; i++ )); do
            if [ -f "${module}/src/main/jni/${jni}/${callback_out_files[${i}]}" ]; then
                continue
            fi
            cmd="java -jar ${mlncgenPath}/mlncgen.jar -callback -module ${module} -class ${callback_classes[${i}]} -jni ${jni} -name ${callback_out_files[${i}]}"
            $cmd
        done
    else
        for (( i = 0; i < ${len}; i++ )); do
            cmd="java -jar ${mlncgenPath}/mlncgen.jar -callback -module ${module} -class ${callback_classes[${i}]} -jni ${jni} -name ${callback_out_files[${i}]}"
            $cmd
        done
    fi
}