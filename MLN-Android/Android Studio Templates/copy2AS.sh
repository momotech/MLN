#!/usr/bin/env bash

for f in `ls` ; do
    if [[ -d ${f} ]]; then
        cp -R ${f} /Applications/Android\ Studio.app/Contents/plugins/android/lib/templates/MLN/
    fi
done
