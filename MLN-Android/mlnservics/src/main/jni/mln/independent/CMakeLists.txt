

cmake_minimum_required(VERSION 3.4.1)

#设置头文件搜索路径（和此txt同个路径的头文件无需设置）
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../lua_include)
# sqlite
add_library(sqlite3 SHARED
        sqlite3.c
        mmsqlite.c)
#------------------luajapi link---------------------
add_library(luajapi_so SHARED IMPORTED)
set_target_properties(luajapi_so PROPERTIES IMPORTED_LOCATION
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libluajapi.so)
target_link_libraries(sqlite3 luajapi_so)