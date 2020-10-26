/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2020/8/24.
//

#include "compiler.h"
#include <errno.h>
#include <sys/stat.h>
#include <time.h>
#include "saes.h"
#include "lundump.h"
#include "m_mem.h"
#include "llimits.h"
#include "lauxlib.h"
#include "lualib.h"
#include "lobject.h"
#include "lstate.h"
#include "jinfo.h"
#include "cache.h"
#include "jfunction.h"
#include "jtable.h"
#include "statistics_require.h"
#ifdef ANDROID
#include "assets_reader.h"
#endif

/**
 * 是否开启文件加密，若开启，读lua文件判断是否是加密文件，写lua文件都加密
 *                若关闭，读写都不使用加密
 */
static int opensaes = 0;

#define FILE_NOT_FOUND -404
#define WRITE_FILE_ERROR -300
#define CLOSE_FILE_ERROR -301
#define BUFFER_SIZE 1024

extern jclass Globals;
extern jclass StringClass;
extern jmethodID Globals__onLuaRequire;
extern jmethodID Globals__getRequireError;

//<editor-fold desc="define static function">
//<editor-fold desc="define read function">
/**
 * 编译数据，并将结果放入栈顶
 * @param chunkname 可为空
 * @return LUA_OK: 成功，其他，失败
 */
static int compile_buffer(lua_State *L, const char *data, size_t size, const char *chunkname);
/**
 * 编译文件数据，并将结果放入栈顶
 * @param chunkname 可为空，则使用file当作chunkname
 * @return LUA_OK: 成功，其他，失败
 */
static int compile_file(lua_State *L, const char *file, const char *chunkname);
#ifdef ANDROID
/**
 * 编译Android Assets文件数据，并将结果放入栈顶
 * @param chunkname  可为空，则使用file当作chunkname
 * @return LUA_OK: 成功，其他，失败
 */
static int compile_assets(lua_State *L, const char *file, const char *chunkname);
#endif
//</editor-fold>

//<editor-fold desc="define java read function">

static int j_compile_buffer(JNIEnv *env, lua_State *L, jstring name, jbyteArray data);

static int j_compile_file(JNIEnv *env, lua_State *L, jstring path, jstring chunkname);

#ifdef ANDROID
static int j_compile_assets(JNIEnv *env, lua_State *L, jstring path, jstring chunkname);
#endif

static void throwUndumpError(JNIEnv *env, const char *msg);
//</editor-fold>

/**
 * 保存lua function，栈顶必须是luafunction
 * @param file 保存位置
 * @return LUA_OK: 成功
 */
static int saveProto(lua_State *L, const char *file);
//</editor-fold>

//<editor-fold desc="jni methods">

void jni_openSAES(JNIEnv *env, jobject jobj, jboolean open) {
    opensaes = (int) open;
}

jint jni_loadData(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring name, jbyteArray data) {
    lua_State *L = (lua_State *) L_state_pointer;
    lua_lock(L);
    jint r = (jint) j_compile_buffer(env, L, name, data);
    lua_unlock(L);
    return r;
}

jint
jni_loadFile(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring path, jstring chunkname) {
    lua_State *L = (lua_State *) L_state_pointer;
    lua_lock(L);
    jint r = (jint) j_compile_file(env, L, path, chunkname);
    lua_unlock(L);
    return r;
}

#ifdef ANDROID
jint
jni_loadAssetsFile(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring path, jstring chunkname) {
    lua_State *L = (lua_State *) L_state_pointer;
    lua_lock(L);
    jint r = (jint) j_compile_assets(env, L, path, chunkname);
    lua_unlock(L);
    return r;
}
#endif

jboolean jni_setMainEntryFromPreload(JNIEnv *env, jobject jobj, jlong LS, jstring name) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_unlock(L);
        return JNI_TRUE;
    }
    const char *cn = GetString(env, name);
    lua_getfield(L, -1, cn);
    ReleaseChar(env, name, cn);
    if (lua_isfunction(L, -1)) {
        lua_unlock(L);
        return JNI_TRUE;
    }
    lua_pop(L, 1);
    lua_unlock(L);
    return JNI_FALSE;
}

