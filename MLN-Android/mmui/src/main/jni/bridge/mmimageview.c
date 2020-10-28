/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by Generator on 2020-10-16
//

#include <jni.h>
#include "lauxlib.h"
#include "cache.h"
#include "statistics.h"
#include "jinfo.h"
#include "jtable.h"
#include "juserdata.h"
#include "m_mem.h"

#define PRE if (!lua_isuserdata(L, 1)) {                            \
        lua_pushstring(L, "use ':' instead of '.' to call method!!");\
        lua_error(L);                                               \
        return 1;                                                   \
    }                                                               \
            JNIEnv *env;                                            \
            getEnv(&env);                                           \
            UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);  \
            jobject jobj = getUserdata(env, L, ud);                 \
            if (!jobj) {                                            \
                lua_pushfstring(L, "get java object from java failed, id: %d", ud->id); \
                lua_error(L);                                       \
                return 1;                                           \
            }

#define REMOVE_TOP(L) while (lua_gettop(L) > 0 && lua_isnil(L, -1)) lua_pop(L, 1);

static inline void push_number(lua_State *L, jdouble num) {
    lua_Integer li1 = (lua_Integer) num;
    if (li1 == num) {
        lua_pushinteger(L, li1);
    } else {
        lua_pushnumber(L, num);
    }
}

static inline void push_string(JNIEnv *env, lua_State *L, jstring s) {
    const char *str = GetString(env, s);
    if (str)
        lua_pushstring(L, str);
    else
        lua_pushnil(L);
    ReleaseChar(env, s, str);
}

static inline void dumpParams(lua_State *L, int from) {
    const int SIZE = 100;
    const int MAX = SIZE - 4;
    char type[SIZE] = {0};
    int top = lua_gettop(L);
    int i;
    int idx = 0;
    for (i = from; i <= top; ++i) {
        const char *n = lua_typename(L, lua_type(L, i));
        size_t len = strlen(n);
        if (len + idx >= MAX) {
            memcpy(type + idx, "...", 3);
            break;
        }
        if (i != from) {
            type[idx ++] = ',';
        }
        memcpy(type + idx, n, len);
        idx += len;
    }
    lua_pushstring(L, type);
}
#ifdef STATISTIC_PERFORMANCE
#include <time.h>
#define _get_milli_second(t) ((t)->tv_sec*1000.0 + (t)->tv_usec / 1000.0)
#endif
#define LUA_CLASS_NAME "ImageView"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
//<editor-fold desc="method definition">
static jmethodID setImageID;
static jmethodID getImageID;
static int _image(lua_State *L);
static jmethodID getContentModeID;
static jmethodID setContentModeID;
static int _contentMode(lua_State *L);
static jmethodID isLazyLoadID;
static jmethodID setLazyLoadID;
static int _lazyLoad(lua_State *L);
static jmethodID setImageUrlID;
static int _setImageUrl(lua_State *L);
static jmethodID setImageWithCallbackID;
static int _setImageWithCallback(lua_State *L);
static jmethodID blurImageID;
static int _blurImage(lua_State *L);
static jmethodID setCornerImage0ID;
static jmethodID setCornerImage1ID;
static int _setCornerImage(lua_State *L);
static jmethodID startAnimationImagesID;
static int _startAnimationImages(lua_State *L);
static jmethodID stopAnimationImagesID;
static int _stopAnimationImages(lua_State *L);
static jmethodID isAnimatingID;
static int _isAnimating(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"image", _image},
            {"contentMode", _contentMode},
            {"lazyLoad", _lazyLoad},
            {"setImageUrl", _setImageUrl},
            {"setImageWithCallback", _setImageWithCallback},
            {"blurImage", _blurImage},
            {"setCornerImage", _setCornerImage},
            {"startAnimationImages", _startAnimationImages},
            {"stopAnimationImages", _stopAnimationImages},
            {"isAnimating", _isAnimating},
            {NULL, NULL}
    };
    const luaL_Reg *lib = _methohds;
    for (; lib->func; lib++) {
        lua_pushstring(L, lib->name);
        lua_pushcfunction(L, lib->func);
        lua_rawset(L, -3);
    }

    if (parentMeta) {
        JNIEnv *env;
        getEnv(&env);
        setParentMetatable(env, L, parentMeta);
    }
}

