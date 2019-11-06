

cmake_minimum_required(VERSION 3.4.1)

# sqlite
add_library(sqlite3 SHARED
        sqlite3.c
        mmsqlite.c)
target_link_libraries(sqlite3 luajapi)