jint jni_doLoadedData(JNIEnv *env, jobject jobj, jlong L_state_pointer) {
    lua_State *L = (lua_State *) L_state_pointer;
    lua_lock(L);
    int err = lua_iscfunction(L, 1) ? 1 : 0;
    jint ret = (jint) lua_pcall(L, 0, LUA_MULTRET, err);
    if (ret) {
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        throwInvokeError(env, errmsg);
    }
    lua_unlock(L);
    return ret;
}

static inline void _set_to_preload(JNIEnv *env, lua_State *L, jstring name, int ret) {
    if (ret) {
        lua_pop(L, 1);
        return;
    }
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD");
    lua_pushvalue(L, -2);
    const char *cn = GetString(env, name);
    lua_setfield(L, -2, cn);
    ReleaseChar(env, name, cn);
    lua_pop(L, 2);
}

void jni_preloadData(JNIEnv *env, jobject jobj, jlong LS, jstring name, jbyteArray data) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    int ret = j_compile_buffer(env, L, name, data);
    _set_to_preload(env, L, name, ret);
    lua_unlock(L);
}

void jni_preloadFile(JNIEnv *env, jobject jobj, jlong LS, jstring name, jstring path) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    int ret = j_compile_file(env, L, path, name);
    _set_to_preload(env, L, name, ret);
    lua_unlock(L);
}

#ifdef ANDROID
void jni_preloadAssets(JNIEnv *env, jobject jobj, jlong LS, jstring chunkname, jstring path) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    int ret = j_compile_assets(env, L, path, chunkname);
    _set_to_preload(env, L, chunkname, ret);
    lua_unlock(L);
}

jint jni_preloadAssetsAndSave(JNIEnv *env, jobject jobj, jlong LS, jstring chunkname, jstring path, jstring savePath) {
    lua_State *L = (lua_State *) LS;
    const char *p = GetString(env, path);
    const char *cn = GetString(env, chunkname);
    lua_lock(L);
    int ret = compile_assets(L, p, cn);
    ReleaseChar(env, path, p);
    if (ret) {
        if (cn)
            ReleaseChar(env, chunkname, cn);
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        lua_pop(L, 1);
        throwUndumpError(env, errmsg);
        lua_unlock(L);
        return 0;
    }
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD");
    lua_pushvalue(L, -2);
    lua_setfield(L, -2, cn);
    /// -1 table -2 function
    lua_pop(L, 1);
    if (cn)
        ReleaseChar(env, chunkname, cn);
    const char *file = GetString(env, savePath);
    int saveRet = saveProto(L, file);
    ReleaseChar(env, savePath, file);
    lua_pop(L, 1);
    lua_unlock(L);
    return saveRet;
}
#endif

jint jni_require(JNIEnv *env, jobject jobj, jlong LS, jstring path) {
    lua_State *L = (lua_State *) LS;
    int errFun = getErrorFunctionIndex(L);
    lua_getglobal(L, "require");
    if (!lua_isfunction(L, -1)) {
        lua_pop(L, 1);
        return -1;
    }
    const char *s = GetString(env, path);
    lua_pushstring(L, s);
    ReleaseChar(env, path, s);
    if (lua_pcall(L, 1, 0, errFun)) {
        const char *msg;
        if (lua_isstring(L, -1)) {
            msg = lua_tostring(L, -1);
        } else {
            msg = "unknown error";
        }
        lua_pop(L, 1);
        throwInvokeError(env, msg);
        return 0;
    }
    return 0;
}

jint jni_dumpFunction(JNIEnv *env, jobject jobj, jlong LS, jlong fun, jstring path) {
    lua_State *L = (lua_State *) LS;
    getValueFromGNV(L, (ptrdiff_t) fun, LUA_TFUNCTION);
    if (!lua_isfunction(L, -1)) {
        lua_pop(L, 1);
        return -1;
    }
    const char *file = GetString(env, path);
    int ret = saveProto(L, file);
    ReleaseChar(env, path, file);
    lua_pop(L, 1);
    return ret;
}

