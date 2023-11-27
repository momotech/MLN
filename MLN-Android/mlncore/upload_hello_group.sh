#!/usr/bin/env bash
# 基础版本号
VERSION=hello_group_1.0

function inform() {
    echo "usage: ./upload.sh <option>"
    echo "options:"
    echo "  -D: Debug mode(build so with debug info), Default: Release mode(build so without debug info)"
    echo "  -c: commit change automatic"
    echo "  -a: arm type. Default: all"
    echo "      v7: armeabi-v7a"
    echo "      v8: arm64-v8a"
    echo "      all: armeabi-v7a and arm64-v8a"
    echo "      sep: upload 2 package, one with armeabi-v7a another arm64-v8a"
    echo "  -b: version name will be like ${VERSION}name, Default: beta_1"
    echo "      -b name --> ${VERSION}name"
    echo "      -b 0 --> ${VERSION}"
    echo "  -s: open statistic, Default: not open"
    echo "  -h: help"
}

function changeArmSettingBefore() {
    if [[ "$1" == "v7" ]]; then
        sed -i '' "s/arm_type =.*/arm_type = 2/g" ../build.gradle
        return 0
    elif [[ "$1" == "v8" ]]; then
        sed -i '' "s/arm_type =.*/arm_type = 1/g" ../build.gradle
        return 0
    elif [[ "$1" == "all" ]]; then
        sed -i '' "s/arm_type =.*/arm_type = 0/g" ../build.gradle
        return 0
    fi
    return 1
}

function changeArmSettingAfter() {
    sed -i '' "s/arm_type =.*/arm_type = 0/g" ../build.gradle
}

function changeSettingBefore {
    sed -i '' "s/\(include.*\)/\/\/\1/g" ../settings.gradle

    sed -i '' "s/\/*\(include.*mlncore\)/\1/g" ../settings.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(include.*\)/\1/g" ../settings.gradle
}

function changeVersion {
    if [[ "$1" != "0" ]]; then
        version=${VERSION}$1
    else
        version=${VERSION}
    fi
    if [[ "$2" == "v7" ]]; then
        version=${version}_armv7
    elif [[ "$2" == "v8" ]]; then
        version=${version}_armv8
    fi
    sed -i '' "s/mlnCoreVersion.*/mlnCoreVersion = '${version}'/g" ../build.gradle
}

function closeNativeInfo() {
    sed -i '' "s/#*\(.*DJ_API_INFO\)/#\1/g" ./src/main/jni/japi/CMakeLists.txt
    sed -i '' "s/#*\(.*DMEM_INFO\)/#\1/g" ./src/main/jni/japi/CMakeLists.txt
}

function openNativeInfo() {
    sed -i '' "s/#*\(.*DJ_API_INFO\)/\1/g" ./src/main/jni/japi/CMakeLists.txt
#    sed -i '' "s/#*\(.*DMEM_INFO\)/\1/g" ./src/main/jni/japi/CMakeLists.txt
}

function openStatistic() {
    sed -i '' "s/#*\(.*DSTATISTIC_PERFORMANCE\)/\1/g" ./src/main/jni/japi/CMakeLists.txt
}

function closeStatistic() {
    sed -i '' "s/#*\(.*DSTATISTIC_PERFORMANCE\)/#\1/g" ./src/main/jni/japi/CMakeLists.txt
}

# debug mode, default false
D=0
# commit automatic, default false
c=0
# statistic
s=0
# release version mode, default false
b=beta_1
arm=('all')
while getopts "hDcsb:a:" optname
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
        "s")
            s=1
            ;;
        "b")
            b=$OPTARG
            ;;
        "a")
            if [[ "$OPTARG" == "sep" ]]; then
                arm=("v7" "v8" "all")
            else
                arm=("$OPTARG")
            fi
            ;;
    esac
done

changeSettingBefore

if [[ ${D} -ne 1 ]]; then
    closeNativeInfo
else
    openNativeInfo
fi
if [[ ${c} -eq 1 ]]; then
    openStatistic
else
    closeStatistic
fi
for ARM in ${arm[*]} ; do
  changeArmSettingBefore $ARM
  if [[ $? -ne 0 ]]; then
      echo "arm type error!"
      inform
      changeArmSettingAfter
      changeSettingAfter
      openNativeInfo
      openStatistic
      exit 1
  fi
  changeVersion $b $ARM
  echo "----------------------------version: ${version}----------------------------"
  echo "----------------------------task: mlncore clean----------------------------"
  ./../gradlew :mlncore:clean >/dev/null 2>&1
  echo "----------------------------task: mlncore uploadArchives ${ARM}----------------------------"
  ./../gradlew :mlncore:uploadArchives >/dev/null
  uploadResult=$?
  if [[ $uploadResult -ne 0 ]]; then
      changeArmSettingAfter
      changeSettingAfter
      openNativeInfo
      openStatistic
      echo upload failed!!! code: $uploadResult
#      echo revert build.gradle file!!!
#      git checkout -- ../build.gradle
      exit $uploadResult
  fi
  echo "----------------------------finish ${ARM}----------------------------"
done

echo "----------------------------all finish----------------------------"
changeArmSettingAfter
changeSettingAfter
openNativeInfo
openStatistic

if [[ ${c} -eq 1 ]]; then
    git add --all
    git commit -m "打包mln core，版本号 = ${version}"
fi
