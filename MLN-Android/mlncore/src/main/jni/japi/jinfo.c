/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/03/13.
//

#include "jinfo.h"
#include "lauxlib.h"
#include "mlog.h"
#include "cache.h"
#include "llimits.h"
#include <string.h>
#include "m_utf.h"
#include "m_mem.h"

static jboolean init = 0;
JavaVM *g_jvm;
// ------------global ref
jclass StringClass = NULL;
jclass LuaValue = NULL;
jclass Globals = NULL;
jclass LuaNumber = NULL;
jclass LuaString = NULL;
jclass LuaTable = NULL;
jclass LuaFunction = NULL;
jclass LuaUserdata = NULL;
jclass LuaThread = NULL;
jclass JavaUserdata = NULL;
jclass InvokeError = NULL;
jclass RuntimeException = NULL;
jclass Throwable = NULL;
// ------------single instance
jobject Lua_TRUE = NULL;
jobject Lua_FALSE = NULL;
jobject Lua_NIL = NULL;
jobjectArray Lua_EMPTY = NULL;

// ------------globals
jmethodID Globals__onLuaRequire = NULL;
jmethodID Globals__getRequireError = NULL;
jmethodID Globals__onLuaGC = NULL;
jmethodID Globals__onNativeCreateGlobals = NULL;
jmethodID Globals__onGlobalsDestroyInNative = NULL;
jmethodID Globals__postCallback = NULL;
jmethodID Globals__onEmptyMethodCall = NULL;
// ------------value
jmethodID LuaValue_type = NULL;
jfieldID LuaValue_nativeGlobalKey = NULL;
// ------------number
jmethodID LuaNumber_I = NULL;
jmethodID LuaNumber_D = NULL;
jfieldID LuaNumber_value = NULL;
// ------------boolean
jfieldID LuaBoolean_value = NULL;
// ------------string
jmethodID LuaString_C = NULL;
jfieldID LuaString_value = NULL;
// ------------table
jmethodID LuaTable_C = NULL;
// ------------function
jmethodID LuaFunction_C = NULL;
// ------------thread
jmethodID LuaThread_C = NULL;
// ------------userdata
jfieldID LuaUserdata_luaclassName = NULL;
jmethodID LuaUserdata_memoryCast = NULL;
// ------------exception
// jmethodID InvokeError_C = NULL;
// jmethodID InvokeError_CT = NULL;
jmethodID obj__toString = NULL;
jmethodID Throwable_getStackTrace = NULL;
jmethodID Globals__getUserdata = NULL;
jfieldID LuaUserdata_id = NULL;
jmethodID LuaUserdata_addRef = NULL;

jclass Entrys = NULL;
jmethodID Entrys_C = NULL;

char **emtpyMethods = NULL;

