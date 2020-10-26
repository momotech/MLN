#!/usr/bin/env bash

OUT_NAME=LuaStatistic.jar
NAME=Statistic.jar
#DIR=tempDir
META_DIR=src/main/java/META-INF
META_NAME=MANIFEST.MF

jar umf ${META_DIR}/${META_NAME} ${NAME}
mv ${NAME} ../../${NAME}