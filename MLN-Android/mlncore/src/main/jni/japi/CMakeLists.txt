# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)
add_library( luajapi SHARED
            m_utf.c
            stack.c
            list.c
            map.c
            statistics.c
            statistics_require.c
            m_mem.c
            saes.c
            utils.c
            jlog.c
            debug_info.c
            jinfo.c
            assets_reader.c
            cache.c
            jfunction.c
            jbridge.c
            jtable.c
            juserdata.c
            compiler.c
            message_looper.c
            isolate.c
            argo/LuaRPC.c
            argo/databindengine.c
            argo/argo_lib.c
            luajapi.c )

add_definitions(-DLUA_DL_DLOPEN -DLUA_USE_C89 -DLUA_COMPAT_5_1 -DLUA_COMPAT_ALL -DLUA_USE_LINUX -DJAVA_ENV -DP_ANDROID -DJAVA_CACHE_UD)
add_definitions(-DJ_API_INFO)
#add_definitions(-DMEM_INFO)
#add_definitions(-DMULTI_THREAD)
add_definitions(-DSTATISTIC_PERFORMANCE)

set(LINKER_DIR ${CMAKE_SOURCE_DIR}/linker/${ANDROID_ABI})

#------------------android log link---------------------
find_library( log-lib log )
find_library( android-lib android)

target_link_libraries( luajapi ${log-lib} ${android-lib} mlsocket lua)
