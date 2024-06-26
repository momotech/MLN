#!/usr/bin/env bash

PACKAGE=('annotation' 'processor' 'mlncore' 'HotReload' 'mlnservics')
DEFAULT_PACKAGE=('mlncore' 'mlnservics')

function inform() {
    echo "usage: ./upload.sh <option> [-p <packages>]"
    echo "options:"
    echo "  -p: packages to upload, Default: ${DEFAULT_PACKAGE[@]}"
    echo "      all: ${PACKAGE[@]}"
    echo "  -c: commit and push"
    echo "  -d: show debug info"
    echo "  -h: help"
}

# commit automatic, default false
c=0
d=0
options=($@)
idx=0
packages=(${DEFAULT_PACKAGE[@]})
while getopts "hdcp" optname
do
    case "$optname" in
        "h")
            inform
            exit 0
            ;;
        "d")
            let idx=idx+1
            d=1
            ;;
        "c")
            let idx=idx+1
            c=1
            ;;
        "p")
            let idx=idx+1
            packages=(${options[@]:idx})
            break
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

if [ ${#packages[*]} -eq 0 ]; then
    echo "packages is empty"
    inform
    exit 1
fi

sed -i '' "s/\(implementation_debug = \).*/\1false/g" ./build.gradle
sed -i '' "s/\(update_hello_group = \).*/\1false/g" ./build.gradle

echo "------------------uploading ${#packages[*]} package: ${packages[*]}------------------"
sleep 1s

for pack in ${packages[*]} ; do
    cmd="./upload.sh "
    cd ${pack}
    if [ $? -ne 0 ]; then
        echo "upload ${pack} failed! no such package!"
        echo "all packages: ${PACKAGE[@]}"
        exit 1
    fi

    echo "======================================================"
    echo "-------------------upload ${pack} --------------------"
    echo "======================================================"
    if [ $d -eq 1 ]; then
      ${cmd}
    else
      ${cmd} >/dev/null
    fi

    uploadResult=$?
    cd ../
    if [[ $uploadResult -ne 0 ]]; then
        echo upload ${pack} failed!!! code: $uploadResult
#        echo revert build.gradle file!!!
#        git checkout -- build.gradle
        exit $uploadResult
    fi
    if [ "${pack}" == "mlncore" ]; then
        echo " >> copy so"
        ./copySo.sh
    fi
done

if [ $c -eq 1 ]; then
  git add build.gradle
  git commit -m "打包:${b}"
  git push
  git checkout -f
fi