static int _execute_new_ud(lua_State *L);
static int _new_java_obj(JNIEnv *env, lua_State *L);
//<editor-fold desc="JNI methods">
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_UDImageView_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    setImageID = (*env)->GetMethodID(env, clz, "setImage", "(Ljava/lang/String;)V");
    getImageID = (*env)->GetMethodID(env, clz, "getImage", "()Ljava/lang/String;");
    getContentModeID = (*env)->GetMethodID(env, clz, "getContentMode", "()I");
    setContentModeID = (*env)->GetMethodID(env, clz, "setContentMode", "(I)V");
    isLazyLoadID = (*env)->GetMethodID(env, clz, "isLazyLoad", "()Z");
    setLazyLoadID = (*env)->GetMethodID(env, clz, "setLazyLoad", "(Z)V");
    setImageUrlID = (*env)->GetMethodID(env, clz, "setImageUrl", "(Ljava/lang/String;Ljava/lang/String;)V");
    setImageWithCallbackID = (*env)->GetMethodID(env, clz, "setImageWithCallback", "(Ljava/lang/String;Ljava/lang/String;Lorg/luaj/vm2/LuaFunction;)V");
    blurImageID = (*env)->GetMethodID(env, clz, "blurImage", "(F)V");
    setCornerImage0ID = (*env)->GetMethodID(env, clz, "setCornerImage", "(Ljava/lang/String;Ljava/lang/String;FI)V");
    setCornerImage1ID = (*env)->GetMethodID(env, clz, "setCornerImage", "(Ljava/lang/String;Ljava/lang/String;F)V");
    startAnimationImagesID = (*env)->GetMethodID(env, clz, "startAnimationImages", "(Lorg/luaj/vm2/LuaValue;FZ)V");
    stopAnimationImagesID = (*env)->GetMethodID(env, clz, "stopAnimationImages", "()V");
    isAnimatingID = (*env)->GetMethodID(env, clz, "isAnimating", "()Z");
}
/**
 * java层需要将此ud注册到虚拟机里
 * @param l 虚拟机
 * @param parent 父类，可为空
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1register)
        (JNIEnv *env, jclass o, jlong l, jstring parent) {
    lua_State *L = (lua_State *)l;

    u_newmetatable(L, META_NAME);
    /// get metatable.__index
    lua_pushstring(L, LUA_INDEX);
    lua_rawget(L, -2);
    /// 未初始化过，创建并设置metatable.__index
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_pushvalue(L, -1);
        lua_pushstring(L, LUA_INDEX);
        lua_pushvalue(L, -2);
        /// -1:nt -2:__index -3:nt -4:mt
        /// mt.__index=nt
        lua_rawset(L, -4);
    }
    /// -1:nt -2: metatable
    const char *luaParent = GetString(env, parent);
    if (luaParent) {
        char *parentMeta = getUDMetaname(luaParent);
        fillUDMetatable(L, parentMeta);
#if defined(J_API_INFO)
        m_malloc(parentMeta, (strlen(parentMeta) + 1) * sizeof(char), 0);
#else
        free(parentMeta);
#endif
        ReleaseChar(env, parent, luaParent);
    } else {
        fillUDMetatable(L, NULL);
    }

    jclass clz = _globalClass;

    /// 设置gc方法
    pushUserdataGcClosure(env, L, clz);
    /// 设置需要返回bool的方法，比如__eq
    pushUserdataBoolClosure(env, L, clz);
    /// 设置__tostring
    pushUserdataTostringClosure(env, L, clz);
    lua_pop(L, 2);

    lua_pushcfunction(L, _execute_new_ud);
    lua_setglobal(L, LUA_CLASS_NAME);
}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * java.lang.String getImage()
 * void setImage(java.lang.String)
 */