void initJavaInfo(JNIEnv *env) {
    if (init) {
        return;
    }

    StringClass = GLOBAL(env, (*env)->FindClass(env, "java/lang/String"));
    Throwable = GLOBAL(env, (*env)->FindClass(env, "java/lang/Throwable"));
    jclass OBJECT = (*env)->FindClass(env, "java/lang/Object");
    obj__toString = (*env)->GetMethodID(env, OBJECT, "toString", "()" STRING_CLASS);
    Throwable_getStackTrace = (*env)->GetMethodID(env, Throwable, "getStackTrace", "()[Ljava/lang/StackTraceElement;");
    if ((*env)->ExceptionCheck(env))
        (*env)->ExceptionClear(env);

    Globals = GLOBAL(env, findTypeClass(env, "Globals"));
    Globals__onLuaRequire = (*env)->GetStaticMethodID(env, Globals, "__onLuaRequire",
                                                      "(J" STRING_CLASS ")" OBJECT_CLASS);
    Globals__getRequireError = (*env)->GetStaticMethodID(env, Globals, "__getRequireError", "(J)" STRING_CLASS);
    Globals__onLuaGC = (*env)->GetStaticMethodID(env, Globals, "__onLuaGC", "(J)V");
    Globals__onNativeCreateGlobals = (*env)->GetStaticMethodID(env, Globals,
                                                               "__onNativeCreateGlobals", "(JJZ)V");
    Globals__onGlobalsDestroyInNative = (*env)->GetStaticMethodID(env, Globals,
                                                                  "__onGlobalsDestroyInNative",
                                                                  "(J)V");
    Globals__postCallback = (*env)->GetStaticMethodID(env, Globals, "__postCallback", "(JJJ)I");
    Globals__onEmptyMethodCall = (*env)->GetStaticMethodID(env, Globals, "__onEmptyMethodCall", "(J" STRING_CLASS STRING_CLASS ")V");
    Globals__getUserdata = (*env)->GetStaticMethodID(env, Globals, "__getUserdata", "(JJ)" OBJECT_CLASS);

    LuaValue = GLOBAL(env, findTypeClass(env, "LuaValue"));
    LuaValue_type = (*env)->GetMethodID(env, LuaValue, "type", "()I");
    LuaValue_nativeGlobalKey = (*env)->GetFieldID(env, LuaValue, "nativeGlobalKey", "J");

    LuaNumber = GLOBAL(env, findTypeClass(env, "LuaNumber"));
    LuaNumber_I = (*env)->GetStaticMethodID(env, LuaNumber, JAVA_VALUE_OF,
                                            "(I)L" JAVA_PATH "LuaNumber;");
    LuaNumber_D = findConstructor(env, LuaNumber, "D");
    LuaNumber_value = (*env)->GetFieldID(env, LuaNumber, "value", "D");

    jclass lb = findTypeClass(env, "LuaBoolean");
    LuaBoolean_value = (*env)->GetFieldID(env, lb, "value", "Z");

    LuaString = GLOBAL(env, findTypeClass(env, "LuaString"));
    LuaString_C = findConstructor(env, LuaString, STRING_CLASS);
    LuaString_value = (*env)->GetFieldID(env, LuaString, "value", STRING_CLASS);

    LuaTable = GLOBAL(env, findTypeClass(env, "LuaTable"));
    LuaTable_C = findConstructor(env, LuaTable, "JJ");

    LuaFunction = GLOBAL(env, findTypeClass(env, "LuaFunction"));
    LuaFunction_C = findConstructor(env, LuaFunction, "JJ");

    LuaUserdata = GLOBAL(env, findTypeClass(env, "LuaUserdata"));
    LuaUserdata_luaclassName = (*env)->GetFieldID(env, LuaUserdata, "luaclassName", STRING_CLASS);
    LuaUserdata_memoryCast = (*env)->GetMethodID(env, LuaUserdata, "memoryCast", "()J");
    LuaUserdata_id = (*env)->GetFieldID(env, LuaUserdata, "id", "J");
    LuaUserdata_addRef = (*env)->GetMethodID(env, LuaUserdata, "addRef", "()V");
    JavaUserdata = GLOBAL(env, findTypeClass(env, "JavaUserdata"));

    LuaThread = GLOBAL(env, findTypeClass(env, "LuaThread"));
    LuaThread_C = findConstructor(env, LuaThread, "JJ");

    jclass LuaBoolean = findTypeClass(env, "LuaBoolean");
    jmethodID LuaBoolean_TRUE = (*env)->GetStaticMethodID(env, LuaBoolean, "TRUE",
                                                          "()L" JAVA_PATH "LuaBoolean;");
    jmethodID LuaBoolean_FALSE = (*env)->GetStaticMethodID(env, LuaBoolean, "FALSE",
                                                           "()L" JAVA_PATH "LuaBoolean;");
    Lua_TRUE = GLOBAL(env, (*env)->CallStaticObjectMethod(env, LuaBoolean, LuaBoolean_TRUE));
    Lua_FALSE = GLOBAL(env, (*env)->CallStaticObjectMethod(env, LuaBoolean, LuaBoolean_FALSE));

    jclass LuaNil = findTypeClass(env, "LuaNil");
    jmethodID LuaNil_NIL = (*env)->GetStaticMethodID(env, LuaNil, "NIL", "()L" JAVA_PATH "LuaNil;");
    Lua_NIL = GLOBAL(env, (*env)->CallStaticObjectMethod(env, LuaNil, LuaNil_NIL));
    jmethodID LuaEmptyMID = (*env)->GetStaticMethodID(env, LuaValue, "empty",
                                                      "()[L" JAVA_PATH "LuaValue;");
    Lua_EMPTY = GLOBAL(env, (*env)->CallStaticObjectMethod(env, LuaValue, LuaEmptyMID));

    Entrys = GLOBAL(env, findTypeClass(env, "LuaTable$Entrys"));
    Entrys_C = findConstructor(env, Entrys, "["
            LUAVALUE_CLASS
            "["
            LUAVALUE_CLASS);
    init = 1;
}

