#!/usr/bin/env bash

function checkDir() {
    if [[ ! -d ${1} ]]; then
        echo "${1} is not a directory"
        exit 1
    fi
}

projectDir=`pwd`
projectDir=${projectDir%%/src*}

# 工程目录
projectDir=${projectDir%/*}
# core目录
coreDir=${projectDir}/mlncore
# mln目录
mlnDir=${projectDir}/mmui
# src结构
srcDir=src/main
# jni结构
jniDir=${srcDir}/jni
# so文件夹结构
libsDir=${srcDir}/libs
# cpu类型
arm=(armeabi-v7a arm64-v8a)

# 非lua头文件存放位置
mln_from=${jniDir}/japi
# lua头文件存放位置
lua_from=${jniDir}/lua

# 非lua的头文件存放位置
mln_include=${jniDir}/include
# lua头文件存放位置
lua_include=${jniDir}/include/lua_include

checkDir ${coreDir}
checkDir ${mlnDir}

function copy_h() {
    fromDir=$1
    toDir=$2
    checkDir ${fromDir}
    if [[ ! -d ${toDir} ]]; then
        mkdirs ${toDir}
    fi

    for file in `ls ${fromDir}/*.h` ; do
        cp ${file} ${toDir}/
    done
}

function copy_so() {
    fromDir=$1
    toDir=$2
    checkDir ${fromDir}
    if [[ ! -d ${toDir} ]]; then
        mkdirs ${toDir}
    fi

    for ARM in ${arm[*]} ; do
        for file in `ls ${fromDir}/${ARM}/*.so` ; do
            cp ${file} ${toDir}/${ARM}/
        done
    done

}

copy_h ${coreDir}/${mln_from} ${mlnDir}/${mln_include}
#copy_h ${coreDir}/${lua_from} ${mlnDir}/${lua_include}
copy_so ${coreDir}/${libsDir} ${mlnDir}/${libsDir}