# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

#设置头文件搜索路径（和此txt同个路径的头文件无需设置）
#INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../include/lua_include)
#INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../include)

add_library( mmuibridge SHARED
        mmdatabinding_callback.c
        mmdatabinding.c)

add_definitions(-DLUA_DL_DLOPEN -DLUA_USE_C89 -DLUA_COMPAT_5_1 -DLUA_COMPAT_ALL -DLUA_USE_LINUX -DJAVA_ENV -DP_ANDROID)

#------------------luajapi link---------------------
add_library(luajapi_so SHARED IMPORTED)
set_target_properties(luajapi_so PROPERTIES IMPORTED_LOCATION
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libluajapi.so)
#------------------android log link---------------------
find_library( log-lib log )

target_link_libraries( mmuibridge ${log-lib}
        luajapi_so)