extern int AndroidVersion;

jstring newJString(JNIEnv *env, const char *s) {
    if (AndroidVersion >= USE_NDK_NEWSTRING_VERSION) {
        return (*env)->NewStringUTF(env, s);
    }
    size_t len = strlen(s);
    jchar *jcs = (jchar *) malloc(sizeof(jchar) * (len));
    memset(jcs, 0, sizeof(jchar) * (len));
    len = ConvertModifiedUtf8ToUtf16(jcs, s, len);
    jstring ret = (*env)->NewString(env, jcs, (jsize) len);
    free(jcs);
    return ret;
}

jobject newLuaNumber(JNIEnv *env, jdouble num) {
    if (num == ((jint) num)) {
        return (*env)->CallStaticObjectMethod(env, LuaNumber, LuaNumber_I, (jint) num);
    }
    return (*env)->NewObject(env, LuaNumber, LuaNumber_D, num);
}

jobject newLuaString(JNIEnv *env, const char *s) {
    jstring str = newJString(env, s);
    jobject ret = (*env)->NewObject(env, LuaString, LuaString_C, str);
    FREE(env, str);
    return ret;
}

jobject newLuaTable(JNIEnv *env, lua_State *L, int idx) {
    lua_lock(L);
    ptrdiff_t key = copyValueToGNV(L, idx);
    jobject ret = (*env)->NewObject(env, LuaTable, LuaTable_C, (jlong) L, key);
    lua_unlock(L);
    return ret;
}

jobject newLuaFunction(JNIEnv *env, lua_State *L, int idx) {
    lua_lock(L);
    ptrdiff_t key = copyValueToGNV(L, idx);
    jobject ret = (*env)->NewObject(env, LuaFunction, LuaFunction_C, (jlong) L, key);
    lua_unlock(L);
    return ret;
}

void copyUDToGNV(JNIEnv *env, lua_State *L, UDjavaobject ud, int idx, jobject jobj) {
    ptrdiff_t key = copyValueToGNV(L, idx);
    if (!jobj) {
        jobj = getUserdata(env, L, ud);
    }
    (*env)->SetLongField(env, jobj, LuaValue_nativeGlobalKey, (jlong) key);
    setUDFlag(ud, JUD_FLAG_SKEY);
}

jobject newLuaUserdata(JNIEnv *env, lua_State *L, int idx, UDjavaobject ud) {
    if (isJavaUserdata(ud)) {
        if (udHasFlag(ud, JUD_FLAG_STRONG) && !udHasFlag(ud, JUD_FLAG_SKEY)) {
            lua_lock(L);
            copyUDToGNV(env, L, ud, idx, NULL);
            lua_unlock(L);
        }
        ud->refCount++;
        return getUserdata(env, L, ud);
    }
    /// 非java定义的userdata
    return NULL;
}

jlong getUserdataId(JNIEnv *env, jobject ud) {
    return (*env)->GetLongField(env, ud, LuaUserdata_id);
}

void addUserdataRefCount(JNIEnv *env, jobject ud) {
    (*env)->CallVoidMethod(env, ud, LuaUserdata_addRef);
}

jobject getUserdata(JNIEnv *env, lua_State *L, UDjavaobject ud) {
    return (*env)->CallStaticObjectMethod(env, Globals, Globals__getUserdata, (jlong) L, ud->id);
}

jobject newLuaThread(JNIEnv *env, lua_State *L, int idx) {
    return NULL;
}

