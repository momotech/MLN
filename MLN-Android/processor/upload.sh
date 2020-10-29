#!/usr/bin/env bash

function changeSettingBefore {
    sed -i '' "s/\(.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(.*processor\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = false/g" ../build.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(.*\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = true/g" ../build.gradle
}

changeSettingBefore
./../gradlew :processor:bintrayUpload
ret=$?
changeSettingAfter
exit $ret