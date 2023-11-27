#!/usr/bin/env bash

# shellcheck disable=SC2045
if [ -d /Applications/Android\ Studio.app/Contents/plugins/android/lib ]; then
    if [ ! -d /Applications/Android\ Studio.app/Contents/plugins/android/lib/templates/MLN ]; then
        mkdir -p /Applications/Android\ Studio.app/Contents/plugins/android/lib/templates/MLN
    fi
fi
if [ ! -d /Applications/Android\ Studio.app/Contents/plugins/android/lib/templates/MLN ]; then
    echo "/Applications/Android\ Studio.app/Contents/plugins/android/lib/templates/MLN 不存在"
    exit 1
fi
for f in `ls` ; do
    if [[ -d ${f} ]]; then
        cp -R ${f} /Applications/Android\ Studio.app/Contents/plugins/android/lib/templates/MLN/
    fi
done