jobject toJavaValue(JNIEnv *env, lua_State *L, int idx) {
    jobject result = NULL;
    lua_lock(L);
    switch (lua_type(L, idx)) {
        case LUA_TNUMBER:
            result = newLuaNumber(env, (double) lua_tonumber(L, idx));
            break;
        case LUA_TBOOLEAN:
            result = lua_toboolean(L, idx) ? Lua_TRUE : Lua_FALSE;
            break;
        case LUA_TSTRING:
            result = newLuaString(env, lua_tostring(L, idx));
            break;
        case LUA_TTABLE:
            result = newLuaTable(env, L, idx);
            break;
        case LUA_TFUNCTION:
            result = newLuaFunction(env, L, idx);
            break;
        case LUA_TUSERDATA:
        case LUA_TLIGHTUSERDATA:
            result = newLuaUserdata(env, L, idx, (UDjavaobject) lua_touserdata(L, idx));
            break;
        case LUA_TTHREAD:
            result = newLuaThread(env, L, idx);
            break;
        default:
            result = Lua_NIL;
            break;
    }
    lua_unlock(L);
    return result;
}

jobjectArray newLuaValueArrayFromStack(JNIEnv *env, lua_State *L, int count, int stackoffset) {
    lua_lock(L);
    count = count < 0 ? 0 : count;
    if (count == 0) return Lua_EMPTY;
    jobjectArray p = (*env)->NewObjectArray(env, count, LuaValue, NULL);
    int i;
    for (i = 0; i < count; i++) {
        jobject v = toJavaValue(env, L, i + stackoffset);
        (*env)->SetObjectArrayElement(env, p, (jsize) i, v);
        FREE(env, v);
    }
    lua_unlock(L);
    return p;
}

void pushUserdataFromJUD(JNIEnv *env, lua_State *L, jobject obj) {
    lua_lock(L);
    jstring lcn = (jstring) (*env)->GetObjectField(env, obj, LuaUserdata_luaclassName);
    const char *luaclassname = GetString(env, lcn);

    UDjavaobject ud = (UDjavaobject) lua_newuserdata(L, sizeof(javaUserdata));
    ud->flag = 0;
    addUserdataRefCount(env, obj);
    ud->id = getUserdataId(env, obj);
    const char *udname = lua_pushfstring(L, METATABLE_FORMAT, luaclassname);
    ReleaseChar(env, lcn, luaclassname);
    FREE(env, lcn);
    lua_pop(L, 1);
    ud->name = udname;

    luaL_getmetatable(L, udname);
    if (lua_istable(L, -1)) {
        lua_setmetatable(L, -2);
    } else {
        luaL_error(L, "error push userdata, metatable for %s is not a table.", udname);
    }
    lua_unlock(L);
}

void pushJavaUserdata(JNIEnv *env, lua_State *L, jobject ud) {
    jlong key = (*env)->GetLongField(env, ud, LuaValue_nativeGlobalKey);
    /// see LuaUserdata#newUserdata 由java创建的userdata，idx为LUA_REGISTRYINDEX
    if (isGlobal(key))
        pushUserdataFromJUD(env, L, ud);
    else
        getValueFromGNV(L, (ptrdiff_t) key, LUA_TUSERDATA);
}

void pushJavaValue(JNIEnv *env, lua_State *L, jobject obj) {
    lua_lock(L);
    if (!obj) {
        lua_pushnil(L);
        lua_unlock(L);
        return;
    }
    int type = (int) (*env)->CallIntMethod(env, obj, LuaValue_type);
    double num;
    jstring string;
    const char *str;
    jlong key;
    switch (type) {
        case LUA_TNUMBER:
            num = (double) (*env)->GetDoubleField(env, obj, LuaNumber_value);
            if (num == (int) num)
                lua_pushinteger(L, (lua_Integer) num);
            else
                lua_pushnumber(L, (lua_Number) num);
            break;
        case LUA_TNIL:
            lua_pushnil(L);
            break;
        case LUA_TBOOLEAN:
            lua_pushboolean(L, (*env)->GetBooleanField(env, obj, LuaBoolean_value));
            break;
        case LUA_TSTRING:
            string = (jstring) (*env)->GetObjectField(env, obj, LuaString_value);
            str = GetString(env, string);
            lua_pushstring(L, str);
            ReleaseChar(env, string, str);
            FREE(env, string);
            break;
        case LUA_TUSERDATA:
            pushJavaUserdata(env, L, obj);
            break;
        default:
            key = (*env)->GetLongField(env, obj, LuaValue_nativeGlobalKey);
            getValueFromGNV(L, (ptrdiff_t) key, type);
            break;
    }
    lua_unlock(L);
}

