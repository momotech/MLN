#!/usr/bin/env bash
# 基础版本号
function changeSettingBefore {
    sed -i '' "s/\(.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(.*mmui\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = false/g" ../build.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(.*\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = true/g" ../build.gradle
}

function closeNativeInfo() {
    sed -i '' "s/#*\(.*DSTATISTIC_PERFORMANCE\)/#\1/g" ./src/main/jni/bridge/CMakeLists.txt
}

function openNativeInfo() {
    sed -i '' "s/#*\(.*DSTATISTIC_PERFORMANCE\)/\1/g" ./src/main/jni/bridge/CMakeLists.txt
}


changeSettingBefore
closeNativeInfo

echo '--------------task:bintrayUpload--------------'
./../gradlew :mmui:bintrayUpload
ret=$?
changeSettingAfter
openNativeInfo
exit $ret