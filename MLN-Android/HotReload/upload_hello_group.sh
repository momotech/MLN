#!/usr/bin/env bash
# 基础版本号
version=hello_group_1.0

function inform() {
    echo "usage: ./upload.sh <option>"
    echo "options:"
    echo "  -b: version name will be like ${version}name, Default: 0_1"
    echo "      -b name --> ${version}name"
    echo "  -h: help"
}

function changeSettingBefore {
    sed -i '' "s/\(include.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(include.*HotReload\)/\1/g" ../settings.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(include.*\)/\1/g" ../settings.gradle
}

function changeVersion {
    sed -i '' "s/hotreloadVersion =.*/hotreloadVersion = '${version}${1}'/g" ../build.gradle
}

b=0_1
while getopts "hb:" optname
do
    case "$optname" in
        "h")
            inform
            exit 1
            ;;
        "b")
            b=$OPTARG
            ;;
    esac
done
changeSettingBefore
changeVersion $b
./../gradlew :HotReload:uploadArchives
ret=$?
if [ $ret -ne 0 ]; then
    changeSettingAfter
    exit $ret
fi
./../gradlew :HotReload_Empty:uploadArchives
ret=$?
changeSettingAfter
if [ $ret -ne 0 ]; then
    exit $ret
fi
