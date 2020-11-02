# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

cmake_minimum_required(VERSION 3.4.1)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/../libs/${ANDROID_ABI})

set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -s")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s")

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -s" )
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -s" )

ADD_SUBDIRECTORY(${CMAKE_CURRENT_SOURCE_DIR}/yoga)

add_compile_options(
        -fno-omit-frame-pointer
        -fexceptions
        -fvisibility=hidden
        -ffunction-sections
        -fdata-sections
        -Wall
        -std=c++11)

file(GLOB jni_SRC
        jni/*.cpp)

file(GLOB yogajni_version_script
        yogajni.version)

add_library(yoga SHARED ${jni_SRC})

target_link_libraries(yoga -Wl,--gc-sections,--version-script=${yogajni_version_script} yogacore)