void pushJavaString(JNIEnv *env, lua_State *L, jstring obj) {
    if (!obj) {
        lua_pushnil(L);
        return;
    }
    const char *str = GetString(env, obj);
    lua_pushstring(L, str);
    ReleaseChar(env, obj, str);
}

int pushJavaArray(JNIEnv *env, lua_State *L, jobjectArray arr) {
    lua_lock(L);
    int len = arr ? GetArrLen(env, arr) : 0;

    if (len == 0)
        return 0;
    int i;
    for (i = 0; i < len; i++) {
        jobject jo = (*env)->GetObjectArrayElement(env, arr, i);
        pushJavaValue(env, L, jo);
        FREE(env, jo);
    }
    lua_unlock(L);
    return len;
}

void throwInvokeError(JNIEnv *env, const char *errmsg) {
    ClearException(env);
    if (!InvokeError)
        InvokeError = GLOBAL(env, findTypeClass(env, "exception/InvokeError"));

    (*env)->ThrowNew(env, InvokeError, errmsg);
}

void throwRuntimeError(JNIEnv *env, const char *msg) {
    ClearException(env);
    if (!RuntimeException)
        RuntimeException = GLOBAL(env, (*env)->FindClass(env, "java/lang/RuntimeException"));

    (*env)->ThrowNew(env, RuntimeException, msg);
}

void callbackLuaGC(JNIEnv *env, lua_State *L) {
    (*env)->CallStaticVoidMethod(env, Globals, Globals__onLuaGC, (jlong) L);
    (*env)->ExceptionClear(env);
}

int postCallback(JNIEnv *env, lua_State *L, callback_method method, void *arg) {
    return (*env)->CallStaticIntMethod(env, Globals, Globals__postCallback, (jlong) L,
                                       (jlong) method, (jlong) arg);
}

int getEnv(JNIEnv **out) {
    int needDetach = 0;
    if ((*g_jvm)->GetEnv(g_jvm, (void **) out, JNI_VERSION_1_4) < 0 || !(*out)) {
        int r = (*g_jvm)->AttachCurrentThread(g_jvm, out, NULL);
        LOGI("attach env result: %d", r);
        needDetach = 1;
    }
    return needDetach;
}

void detachEnv() {
    int r = (*g_jvm)->DetachCurrentThread(g_jvm);
    LOGI("detach env result: %d", r);
}

size_t copy_string(JNIEnv *env, jstring src, char *out, size_t len) {
    const char *cs = GetString(env, src);
    if (!cs) return 0;
    size_t slen = (size_t) (*env)->GetStringUTFLength(env, src);

    size_t copy_len = slen >= len ? len - 1 : slen;
    memcpy(out, cs, copy_len);
    ReleaseChar(env, src, cs);
    (*env)->DeleteLocalRef(env, src);
    return copy_len;
}

