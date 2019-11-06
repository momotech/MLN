#!/bin/bash

function open {
    sed -i '' "s/[\/]*\(.*mls:processor.*\)/\1/g" ./sdk/build.gradle
    sed -i '' "s/[\/]*\(.*Processor project(.*\)/\/\/\1/g" ./sdk/build.gradle
}

function close {
    sed -i '' "s/[\/]*\(.*mls:processor.*\)/\/\/\1/g" ./sdk/build.gradle
    sed -i '' "s/[\/]*\(.*Processor project(.*\)/\1/g" ./sdk/build.gradle
}

function main {
    if [ $1 -ne 1 ]; then
        close
    else
        open
    fi
}

function inform {
    echo "脚本后跟参数1表示调试LuaView 其他表示关闭"
}
if [ $# = 0 ];
then
    inform
else
    main $1
fi