extern jclass LuaValue;
jobjectArray jni_doLoadedDataAndGetResult(JNIEnv *env, jobject jobj, jlong LS) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    int err = lua_iscfunction(L, 1) ? 1 : 0;
    int oldTop = lua_gettop(L) - 1;
    jint ret = (jint) lua_pcall(L, 0, LUA_MULTRET, err);
    if (ret) {
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        throwInvokeError(env, errmsg);
        lua_unlock(L);
        return NULL;
    }
    int returnCount = lua_gettop(L) - oldTop;
    if (returnCount == 0) {
        lua_unlock(L);
        return NULL;
    }
    int i;
    jobjectArray r = (*env)->NewObjectArray(env, returnCount, LuaValue, NULL);
    for (i = returnCount - 1; i >= 0; i--) {
        jobject v = toJavaValue(env, L, oldTop + i + 1);
        (*env)->SetObjectArrayElement(env, r, i, v);
        FREE(env, v);
    }
    lua_settop(L, oldTop);
    lua_unlock(L);
    return r;
}

jint jni_startDebug(JNIEnv *env, jobject jobj, jlong LS, jbyteArray data, jstring ip, jint port) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    /// 加载debug脚本
    int ret = j_compile_buffer(env, L, NULL, data); // -1: debug
    if (ret) {
        lua_unlock(L);
        return (jint) ret;
    }
    /// 执行debug脚本，返回table，需要调用table.start(ip, port)
    ret = lua_pcall(L, 0, 1, 0); // -1: table
    if (ret) {
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        throwInvokeError(env, errmsg);
        lua_unlock(L);
        return (jint) ret;
    }
    if (!lua_istable(L, -1)) {
        throwInvokeError(env, "return value not a table!");
        lua_unlock(L);
        return -1;
    }
    lua_pushstring(L, "start");
    lua_gettable(L, -2);
    /// 判断table.start是否是函数
    if (!lua_isfunction(L, -1)) // -1: start fun; -2: table
    {
        lua_pop(L, 2);
        throwInvokeError(env, "start is not function in table!");
        lua_unlock(L);
        return -1;
    }
    const char *ips = GetString(env, ip);
    lua_pushstring(L, ips);
    ReleaseChar(env, ip, ips);
    lua_pushinteger(L, (lua_Integer) port);
    /// 调用table.start(ip, port)
    ret = lua_pcall(L, 2, 1, 0); // -1: result; -2: table
    if (ret) {
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        throwInvokeError(env, errmsg);
        lua_unlock(L);
        return (jint) ret;
    }
    lua_pop(L, 2);
    lua_unlock(L);
    return (jint) ret;
}
//</editor-fold>

//<editor-fold desc="implement function">
//<editor-fold desc="implement read function">

static int compile_buffer(lua_State *L, const char *data, size_t size, const char *chunkname) {
    if (!opensaes) return luaL_loadbuffer(L, data, size, chunkname);
    SIZE cs = check_header(data);
    int ret;
    if (cs == size) {
        char *dest = (char *) m_malloc(NULL, 0, size * sizeof(char));
        decrypt_cpy(dest, data + SOURCE_LEN + HEADER_LEN, size);
        ret = luaL_loadbuffer(L, dest, size, chunkname);
        m_malloc(dest, size * sizeof(char), 0);
    } else {
        ret = luaL_loadbuffer(L, data, size, chunkname);
    }
    return ret;
}

//<editor-fold desc="file read function">

typedef struct FileData {
    int n;                 /* number of pre-read characters */
    int aes;               /* nead aes?*/
    FILE *f;               /* file being read */
    char buff[BUFFER_SIZE]; /* area for reading file */
} FileData;
/**
 * for compile_file
 */