int getThrowableMsg(JNIEnv *env, jthrowable t, char *out, size_t len) {
    if (!t) return -1;

    jstring ret = (jstring) (*env)->CallObjectMethod(env, t, obj__toString);
    if ((*env)->ExceptionCheck(env) || !ret) return -2;

    size_t copy_len = copy_string(env, ret, out, len);
    if (copy_len == 0)
        return -3;

    if (len - copy_len > EXCEPTION_STACK_LEN && Throwable_getStackTrace) {
        jobjectArray stacks = (*env)->CallObjectMethod(env, t,Throwable_getStackTrace);
        if ((*env)->ExceptionCheck(env) || !stacks) {
            return 0;
        }
        int stack_size = GetArrLen(env, stacks);
        if (stack_size <= 0) {
            (*env)->DeleteLocalRef(env, stacks);
            return 0;
        }
        jobject stack1 = (*env)->GetObjectArrayElement(env, stacks, 0);
        if ((*env)->ExceptionCheck(env) || !stack1) {
            (*env)->DeleteLocalRef(env, stacks);
            return 0;
        }
        ret = (jstring) (*env)->CallObjectMethod(env, stack1, obj__toString);
        if ((*env)->ExceptionCheck(env) || !ret) {
            (*env)->DeleteLocalRef(env, stack1);
            (*env)->DeleteLocalRef(env, stacks);
            return 0;
        }

        char *temp = out + copy_len;
        memcpy(temp, "\n", 1);
        temp += 1;
        copy_string(env, ret, temp, len - copy_len - 1);
        (*env)->DeleteLocalRef(env, stack1);
        (*env)->DeleteLocalRef(env, stacks);
    }
    return 0;
}

int isStrongUserdata(JNIEnv *env, jclass clz) {
    return (*env)->IsAssignableFrom(env, clz, JavaUserdata);
}

int catchJavaException(JNIEnv *env, lua_State *L, const char * mn) {
    jthrowable thr = (*env)->ExceptionOccurred(env);
    if (thr) {
        (*env)->ExceptionClear(env);
        char msg[MAX_EXCEPTION_MSG] = {0};
        if (!mn) mn = "unknown";
        if (getThrowableMsg(env, thr, msg, MAX_EXCEPTION_MSG) == 0) {
            lua_pushfstring(L, "exception throws in java (%s)---%s", mn, msg);
        } else {
            lua_pushfstring(L, "exception throws in java (%s)!", mn);
        }
        return 1;
    }
    return 0;
}

jclass getClassByName(JNIEnv *env, const char *name) {
    jclass clz = (jclass) cj_get(name);
    if (!clz) {
        clz = (*env)->FindClass(env, name);
        if (!clz) {
            char *errorstr = joinstr("cannot find class ", name);
            throwRuntimeError(env, errorstr);
            m_malloc(errorstr, (strlen(errorstr) + 1) * sizeof(char), 0);
            return NULL;
        }
        clz = GLOBAL(env, clz);
        cj_put(name, clz);
    }
    return clz;
}

jmethodID getConstructor(JNIEnv *env, jclass clz) {
    jmethodID id = (jmethodID) jc_get(clz);
    if (!id) {
        id = findConstructor(env, clz, "J["
                LUAVALUE_CLASS);
        (*env)->ExceptionClear(env);
        if (id) {
            jc_put(clz, id);
        } else {
            LOGE("constructor for class %p not found", clz);
        }
    }
    return id;
}

jmethodID getMethodByName(JNIEnv *env, jclass clz, const char *name) {
    jmethodID id = jm_get(clz, name);
    if (!id) {
        id = (*env)->GetMethodID(env, clz, name, DEFAULT_SIG);
        if (id)
            jm_put(clz, name, id);
    }
    return id;
}

#define S_DEFAULT_SIG "(J[" LUAVALUE_CLASS ")[" LUAVALUE_CLASS

jmethodID getStaticMethodByName(JNIEnv *env, jclass clz, const char *name) {
    jmethodID id = jm_get(clz, name);
    if (!id) {
        id = (*env)->GetStaticMethodID(env, clz, name, S_DEFAULT_SIG);
        if (id)
            jm_put(clz, name, id);
    }
    return id;
}

static const char *special_method_sigs[] = {
        "()" STRING_CLASS,
        "(" OBJECT_CLASS ")Z",
        "()V"
};

static jmethodID placeholder = (jmethodID) 1;

jmethodID getSpecialMethod(JNIEnv *env, jclass clz, int type) {
    if (type < METHOD_TOSTRING || type > METHOD_GC)
        return NULL;
    const char *name = special_methods[type];
    jmethodID id = jm_get(clz, name);
    if (!id) {
        id = (*env)->GetMethodID(env, clz, name, special_method_sigs[type]);
        if ((*env)->ExceptionCheck(env)) {
            (*env)->ExceptionClear(env);
            jm_put(clz, name, placeholder);
        } else {
            jm_put(clz, name, id);
        }
    } else if (id == placeholder) {
        id = NULL;
    }
    return id;
}

