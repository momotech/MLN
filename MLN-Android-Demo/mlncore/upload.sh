#!/usr/bin/env bash
# 基础版本号
version=1.4

function inform() {
    echo "usage: ./upload.sh <option>"
    echo "options:"
    echo "  -D: Debug mode(build so with debug info), Default: Release mode(build so without debug info)"
    echo "  -c: commit change automatic"
    echo "  -h: help"
}

function changeSettingBefore {
    sed -i '' "s/\(.*\)/\/\/\1/g" ../settings.gradle

    sed -i '' "s/\/*\(.*mlncore\)/\1/g" ../settings.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(.*\)/\1/g" ../settings.gradle
}

function changeVersion {
    now=$(date +%m%d_%H%M)
    version=${version}.${now}
    sed -i '' "s/mlnCoreVersion.*/mlnCoreVersion = '${version}'/g" ../build.gradle
}

function closeNativeInfo() {
    sed -i '' "s/#*\(.*DJ_API_INFO\)/#\1/g" ./src/main/jni/japi/CMakeLists.txt
    sed -i '' "s/#*\(.*DMEM_INFO\)/#\1/g" ./src/main/jni/japi/CMakeLists.txt
}

function openNativeInfo() {
    sed -i '' "s/#*\(.*DJ_API_INFO\)/\1/g" ./src/main/jni/japi/CMakeLists.txt
    sed -i '' "s/#*\(.*DMEM_INFO\)/\1/g" ./src/main/jni/japi/CMakeLists.txt
}

# debug mode, default false
D=0
# commit automatic, default false
c=0
while getopts "hDc" optname
do
    case "$optname" in
        "h")
            inform
            exit
            ;;
        "D")
            D=1
            ;;
        "c")
            c=1
            ;;
        "?")
            echo "Unknown option $OPTARG"
            inform
            exit
            ;;
        ":")
            echo "No argument value for option $OPTARG"
            inform
            exit
            ;;
        *)
            inform
            exit
            ;;
    esac
done

changeSettingBefore
changeVersion
if [[ ${D} -ne 1 ]]; then
    closeNativeInfo
else
    openNativeInfo
fi
echo '--------------task:uploadArchives--------------'
./../gradlew :mlncore:uploadArchives
uploadResult=$?
changeSettingAfter
openNativeInfo
if [[ $uploadResult -ne 0 ]]; then
    echo upload failed!!! code: $uploadResult
    echo revert build.gradle file!!!
    git checkout -- ../build.gradle
    exit $uploadResult
fi
echo 'finish'

if [[ ${c} -eq 1 ]]; then
    git add --all
    git commit -m "打包mln core，版本号 = ${version}"
fi