static const char *_file_reader(lua_State *L, void *ud, size_t *size) {
    FileData *lf = (FileData *) ud;
    (void) L; /* not used */
    if (lf->n > 0) {   /* are there pre-read characters to be read? */
        *size = lf->n; /* return them (chars already in buffer) */
        lf->n = 0;     /* no more pre-read characters */
    } else {
        /// 检查文件是否已读完
        if (feof(lf->f))
            return NULL;
        *size = fread(lf->buff, 1, BUFFER_SIZE, lf->f); /* read block */
        if (*size && lf->aes) decrypt(lf->buff, *size);
    }
    return lf->buff;
}
/**
 * 文件操作出错时调用 for compile_file
 * 将错误信息放到栈顶
 */
static inline int errfile(lua_State *L, const char *what, const char *filename) {
    const char *serr = strerror(errno);
    lua_pushfstring(L, "cannot %s %s: %s", what, filename, serr);
    return LUA_ERRFILE;
}
/**
 * 获取文件大小
 */
static inline SIZE get_file_size(const char *__restrict file) {
    struct stat statbuf;
    stat(file, &statbuf);
    return (SIZE) statbuf.st_size;
}
static int compile_file(lua_State *L, const char *filename, const char *chunkname) {
    int oldTop = lua_gettop(L);
    FileData lf;
    lf.n = 0;
    lf.aes = 0;
    lf.buff[0] = '\0';
    /// 先使用二进制读取，检查文件类型
    lf.f = fopen(filename, "rb");
    if (!lf.f) return errfile(L, "open(byte)", filename);
    if (chunkname)
        lua_pushstring(L, chunkname);
    else
        lua_pushfstring(L, "@%s", filename);
    if (opensaes) {
        /// check aes
        SIZE size = get_file_size(filename);
        if (size > HEADER_LEN + SOURCE_LEN) {
            int r = fread(lf.buff, HEADER_LEN + SOURCE_LEN, 1, lf.f);
            lf.aes = r && check_header(lf.buff) == (size - HEADER_LEN - SOURCE_LEN);
        }
    }
    /// 1: bytecode
    /// 2: source code
    /// 3: aes code
    int codeType = 3;
    if (!lf.aes) {
        /// 源码的情况
        if (lf.buff[0] != LUA_SIGNATURE[0]) {
            lf.f = freopen(filename, "r", lf.f);
            if (!lf.f) return errfile(L, "reopen", filename);
            codeType = 2;
        } else {
            lf.n = HEADER_LEN + SOURCE_LEN;
            codeType = 1;
        }
    }
    int state = lua_load(L, _file_reader, &lf, lua_tostring(L, -1), NULL);
    int readstatus = ferror(lf.f);
    fclose(lf.f);
    if (readstatus) {
        lua_settop(L, oldTop);  /* ignore results from `lua_load' */
        const char *info;
        switch (codeType) {
            case 1:
                info = "read bytecode";
                break;
            case 2:
                info = "read source code";
                break;
            case 3:
                info = "read aes bytecode";
                break;
            default:
                info = "read unknown code";
                break;
        }
        return errfile(L, info, filename);
    }
    lua_remove(L, -2);
    return state;
}
//</editor-fold>

#ifdef ANDROID
static int compile_assets(lua_State *L, const char *filename, const char *chunkname) {
    if (chunkname)
        lua_pushstring(L, chunkname);
    else
        lua_pushfstring(L, "@%s", filename);

    AD ad;
    int code = initAssetsData(&ad, filename);
    if (code != AR_OK) {
        lua_pushfstring(L, "find %s from native asset failed, code: %d", filename, code);
        return code;
    }
    if (opensaes) {
        unsigned short preReadLen;
        const char *preData = preReadData(&ad, HEADER_LEN + SOURCE_LEN, &preReadLen);
        if (!preData) {
            destroyAssetsData(&ad);
            lua_pushfstring(L, "preload %s from native asset failed!", filename);
            return 1;
        }

        size_t len = (size_t) ad.len;
        if (preReadLen < (HEADER_LEN + SOURCE_LEN)) {
            /// 非加密
            ad.aes = 0;
            ad.remain = preReadLen;
        } else {
            int aes = check_header(preData) == (len - HEADER_LEN - SOURCE_LEN);
            ad.aes = aes;
            ad.remain = aes ? 0 : preReadLen;
        }
    } else {
        ad.aes = 0;
        ad.remain = 0;
    }
    code = lua_load(L, getFromAssets, &ad, lua_tostring(L, -1), NULL);
    destroyAssetsData(&ad);
    lua_remove(L, -2);  //remove chunkname

    return code;
}
#endif
//</editor-fold>

