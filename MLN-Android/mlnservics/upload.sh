#!/usr/bin/env bash
# 基础版本号

function changeSettingBefore {
    sed -i '' "s/\(include.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(include.*mlnservics\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = false/g" ../build.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(include.*\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = true/g" ../build.gradle
}

function closeNativeInfo() {
    sed -i '' "s/#*\(.*DJ_API_INFO\)/#\1/g" ./src/main/jni/mln/CMakeLists.txt
    sed -i '' "s/#*\(.*DMEM_INFO\)/#\1/g" ./src/main/jni/mln/CMakeLists.txt
    sed -i '' "s/#*\(.*DSTATISTIC_PERFORMANCE\)/#\1/g" ./src/main/jni/mln/CMakeLists.txt
}

function openNativeInfo() {
    sed -i '' "s/#*\(.*DJ_API_INFO\)/\1/g" ./src/main/jni/mln/CMakeLists.txt
#    sed -i '' "s/#*\(.*DMEM_INFO\)/\1/g" ./src/main/jni/mln/CMakeLists.txt
    sed -i '' "s/#*\(.*DSTATISTIC_PERFORMANCE\)/\1/g" ./src/main/jni/mln/CMakeLists.txt
}


changeSettingBefore
closeNativeInfo

echo '--------------task:bintrayUpload--------------'
./../gradlew :mlnservics:publish
ret=$?
changeSettingAfter
openNativeInfo
exit $ret