static int _image(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jstring ret = (*env)->CallObjectMethod(env, jobj, getImageID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getImage")) {
            return lua_error(L);
        }
        pushJavaString(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getImage", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallVoidMethod(env, jobj, setImageID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setImage")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setImage", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getContentMode()
 * void setContentMode(int)
 */
static int _contentMode(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getContentModeID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getContentMode")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getContentMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setContentModeID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setContentMode")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setContentMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isLazyLoad()
 * void setLazyLoad(boolean)
 */
static int _lazyLoad(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isLazyLoadID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isLazyLoad")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isLazyLoad", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setLazyLoadID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setLazyLoad")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setLazyLoad", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setImageUrl(java.lang.String,java.lang.String)
 */
static int _setImageUrl(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jstring p2 = lua_isnil(L, 3) ? NULL : newJString(env, lua_tostring(L, 3));
    (*env)->CallVoidMethod(env, jobj, setImageUrlID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setImageUrl")) {
        FREE(env, p1);
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setImageUrl", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setImageWithCallback(java.lang.String,java.lang.String,org.luaj.vm2.LuaFunction)
 */
static int _setImageWithCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jstring p2 = lua_isnil(L, 3) ? NULL : newJString(env, lua_tostring(L, 3));
    jobject p3 = lua_isnil(L, 4) ? NULL : toJavaValue(env, L, 4);
    (*env)->CallVoidMethod(env, jobj, setImageWithCallbackID, p1, p2, p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setImageWithCallback")) {
        FREE(env, p1);
        FREE(env, p2);
        FREE(env, p3);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    FREE(env, p3);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setImageWithCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void blurImage(float)
 */
static int _blurImage(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, blurImageID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".blurImage")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "blurImage", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setCornerImage(java.lang.String,java.lang.String,float,int)
 * void setCornerImage(java.lang.String,java.lang.String,float)
 */
static int _setCornerImage(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 5) {
        if (lua_type(L, 2) == LUA_TSTRING&&lua_type(L, 3) == LUA_TSTRING&&lua_type(L, 4) == LUA_TNUMBER&&lua_type(L, 5) == LUA_TNUMBER) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            jstring p2 = newJString(env, lua_tostring(L, 3));
            lua_Number p3 = luaL_checknumber(L, 4);
            lua_Integer p4 = luaL_checkinteger(L, 5);
            (*env)->CallVoidMethod(env, jobj, setCornerImage0ID, p1, p2, (jfloat)p3, (jint)p4);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".setCornerImage")) {
                FREE(env, p1);
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p1);
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setCornerImage", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".setCornerImage函数4个参数有: (String,String,float,int)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TSTRING&&lua_type(L, 3) == LUA_TSTRING&&lua_type(L, 4) == LUA_TNUMBER) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            jstring p2 = newJString(env, lua_tostring(L, 3));
            lua_Number p3 = luaL_checknumber(L, 4);
            (*env)->CallVoidMethod(env, jobj, setCornerImage1ID, p1, p2, (jfloat)p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".setCornerImage")) {
                FREE(env, p1);
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p1);
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setCornerImage", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".setCornerImage函数3个参数有: (String,String,float)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void startAnimationImages(org.luaj.vm2.LuaValue,float,boolean)
 */
static int _startAnimationImages(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    int p3 = lua_toboolean(L, 4);
    (*env)->CallVoidMethod(env, jobj, startAnimationImagesID, p1, (jfloat)p2, (jboolean)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".startAnimationImages")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "startAnimationImages", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void stopAnimationImages()
 */
static int _stopAnimationImages(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, stopAnimationImagesID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".stopAnimationImages")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "stopAnimationImages", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isAnimating()
 */
static int _isAnimating(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jboolean ret = (*env)->CallBooleanMethod(env, jobj, isAnimatingID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".isAnimating")) {
        return lua_error(L);
    }
    lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isAnimating", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>

static int _execute_new_ud(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif

    JNIEnv *env;
    int need = getEnv(&env);

    if (_new_java_obj(env, L)) {
        if (need) detachEnv();
        lua_error(L);
        return 1;
    }

    luaL_getmetatable(L, META_NAME);
    lua_setmetatable(L, -2);

    if (need) detachEnv();

#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    double offset = _get_milli_second(&end) - _get_milli_second(&start);
    userdataMethodCall(LUA_CLASS_NAME, InitMethodName, offset);
#endif

    return 1;
}
static int _new_java_obj(JNIEnv *env, lua_State *L) {
    jobject javaObj = NULL;
    javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L);

    char *info = joinstr(LUA_CLASS_NAME, InitMethodName);

    if (catchJavaException(env, L, info)) {
        if (info)
            m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);
        FREE(env, javaObj);
        return 1;
    }
    if (info)
        m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);

    UDjavaobject ud = (UDjavaobject) lua_newuserdata(L, sizeof(javaUserdata));
    ud->id = getUserdataId(env, javaObj);
    if (isStrongUserdata(env, _globalClass)) {
        setUDFlag(ud, JUD_FLAG_STRONG);
        copyUDToGNV(env, L, ud, -1, javaObj);
    }
    FREE(env, javaObj);
    ud->refCount = 0;

    ud->name = lua_pushstring(L, META_NAME);
    lua_pop(L, 1);
    return 0;
}