//<editor-fold desc="implement java read function">

static int j_compile_buffer(JNIEnv *env, lua_State *L, jstring name, jbyteArray data) {
    jbyte *nd = (*env)->GetByteArrayElements(env, data, 0);
    size_t size = (size_t) GetArrLen(env, data);
    const char *cn = GetString(env, name);

    lua_lock(L);
    int ret = compile_buffer(L, (char *) nd, size, cn);
    (*env)->ReleaseByteArrayElements(env, data, nd, 0);
    if (name)
        ReleaseChar(env, name, cn);
    if (ret) {
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        lua_pop(L, 1);
        throwUndumpError(env, errmsg);
    }
    lua_unlock(L);
    return ret;
}

static int j_compile_file(JNIEnv *env, lua_State *L, jstring path, jstring chunkname) {
    const char *p = GetString(env, path);
    const char *cn = GetString(env, chunkname);
    lua_lock(L);
    int ret = compile_file(L, p, cn);
    ReleaseChar(env, path, p);
    if (cn)
        ReleaseChar(env, chunkname, cn);
    if (ret) {
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        lua_pop(L, 1);
        throwUndumpError(env, errmsg);
    }
    lua_unlock(L);
    return ret;
}

#ifdef ANDROID
static int j_compile_assets(JNIEnv *env, lua_State *L, jstring path, jstring chunkname) {
    const char *p = GetString(env, path);
    const char *cn = GetString(env, chunkname);
    lua_lock(L);
    int ret = compile_assets(L, p, cn);
    ReleaseChar(env, path, p);
    if (cn)
        ReleaseChar(env, chunkname, cn);
    if (ret) {
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        lua_pop(L, 1);
        throwUndumpError(env, errmsg);
    }
    lua_unlock(L);
    return ret;
}
#endif

static jclass UndumpError;
static void throwUndumpError(JNIEnv *env, const char *msg) {
    ClearException(env);
    if (!UndumpError)
        UndumpError = GLOBAL(env, (*env)->FindClass(env, JAVA_PATH
                "exception/UndumpError"));
    (*env)->ThrowNew(env, UndumpError, msg);
}
//</editor-fold>

static int writer(lua_State *L, const void *p, size_t size, void *u) {
    if (!size)
        return 1;
    if (!opensaes)
        return fwrite(p, size, 1, (FILE *) u) != 1;
    char temp[BUFFER_SIZE];
    while (size) {
        size_t realsize = size > BUFFER_SIZE ? BUFFER_SIZE : size;
        size -= realsize;
        encrypt_cpy(temp, (const char *) p, realsize);
        if (!fwrite(temp, realsize, 1, (FILE *) u)) return 1;
    }

    return 0;
}

static int saveProto(lua_State *L, const char *file) {
    FILE *F = fopen(file, "wb");
    if (!F)
        return FILE_NOT_FOUND;
    /// 开启加密的情况，先写占位
    if (opensaes) {
        char *temp[HEADER_LEN + SOURCE_LEN];
        memset(temp, 0, HEADER_LEN + SOURCE_LEN);
        if (!fwrite(temp, HEADER_LEN + SOURCE_LEN, 1, F)) {
            fclose(F);
            return WRITE_FILE_ERROR;
        }
    }
    const Proto *p = getproto(L->top - 1);
    int ret = luaU_dump(L, p, writer, F, 0);
    if (ferror(F))
        return WRITE_FILE_ERROR;
    /// 开启加密的情况，最后获取到文件总长度时，再覆盖写入头部信息
    if (opensaes) {
        SIZE size = (SIZE) ftell(F) - HEADER_LEN - SOURCE_LEN;
        F = freopen(file, "rb+", F);
        if (!F) return FILE_NOT_FOUND;
        if (!fwrite(EN_HEADER, HEADER_LEN, 1, F)) {
            fclose(F);
            return WRITE_FILE_ERROR;
        }
        char *h2 = generate_header(size);
        if (!fwrite(h2, SOURCE_LEN, 1, F)) {
#if defined(J_API_INFO)
            m_malloc(h2, SOURCE_LEN, 0);
#else
            free(h2);
#endif
            fclose(F);
            return WRITE_FILE_ERROR;
        }
#if defined(J_API_INFO)
        m_malloc(h2, SOURCE_LEN, 0);
#else
        free(h2);
#endif
    }
    if (fclose(F))
        return CLOSE_FILE_ERROR;
    return ret;
}
//</editor-fold>

