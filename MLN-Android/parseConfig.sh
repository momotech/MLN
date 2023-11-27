#!/bin/bash

# $1: 输入文件
# $2: 输出文件

CLASS='#class start'
CALLBACK='#callback start'

IN_FILE=$1
OUT_FILE=$2

classes=()
out_files=()
callback_classes=()
callback_out_files=()

function on_class_read() {
    local line=$1
    if [ -z "${line}" ] || [ "${line:0:1}" == "#" ] || [ "${line:0:1}" == " " ]; then
      return
    fi
    classes[${#classes[@]}]="'${line%% *}'"
    out_files[${#out_files[@]}]="'${line##* }'"
}

function on_callback_read() {
    local line=$1
    if [ -z "${line}" ] || [ "${line:0:1}" == "#" ] || [ "${line:0:1}" == " " ]; then
      return
    fi
    callback_classes[${#callback_classes[@]}]="'${line%% *}'"
    callback_out_files[${#callback_out_files[@]}]="'${line##* }'"
}

read_conifg=0
while read line
do
  if [ "${line:0:${#CLASS}}" == "${CLASS}" ]; then
    read_conifg=1
    continue
  elif [ "${line:0:${#CALLBACK}}" == "${CALLBACK}" ]; then
    read_conifg=2
    continue
  elif [ $read_conifg -eq 1 ]; then
    on_class_read "$line"
  elif [ $read_conifg -eq 2 ]; then
    on_callback_read "$line"
  fi
done < ${IN_FILE}

echo "classes=(${classes[@]})" > ${OUT_FILE}
echo "out_files=(${out_files[@]})" >> ${OUT_FILE}
echo "callback_classes=(${callback_classes[@]})" >> ${OUT_FILE}
echo "callback_out_files=(${callback_out_files[@]})" >> ${OUT_FILE}