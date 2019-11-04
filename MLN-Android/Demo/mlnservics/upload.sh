#!/usr/bin/env bash
# 基础版本号
version=2.0

function inform() {
    echo "usage: ./upload.sh <option>"
    echo "options:"
    echo "  -D: Debug mode(build so with debug info), Default: Release mode(build so without debug info)"
    echo "  -c: commit change automatic"
    echo "  -b: beta mode, version name will be like 1.3.0_beta1, Default: 1"
    echo "      -b n --> 1.3.0_betan"
    echo "      -b 0 --> 1.3.0"
    echo "  -h: help"
}

function changeSettingBefore {
    sed -i '' "s/\(.*\)/\/\/\1/g" ../settings.gradle
    sed -i '' "s/\/*\(.*mlnservics\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = false/g" ../build.gradle
}

function changeSettingAfter {
    sed -i '' "s/\/*\(.*\)/\1/g" ../settings.gradle

    sed -i '' "s/\(.*implementation_debug\).*/\1 = true/g" ../build.gradle
}

function change2ReleaseVersion {
    cc=`cat ./src/main/java/com/immomo/mls/Constants.java | grep 'String SDK_VERSION'`
    cc=${cc#*\"}
    cc=${cc%\"*}
    v=${cc}
    if [[ "$1" != "0" ]]; then
        v=${v}_beta$1
    fi
    version=${v}
    echo $version
    sed -i '' "s/mlnsVersion.*/mlnsVersion = '${version}'/g" ../build.gradle
}

#function release_so() {
#    nd=`pwd`
#    cd src/main/jni
#    ./build_jni.sh -R >/dev/null 2>&1
#    build_jni_result=$?
##    git checkout -- ../libs/armeabi/liblblur.so
#    rm -rf ../obj/local/armeabi/objs
#    cd ${nd}
#    return $build_jni_result
#}

function closeNativeInfo() {
    sed -i '' "s/#*\(.*DJ_API_INFO\)/#\1/g" ./src/main/jni/mln/CMakeLists.txt
    sed -i '' "s/#*\(.*DMEM_INFO\)/#\1/g" ./src/main/jni/mln/CMakeLists.txt
}

function openNativeInfo() {
    sed -i '' "s/#*\(.*DJ_API_INFO\)/\1/g" ./src/main/jni/mln/CMakeLists.txt
    sed -i '' "s/#*\(.*DMEM_INFO\)/\1/g" ./src/main/jni/mln/CMakeLists.txt
}

# debug mode, default false
D=0
# commit automatic, default false
c=0
# release version mode, default false
b=1
while getopts "hDcb:" optname
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
        "b")
            b=$OPTARG
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
change2ReleaseVersion $b
if [[ ${D} -ne 1 ]]; then
    closeNativeInfo
else
    openNativeInfo
fi
echo '--------------task:uploadArchives--------------'
./../gradlew :mlnservics:uploadArchives
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
    git commit -m "打包 版本号 = ${version}"
fi