jmethodID getIndexStaticMethod(JNIEnv *env, jclass clz) {
    const char *name = "__index";
    jmethodID id = jm_get(clz, name);
    if (!id) {
        const char *sig = "(J" STRING_CLASS "[" LUAVALUE_CLASS ")[" LUAVALUE_CLASS;
        id = (*env)->GetStaticMethodID(env, clz, name, sig);
        if ((*env)->ExceptionCheck(env)) {
            return NULL;
        }
        jm_put(clz, name, id);
    }
    return id;
}

void traverseAllMethods(jclass clz, map_look_fun fun, void *ud) {
    jm_traverse_all_method(clz, fun, ud);
}

void jni_preRegisterUD(JNIEnv *env, jobject jobj, jstring className, jobjectArray methods) {
    const char *cname = GetString(env, className);
    jclass clz = getClassByName(env, cname);
    ReleaseChar(env, className, cname);
    if (!clz) {
        return;
    }

    if (!getConstructor(env, clz)) {
        return;
    }

    jsize len = (*env)->GetArrayLength(env, methods);
    jsize i = 0;
    jstring jname;
    const char *name;
    jmethodID id;
    for (i = 0; i < len; ++i) {
        jname = (jstring) (*env)->GetObjectArrayElement(env, methods, i);
        name = GetString(env, jname);
        id = getMethodByName(env, clz, name);
        if (!id) return;

        ReleaseChar(env, jname, name);
        FREE(env, jname);
    }

    for (i = METHOD_TOSTRING; i <= METHOD_GC; ++i) {
        getSpecialMethod(env, clz, i);
    }
}

void jni_preRegisterStatic(JNIEnv *env, jobject jobj, jstring className, jobjectArray methods) {
    const char *cname = GetString(env, className);
    jclass clz = getClassByName(env, cname);
    ReleaseChar(env, className, cname);
    if (!clz) {
        return;
    }

    jsize len = (*env)->GetArrayLength(env, methods);
    jsize i = 0;
    jstring jname;
    const char *name;
    jmethodID id;
    for (i = 0; i < len; ++i) {
        jname = (jstring) (*env)->GetObjectArrayElement(env, methods, i);
        name = GetString(env, jname);
        id = getStaticMethodByName(env, clz, name);
        if (!id) return;

        ReleaseChar(env, jname, name);
        FREE(env, jname);
    }
}

void jni_preRegisterEmptyMethods(JNIEnv *env, jobject jobj, jobjectArray methods) {
    /// 覆盖操作，先释放旧内存
    if (emtpyMethods) {
        int i = 0;
        char *s;
        while ((s = emtpyMethods[i++]) != NULL) {
            m_malloc(s, strlen(s) + 1, 0);
        }
        m_malloc(emtpyMethods, sizeof(char*) * i, 0);
    }
    int len = GetArrLen(env, methods);
    emtpyMethods = m_malloc(0, 0, (len + 1) * sizeof(char *));
    int i;
    jstring jname;
    const char *name;
    for (i = 0; i < len; ++i) {
        jname = (jstring) (*env)->GetObjectArrayElement(env, methods, i);
        name = GetString(env, jname);
        emtpyMethods[i] = copystr(name);
        ReleaseChar(env, jname, name);
        FREE(env, jname);
    }
    emtpyMethods[i] = 0;
}

int hasEmptyMethod() {
    return emtpyMethods != NULL;
}

/**
 * 遍历所有空函数
 */
void traverseAllEmptyMethods(traverse_empty fun, void *ud) {
    if (emtpyMethods) {
        char **temp = emtpyMethods;
        while (*temp) {
            fun(*temp, ud);
            temp++;
        }
    }
}

void onEmptyMethodCall(lua_State *L, const char *clz, const char *methodName) {
    JNIEnv *env;
    getEnv(&env);
    jstring jclz = newJString(env, clz);
    jstring jmn = newJString(env, methodName);
    (*env)->CallStaticVoidMethod(env, Globals, Globals__onEmptyMethodCall, (jlong) L, jclz, jmn);
}