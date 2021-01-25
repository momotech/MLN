#!/usr/bin/env bash


function changeSettingBefore {
    sed -i '' "s/\(.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(.*HotReload\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = false/g" ../build.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(.*\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = true/g" ../build.gradle
}

changeSettingBefore
./../gradlew :HotReload:bintrayUpload
if [ $? -ne 0 ]; then
    echo "HotReload:bintrayUpload error"
    changeSettingAfter
    exit 1
fi
./../gradlew :HotReload_Empty:bintrayUpload
if [ $? -ne 0 ]; then
    echo "HotReload_Empty:bintrayUpload error"
    changeSettingAfter
    exit 1
fi
changeSettingAfter