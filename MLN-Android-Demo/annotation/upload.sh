#!/usr/bin/env bash
# 基础版本号
version=2.0

function changeSettingBefore {
    sed -i '' "s/\(.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(.*annotation\)/\1/g" ../settings.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(.*\)/\1/g" ../settings.gradle
}

function changeVersion {
    now=$(date +%m%d_%H%M)
#    echo ${version}${now}
    sed -i '' "s/annotationVersion.*/annotationVersion = '${version}.${now}'/g" ../build.gradle
}

changeSettingBefore
changeVersion
./../gradlew :annotation:uploadArchives
changeSettingAfter