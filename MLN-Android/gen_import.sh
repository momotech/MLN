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
            if [ -z "${classes[${i}]}" ]; then
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
            if [ -z "${callback_classes[${i}]}" ]; then
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

function gen_cmakelists() {
    local cmakeFile=$1
    local prefix=$2
    local files=(${out_files[@]} ${callback_out_files[@]})
    local StartMark="#native bridge start"
    local EndMark="#native bridge end"
    if [ ! -f ${cmakeFile} ]; then
        echo_err "找不到${cmakeFile}文件"
        exit 1
    fi
    local allLines=()
    local flag=0
    IFS_old=$IFS
    IFS=$'\n'
    for line in `cat ${cmakeFile}`; do
        if [ ${flag} -eq 0 ]; then
            if [[ ${line} =~ ${StartMark} ]]; then
                flag=1
            fi
            allLines[${#allLines[@]}]="$line"
            continue
        elif [ ${flag} -eq 1 ]; then
            if [[ ${line} =~ ${EndMark} ]]; then
                flag=2
                for i in ${files[@]} ; do
                    allLines[${#allLines[@]}]="        ${prefix}${i}"
                done
                allLines[${#allLines[@]}]="$line"
            fi
            continue
        else
            allLines[${#allLines[@]}]="$line"
        fi
    done
    IFS=$IFS_old

    local len=${#allLines[@]}
    for (( i = 0; i < ${len}; i++ )); do
        if [ $i -eq 0 ]; then
            echo -e "${allLines[$i]}" > ${cmakeFile}
        else
            echo -e "${allLines[$i]}" >> ${cmakeFile}
        fi
    done
}