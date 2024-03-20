

cmake_minimum_required(VERSION 3.4.1)

#设置头文件搜索路径（和此txt同个路径的头文件无需设置）
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../lua_include)
link_directories(${LINK_LIBRARY_DIRECTORY})
add_library(mlnbc SHARED
        lua_broadcastchannel.cpp )

target_link_libraries(mlnbc luajapi broadcastchannel)