//<editor-fold desc="require">

static int readable(const char *filename) {
    FILE *f = fopen(filename, "r"); /* try to open file */
    if (!f)
        return 0; /* open failed */
    fclose(f);
    return 1;
}

/**
 * 不需要free
 */
static char *replaceLuaRequire(lua_State *L, const char *name) {
    size_t len = strlen(name);
    if (name[len-4] == '.'
    && name[len-3] == 'l'
    && name[len-2] == 'u'
    && name[len-1] == 'a') {
        char *nameNoLua = m_malloc(NULL, 0, sizeof(char) * (len - 3));
        memcpy(nameNoLua, name, len - 4);
        nameNoLua[len-4] = '\0';
        const char *path = luaL_gsub(L, nameNoLua, ".", LUA_DIRSEP);
#if defined(J_API_INFO)
        m_malloc(nameNoLua, (len - 3) * sizeof(char), 0);
#else
        free(nameNoLua);
#endif
        return path;
    }
    return luaL_gsub(L, name, ".", LUA_DIRSEP);
}

static char *findfile4lua(lua_State *L, const char *name) {
    const char *path;
    lua_getfield(L, lua_upvalueindex(1), "path");
    if (lua_isstring(L, -1))
        path = lua_tostring(L, -1);
    else
        path = NULL;
    lua_pop(L, 1);
    name = replaceLuaRequire(L, name);
    char *ret;
    if (!path) {
        ret = joinstr(name, ".lua");
    } else {
        ret = formatstr("%s" LUA_DIRSEP "%s.lua", path, name);
    }
    if (!ret) {
        lua_pushfstring(L, "\n\tformat %s error!", name);
        return NULL;
    }
    if (readable(ret))
        return ret;
    lua_pushfstring(L, "\n\tfile %s is not readable", ret);
#if defined(J_API_INFO)
    m_malloc(ret, (strlen(ret) + 1) * sizeof(char), 0);
#else
    free(ret);
#endif
    return NULL;
}

/**
 * loadlib.c createsearcherstable
 */
int searcher_Lua(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    double startTime = getStartTime();
#endif

    lua_lock(L);
    char *filename;
    const char *name = luaL_checkstring(L, 1);
    filename = findfile4lua(L, name);
    if (!filename) {
        lua_unlock(L);
        return 1; /* module not found in this path */
    }

    if (compile_file(L, filename, name) == LUA_OK) {
        lua_pushstring(L, filename); /* will be 2nd argument to module */
#if defined(J_API_INFO)
        m_malloc(filename, (strlen(filename) + 1) * sizeof(char), 0);
#else
        free(filename);
#endif
        lua_unlock(L);
#ifdef STATISTIC_PERFORMANCE
        statistics_searcher_Call(FROM_SEARCHER_LUA, name, getoffsetTime(startTime));
#endif
        return 2;
    }

    lua_pushfstring(L, "\n\terror loading module '%s' from file '%s':\n\t%s",
                    lua_tostring(L, 1), filename, lua_tostring(L, -1));
#if defined(J_API_INFO)
    m_malloc(filename, (strlen(filename) + 1) * sizeof(char), 0);
#else
    free(filename);
#endif
    lua_unlock(L);
    return 1;
}

