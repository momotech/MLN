# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/include)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/include/lua_include)
#设置生成的so动态库最后输出的路径
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/../libs/${ANDROID_ABI})

#添加子目录，将自动找到子目录中的CMakeLists.txt
ADD_SUBDIRECTORY(${CMAKE_CURRENT_SOURCE_DIR}/anim)
ADD_SUBDIRECTORY(${CMAKE_CURRENT_SOURCE_DIR}/bridge)