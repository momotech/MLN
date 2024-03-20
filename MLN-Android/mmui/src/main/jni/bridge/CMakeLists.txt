# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html
# Sets the minimum version of CMake required to build the native library.
cmake_minimum_required(VERSION 3.4.1)
#设置头文件搜索路径（和此txt同个路径的头文件无需设置）
#INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../include/lua_include)
#INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../include)
link_directories(${LINK_LIBRARY_DIRECTORY})
add_library( mmuibridge SHARED
        mmui_vm_auto_fill.c
        #native bridge start
        mmview.c
        mmnodegroup.c
        mmspacer.c
        mmhstack.c
        mmvstack.c
        interactive_behavior.c
        mmdatabinding.c
        mmcolor.c
        mmstylestring.c
        mmlabel.c
        mmedittext.c
        mmwindow.c
        mmimageview.c
        mmimagebutton.c
        mmsafearea.c
        mmbaseanim.c
        mmanimset.c
        mmanimator.c
        mmrecyclerview.c
        mmbaserecycleradapter.c
        mmlistadapter.c
        mmcollectionadapter.c
        mmbaserecyclerlayout.c
        mmcollectionlayout.c
        mmwaterfalllayout.c
        mmwaterfalladapter.c
        mmscrollview.c
        mmpagelink.c
        mmpoint.c
        mmsize.c
        mmstringutil.c
        mmargoui.c
        interactive_behavior_callback.c
        mmrecycler_callback.c
        mmadapter_callback.c
        mmtouch_callback.c
        mmdatabind_callback.c
        #native bridge end
        )
add_definitions(-DLUA_DL_DLOPEN -DLUA_USE_C89 -DLUA_COMPAT_5_1 -DLUA_COMPAT_ALL -DLUA_USE_LINUX -DJAVA_ENV -DP_ANDROID)
add_definitions(-DSTATISTIC_PERFORMANCE)
add_definitions(-DJ_API_INFO)

find_library( log-lib log )
target_link_libraries( mmuibridge
        ${log-lib}
        luajapi)
