#!/usr/bin/env bash

function changeSettingBefore {
    sed -i '' "s/\(include.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(include.*processor\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = false/g" ../build.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(include.*\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = true/g" ../build.gradle
}

changeSettingBefore
./../gradlew :processor:publish
ret=$?
changeSettingAfter
exit $ret