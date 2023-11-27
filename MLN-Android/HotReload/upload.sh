#!/usr/bin/env bash


function changeSettingBefore {
    sed -i '' "s/\(include.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(include.*HotReload\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = false/g" ../build.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(include.*\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = true/g" ../build.gradle
}

changeSettingBefore
./../gradlew :HotReload:publish
if [ $? -ne 0 ]; then
    echo "HotReload:publish error"
    changeSettingAfter
    exit 1
fi
./../gradlew :HotReload_Empty:publish
if [ $? -ne 0 ]; then
    echo "HotReload_Empty:publish error"
    changeSettingAfter
    exit 1
fi
changeSettingAfter