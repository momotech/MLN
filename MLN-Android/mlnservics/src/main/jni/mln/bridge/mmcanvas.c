//
// Created by Generator on 2020-02-13
//

#include <jni.h>
#include "lauxlib.h"
#include "../juserdata.h"
#include "../jinfo.h"
#include "../juserdata.h"
#include "../m_mem.h"

#define PRE JNIEnv *env;                                            \
            getEnv(&env);                                           \
            UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);  \
            jobject jobj = getUserdata(env, L, ud);                 \
            if (!jobj) {                                            \
                lua_pushfstring(L, "get java object from java failed, id: %d", ud->id); \
                lua_error(L);                                       \
                return 1;                                           \
            }

#define LUA_CLASS_NAME "CCanvas"

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID saveID;
static int _save(lua_State *L);
static jmethodID restoreID;
static int _restore(lua_State *L);
static jmethodID restoreToCountID;
static int _restoreToCount(lua_State *L);
static jmethodID translateID;
static int _translate(lua_State *L);
static jmethodID clipRectID;
static int _clipRect(lua_State *L);
static jmethodID clipPathID;
static int _clipPath(lua_State *L);
static jmethodID drawColorID;
static int _drawColor(lua_State *L);
static jmethodID drawRectID;
static int _drawRect(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L) {
    static const luaL_Reg _methohds[] = {
            {"save", _save},
            {"restore", _restore},
            {"restoreToCount", _restoreToCount},
            {"translate", _translate},
            {"clipRect", _clipRect},
            {"clipPath", _clipPath},
            {"drawColor", _drawColor},
            {"drawRect", _drawRect},
            {NULL, NULL}
    };
    const luaL_Reg *lib = _methohds;
    for (; lib->func; lib++) {
        lua_pushstring(L, lib->name);
        lua_pushcfunction(L, lib->func);
        lua_rawset(L, -3);
    }
}
//<editor-fold desc="JNI methods">
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL Java_com_immomo_mls_fun_ud_UDCCanvas__1init
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    saveID = (*env)->GetMethodID(env, clz, "save", "()I");
    restoreID = (*env)->GetMethodID(env, clz, "restore", "()V");
    restoreToCountID = (*env)->GetMethodID(env, clz, "restoreToCount", "(I)V");
    translateID = (*env)->GetMethodID(env, clz, "translate", "(DD)V");
    clipRectID = (*env)->GetMethodID(env, clz, "clipRect", "(DDDD)V");
    clipPathID = (*env)->GetMethodID(env, clz, "clipPath", "(Lcom/immomo/mls/fun/ud/UDPath;)V");
    drawColorID = (*env)->GetMethodID(env, clz, "drawColor", "(I)V");
    drawRectID = (*env)->GetMethodID(env, clz, "drawRect", "(DDDDLcom/immomo/mls/fun/ud/UDPaint;)V");
}
/**
 * java层需要将此ud注册到虚拟机里
 * @param l 虚拟机
 */
JNIEXPORT void JNICALL Java_com_immomo_mls_fun_ud_UDCCanvas__1register
        (JNIEnv *env, jclass o, jlong l) {
    lua_State *L = (lua_State *)l;

    char *metaname = getUDMetaname(LUA_CLASS_NAME);
    luaL_newmetatable(L, metaname);
    SET_METATABLE(L);
    /// -1: metatable
    fillUDMetatable(L);

    jclass clz = _globalClass;

    /// 设置gc方法
    pushUserdataGcClosure(env, L, clz);
    /// 设置需要返回bool的方法，比如__eq
    pushUserdataBoolClosure(env, L, clz);
    /// 设置__tostring
    pushUserdataTostringClosure(env, L, clz);
    lua_pop(L, 1);

    pushConstructorMethod(L, clz, getConstructor(env, clz), metaname);
    lua_setglobal(L, LUA_CLASS_NAME);

#if defined(J_API_INFO)
    m_malloc(metaname, (strlen(metaname) + 1) * sizeof(char), 0);
#else
    free(metaname);
#endif
}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * int save()
 */
static int _save(lua_State *L) {
    PRE
    jint ret = (*env)->CallIntMethod(env, jobj, saveID);
    lua_pushinteger(L, (lua_Integer) ret);
    return 1;
}
/**
 * void restore()
 */
static int _restore(lua_State *L) {
    PRE
    (*env)->CallVoidMethod(env, jobj, restoreID);
    lua_settop(L, 1);
    return 1;
}
/**
 * void restoreToCount(int)
 */
static int _restoreToCount(lua_State *L) {
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, restoreToCountID, (jint)p1);
    lua_settop(L, 1);
    return 1;
}
/**
 * void translate(double,double)
 */
static int _translate(lua_State *L) {
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    (*env)->CallVoidMethod(env, jobj, translateID, (jdouble)p1, (jdouble)p2);
    lua_settop(L, 1);
    return 1;
}
/**
 * void clipRect(double,double,double,double)
 */
static int _clipRect(lua_State *L) {
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    lua_Number p3 = luaL_checknumber(L, 4);
    lua_Number p4 = luaL_checknumber(L, 5);
    (*env)->CallVoidMethod(env, jobj, clipRectID, (jdouble)p1, (jdouble)p2, (jdouble)p3, (jdouble)p4);
    lua_settop(L, 1);
    return 1;
}
/**
 * void clipPath(com.immomo.mls.fun.ud.UDPath)
 */
static int _clipPath(lua_State *L) {
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, clipPathID, p1);
    lua_settop(L, 1);
    return 1;
}
/**
 * void drawColor(int)
 */
static int _drawColor(lua_State *L) {
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, drawColorID, (jint)p1);
    lua_settop(L, 1);
    return 1;
}
/**
 * void drawRect(double,double,double,double,com.immomo.mls.fun.ud.UDPaint)
 */
static int _drawRect(lua_State *L) {
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    lua_Number p3 = luaL_checknumber(L, 4);
    lua_Number p4 = luaL_checknumber(L, 5);
    jobject p5 = lua_isnil(L, 6) ? NULL : toJavaValue(env, L, 6);
    (*env)->CallVoidMethod(env, jobj, drawRectID, (jdouble)p1, (jdouble)p2, (jdouble)p3, (jdouble)p4, p5);
    lua_settop(L, 1);
    return 1;
}
//</editor-fold>
