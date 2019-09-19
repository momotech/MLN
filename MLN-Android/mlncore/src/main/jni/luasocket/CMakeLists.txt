# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)
add_library( mlsocket STATIC
            luasocket.c
            buffer.c
            auxiliar.c
            options.c
            timeout.c
            io.c
            usocket.c
            compat.c
            except.c
            inet.c
            mime.c
            select.c
            serial.c
            tcp.c
            udp.c )

add_definitions(-DLUA_DL_DLOPEN -DLUA_USE_C89 -DLUA_COMPAT_5_1 -DLUA_COMPAT_5_2 -DLUA_USE_LINUX -DANDROID -DLUA_COMPAT_ALL)
#add_definitions(-DMULTI_THREAD)