/**
 * 参数1 : name (string)
 * 返回2 : -1: string, -2: function(or nil)
 */
int searcher_java(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    double startTime = getStartTime();
#endif

    JNIEnv *env;
    int need = getEnv(&env);
    lua_lock(L);
    const char *name = luaL_checkstring(L, 1);
    jstring str = newJString(env, name);
    jobject r = (*env)->CallStaticObjectMethod(env, Globals, Globals__onLuaRequire, (jlong) L, str);
    FREE(env, str);
    if (!r) {
        jobject errorStr = (*env)->CallStaticObjectMethod(env, Globals, Globals__getRequireError, (jlong) L);
        const char *em = GetString(env, errorStr);
        if (em) {
            lua_pushfstring(L, "\n\trequire %s from java failed, error: %s", name, em);
            ReleaseChar(env, errorStr, em);
        } else {
            lua_pushfstring(L, "\n\trequire %s from java failed, unknown error", name);
        }
        if (need) detachEnv();
        lua_unlock(L);
        return 1;
    }
    int isstr = (*env)->IsInstanceOf(env, r, StringClass);

    if (isstr) // return a path(string), call real_loadfile
    {
        const char *path = GetString(env, r);
        if (compile_file(L, path, name) == LUA_OK) {
            lua_pushstring(L, path);
            ReleaseChar(env, r, path);
            FREE(env, r);
            if (need) detachEnv();
            lua_unlock(L);
#ifdef STATISTIC_PERFORMANCE
            statistics_searcher_Call(FROM_SEARCHER_JAVA, name, getoffsetTime(startTime));
#endif
            return 2;
        }
        lua_pushfstring(L, "\n\terror loading module '%s' from java file '%s':\n\t%s",
                                          name, path, lua_tostring(L, -1));
        ReleaseChar(env, r, path);
        FREE(env, r);
        if (need) detachEnv();
        lua_unlock(L);
        return 1;
    } else // return file content (byte array ), call real_loadbuffer
    {
        jbyteArray arr = (jbyteArray) r;
        jbyte *nd = (*env)->GetByteArrayElements(env, arr, 0);
        size_t size = (size_t) GetArrLen(env, arr);
        int loadresult = compile_buffer(L, (char *) nd, size, name);
        (*env)->ReleaseByteArrayElements(env, arr, nd, 0);
        FREE(env, arr);
        if (loadresult == LUA_OK) {
            lua_pushstring(L, name);
            if (need) detachEnv();
            lua_unlock(L);
#ifdef STATISTIC_PERFORMANCE
            statistics_searcher_Call(FROM_SEARCHER_JAVA, name, getoffsetTime(startTime));
#endif
            return 2;
        }
        if (need) detachEnv();
        lua_unlock(L);
        lua_pushfstring(L, "\n\terror loading module '%s' from java data:\n\t%s", name,
                        lua_tostring(L, -1));
        return 1;
    }
}

#ifdef ANDROID
/**
 * require时调用
 */
int searcher_Lua_asset(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    double startTime = getStartTime();
#endif
    const char *name = luaL_checkstring(L, 1);
    const char *filename = formatstr("%s.lua", replaceLuaRequire(L, name));
    int code = compile_assets(L, filename, name);
#if defined(J_API_INFO)
    m_malloc((void *) filename, (strlen(filename) + 1) * sizeof(char), 0);
#else
    free(filename);
#endif
    if (code == LUA_OK) {
        lua_pushvalue(L, 1);
#ifdef STATISTIC_PERFORMANCE
        statistics_searcher_Call(FROM_SEARCHER_ASSET, name, getoffsetTime(startTime));
#endif
        return 2;
    }
    const char *err;
    if (lua_isstring(L, -1)) {
        err = lua_tostring(L, -1);
    } else {
        err = "unknown error!";
    }
    lua_pop(L, 1);
    lua_pushfstring(L, "\n\terror loading module '%s' from asset '%s', code: %d, err: %s",
                    name, filename, code, err);
    return 1;
}
#endif
//</editor-fold>