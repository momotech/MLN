#!/usr/bin/env bash

cd mlnservics/src/main/jni
./copy_h_so.sh

cd ../../../..
cd mmui/src/main/jni
./copy_h_so.sh