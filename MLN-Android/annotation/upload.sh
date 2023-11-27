#!/usr/bin/env bash

function changeSettingBefore {
    sed -i '' "s/\(include.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(include.*annotation\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = false/g" ../build.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(include.*\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = true/g" ../build.gradle
}

changeSettingBefore
./../gradlew :annotation:publish
ret=$?
changeSettingAfter
exit $ret