

cmake_minimum_required(VERSION 3.4.1)

#设置头文件搜索路径（和此txt同个路径的头文件无需设置）
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../lua_include)
# sqlite
add_library(mlnbc SHARED
        lua_broadcastchannel.cpp )

#------------------broadcast channel link---------------------
add_library(libbroadcastchannel_so SHARED IMPORTED)
set_target_properties(libbroadcastchannel_so PROPERTIES IMPORTED_LOCATION
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libbroadcastchannel.so)

target_link_libraries(mlnbc luajapi_so libbroadcastchannel_so)