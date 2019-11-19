/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
//  compiler.c
//
//  Created by XiongFangyu on 2019/6/13.
//  Copyright © 2019 XiongFangyu. All rights reserved.
//

#include <errno.h>
#include <sys/stat.h>
#include "compiler.h"
#include "luajapi.h"
#include "saes.h"
#include "lundump.h"
#include "m_mem.h"
#include "llimits.h"
#include "assets_reader.h"

/**
 * 是否开启文件加密，若开启，读lua文件判断是否是加密文件，写lua文件都加密
 *                若关闭，读写都不使用加密
 */
static int opensaes = 0;
extern jclass Globals;
extern jclass StringClass;
extern jmethodID Globals__onLuaRequire;

#define AUTO_SAVE "__autosave"

#define FILE_NOT_FOUND -404
#define WRITE_FILE_ERROR -300
#define CLOSE_FILE_ERROR -301
#define GET_PROTO(L) getproto(L->top - 1)
#define BUFFER_SIZE 1024
#define READ_BLOCK 1024

typedef struct LoadEF {
    int n;                 /* number of pre-read characters */
    int aes;               /* nead aes?*/
    FILE *f;               /* file being read */
    char buff[READ_BLOCK]; /* area for reading file */
} LoadEF;

typedef struct LoadES {
    const char *s;
    size_t size;
} LoadES;

static int getLuaClosureAndSave(JNIEnv *env, lua_State *L, jstring savePath, jstring chunkname);

static int loadbuffer(JNIEnv *env, lua_State *L, jstring name, jbyteArray data);

static int real_loadbuffer(lua_State *L, char *nd, size_t size, const char *cn);

static const char *getES(lua_State *L, void *ud, size_t *size);

static int loadfile(JNIEnv *env, lua_State *L, jstring path, jstring chunkname);

static int real_loadfile(lua_State *L, const char *filename, const char *chunkname);

static int loadAssetsfile(JNIEnv *env, lua_State *L, jstring path, jstring chunkname);

static int real_loadassetsfile(lua_State *L, const char *filename, const char *chunkname);

static int errfile(lua_State *L, const char *what, const char *filename);

static SIZE get_file_size(const char *__restrict file);

static const char *getF(lua_State *L, void *ud, size_t *size);

static void checkSaveError(JNIEnv *env, int ret);

static int writer(lua_State *L, const void *p, size_t size, void *u);

static int saveProto(lua_State *L, const Proto *p, const char *file);

static void throwUndumpError(JNIEnv *env, const char *msg);

/// ------------------------jni methods------------------------
void jni_openSAES(JNIEnv *env, jobject jobj, jboolean open) {
    opensaes = (int) open;
}

void jni_setBasePath(JNIEnv *env, jobject jobj, jlong LS, jstring path, jboolean autosave) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    const char *bp = GetString(env, path);
    lua_getglobal(L, LUA_LOADLIBNAME); //-1 package table
    lua_pushstring(L, bp);             //-1 bp -- table
    lua_setfield(L, -2, "path");       //-1 table
    lua_pushboolean(L, (int) autosave); //-1 bool --table
    lua_setfield(L, -2, AUTO_SAVE);    //-1 table
    lua_pop(L, 1);
    ReleaseChar(env, path, bp);
    lua_unlock(L);
}

void jni_setSoPath(JNIEnv *env, jobject jobj, jlong LS, jstring path) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    const char *bp = GetString(env, path);
    lua_getglobal(L, LUA_LOADLIBNAME); //-1 package table
    lua_pushstring(L, bp);             //-1 bp -- table
    lua_setfield(L, -2, "cpath");      //-1 table
    lua_pop(L, 1);
    ReleaseChar(env, path, bp);
    lua_unlock(L);
}

jint jni_compileAndSave(JNIEnv *env, jobject jobj, jlong L, jstring fn, jstring chunkname,
                        jbyteArray data) {
    lua_State *LS = (lua_State *) L;

    lua_lock(LS);
    int ret = loadbuffer(env, LS, chunkname, data);
    if (ret) {
        lua_unlock(LS);
        return ret;
    }
    const Proto *f = GET_PROTO(LS);
    const char *filename = GetString(env, fn);
    ret = saveProto(LS, f, filename);
    // lua_pop(LS, 1);
    ReleaseChar(env, fn, filename);
    checkSaveError(env, ret);
    lua_unlock(LS);
    return (jint) ret;
}

jint jni_compilePathAndSave(JNIEnv *env, jobject jobj, jlong L, jstring fn, jstring src,
                            jstring chunkname) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    int ret = loadfile(env, LS, src, chunkname);
    if (ret) {
        lua_unlock(LS);
        return ret;
    }
    const Proto *f = GET_PROTO(LS);
    const char *filename = GetString(env, fn);
    ret = saveProto(LS, f, filename);
    // lua_pop(LS, 1);
    ReleaseChar(env, fn, filename);
    checkSaveError(env, ret);
    lua_unlock(LS);
    return (jint) ret;
}

jint jni_savePreloadData(JNIEnv *env, jobject jobj, jlong LS, jstring savePath, jstring chunkname) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD"); // -1: _PRELOAD table
    jint r = (jint) getLuaClosureAndSave(env, L, savePath, chunkname);
    lua_unlock(L);
    return r;
}

jint jni_saveChunk(JNIEnv *env, jobject jobj, jlong LS, jstring savePath, jstring chunkname) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_LOADED");
    jint r = (jint) getLuaClosureAndSave(env, L, savePath, chunkname);
    lua_unlock(L);
    return r;
}

jint jni_loadData(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring name, jbyteArray data) {
    lua_State *L = (lua_State *) L_state_pointer;
    lua_lock(L);
    jint r = (jint) loadbuffer(env, L, name, data);
    lua_unlock(L);
    return r;
}

jint
jni_loadFile(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring path, jstring chunkname) {
    lua_State *L = (lua_State *) L_state_pointer;
    lua_lock(L);
    jint r = (jint) loadfile(env, L, path, chunkname);
    lua_unlock(L);
    return r;
}

jint
jni_loadAssetsFile(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring path, jstring chunkname) {
    lua_State *L = (lua_State *) L_state_pointer;
    lua_lock(L);
    jint r = (jint) loadAssetsfile(env, L, path, chunkname);
    lua_unlock(L);
    return r;
}

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

void jni_preloadData(JNIEnv *env, jobject jobj, jlong LS, jstring name, jbyteArray data) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    int ret = loadbuffer(env, L, name, data);
    if (ret) {
        lua_unlock(L);
        return;
    }
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD");
    lua_pushvalue(L, -2);
    const char *cn = GetString(env, name);
    lua_setfield(L, -2, cn);
    ReleaseChar(env, name, cn);
    lua_pop(L, 2);
    lua_unlock(L);
}

void jni_preloadFile(JNIEnv *env, jobject jobj, jlong LS, jstring name, jstring path) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    const char *p = GetString(env, path);
    int ret = real_loadfile(L, p, NULL);
    ReleaseChar(env, path, p);
    if (ret) {
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        throwUndumpError(env, errmsg);
        lua_pop(L, 1);
        lua_unlock(L);
        return;
    }
    const char *cn = GetString(env, name);
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD");
    lua_pushvalue(L, -2);
    lua_setfield(L, -2, cn);
    ReleaseChar(env, name, cn);
    lua_pop(L, 2);
    lua_unlock(L);
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

jint jni_startDebug(JNIEnv *env, jobject jobj, jlong LS, jbyteArray data, jstring ip, jint port) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    /// 加载debug脚本
    int ret = loadbuffer(env, L, NULL, data); // -1: debug
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

///--------------------------------------------------------------------------------
///-----------------------------------static---------------------------------------
///--------------------------------------------------------------------------------
static int getLuaClosureAndSave(JNIEnv *env, lua_State *L, jstring savePath, jstring chunkname) {
    lua_lock(L);
    const char *cn = GetString(env, chunkname);
    lua_pushstring(L, cn); // -1: cn --table
    ReleaseChar(env, chunkname, cn);
    lua_rawget(L, -2); // -1: preloadFunction --table
    if (lua_isnil(L, -1) || !isLfunction(L->top - 1)) {
        lua_pop(L, 2);
        lua_unlock(L);
        return -400;
    }
    const char *p = GetString(env, savePath);
    const Proto *f = GET_PROTO(L);
    int ret = saveProto(L, f, p);
    lua_pop(L, 2);
    ReleaseChar(env, savePath, p);
    checkSaveError(env, ret);
    lua_unlock(L);
    return ret;
}

static int real_loadbuffer(lua_State *L, char *nd, size_t size, const char *cn) {
    if (!opensaes) return luaL_loadbuffer(L, nd, size, cn);
    SIZE cs = check_header(nd);
    int ret;
    if (cs == size) {
        encrypt(nd, size);
        LoadES les;
        les.s = nd;
        les.size = size;
        ret = lua_load(L, getES, &les, cn, NULL);
        LOGI("load aes data");
    } else {
        ret = luaL_loadbuffer(L, nd, size, cn);
        LOGI("load none aes data");
    }
    return ret;
}

static int loadbuffer(JNIEnv *env, lua_State *L, jstring name, jbyteArray data) {
    jbyte *nd = (*env)->GetByteArrayElements(env, data, 0);
    size_t size = (size_t) GetArrLen(env, data);
    const char *cn = GetString(env, name);

    lua_lock(L);
    int ret = real_loadbuffer(L, (char *) nd, size, cn);
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

static const char *getES(lua_State *L, void *ud, size_t *size) {
    LoadES *ls = (LoadES *) ud;
    (void) L; /* not used */
    if (ls->size == 0)
        return NULL;
    *size = ls->size;
    ls->size = 0;
    return ls->s + SOURCE_LEN + HEADER_LEN;
}

static int loadAssetsfile(JNIEnv *env, lua_State *L, jstring path, jstring chunkname) {
    const char *p = GetString(env, path);
    const char *cn = GetString(env, chunkname);
    lua_lock(L);
    int ret = real_loadassetsfile(L, p, cn);
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

static int loadfile(JNIEnv *env, lua_State *L, jstring path, jstring chunkname) {
    const char *p = GetString(env, path);
    const char *cn = GetString(env, chunkname);
    lua_lock(L);
    int ret = real_loadfile(L, p, cn);
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

static int real_loadassetsfile(lua_State *L, const char *filename, const char *chunkname) {
    int oldTop = lua_gettop(L);
    if (chunkname)
        lua_pushstring(L, chunkname);
    else
        lua_pushfstring(L, "@%s", filename);

    AD ad;
    int code = initAssetsData(&ad, filename);
    if (code != AR_OK) {
        lua_pushfstring(L, "find %s from native asset failed, code: %d", lua_tostring(L, -1), code);
        return 1;
    }
    if (opensaes) {
        unsigned short preReadLen;
        const char *preData = preReadData(&ad, HEADER_LEN + SOURCE_LEN, &preReadLen);
        if (!preData) {
            destroyAssetsData(&ad);
            lua_pushfstring(L, "preload %s from native asset failed!", lua_tostring(L, -1));
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
    lua_remove(L, oldTop + 1);

    if (code != LUA_OK) {
        lua_pushfstring(L, "error loading '%s' from asset, code: %d",
                        lua_tostring(L, -1), code);
    }
    return code;
}

static int real_loadfile(lua_State *L, const char *filename, const char *chunkname) {
    if (!opensaes) return luaL_loadfilec(L, filename, chunkname);
    LoadEF lf;
    lf.aes = 0;
    lf.n = 0;
    int oldTop = lua_gettop(L);
    if (chunkname)
        lua_pushstring(L, chunkname);
    else
        lua_pushfstring(L, "@%s", filename);
    /// 先使用二进制读取，检查是否是加密文件
    lf.f = fopen(filename, "rb");
    if (!lf.f) return errfile(L, "open", filename);
    /// check aes
    SIZE size = get_file_size(filename);
    if (size > HEADER_LEN + SOURCE_LEN) {
        int r = fread(lf.buff, HEADER_LEN + SOURCE_LEN, 1, lf.f);
        lf.aes = r && check_header(lf.buff) == (size - HEADER_LEN - SOURCE_LEN);
    }
    /// 1: bytecode
    /// 2: source code
    /// 3: aes code
    int codeType = 0;
    /// check end
    if (!lf.aes) {
        /// 源码的情况
        if (lf.buff[0] != LUA_SIGNATURE[0]) {
            lf.f = freopen(filename, "r", lf.f);
            if (!lf.f) return errfile(L, "reopen", filename);
            codeType = 2;
        }
        /// bytecode
        else {
            lf.n = HEADER_LEN + SOURCE_LEN;
            codeType = 1;
        }
    } else {
        codeType = 4;
    }
    int state = lua_load(L, getF, &lf, lua_tostring(L, -1), NULL);
    LOGI("load %saes data", lf.aes ? " " : "none ");
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
    lua_remove(L, oldTop + 1);
    return state;
}

static SIZE get_file_size(const char *__restrict file) {
    struct stat statbuf;
    stat(file, &statbuf);
    return (SIZE) statbuf.st_size;
}

static int errfile(lua_State *L, const char *what, const char *filename) {
    const char *serr = strerror(errno);
    lua_pushfstring(L, "cannot %s %s: %s", what, filename, serr);
    return LUA_ERRFILE;
}

static const char *getF(lua_State *L, void *ud, size_t *size) {
    LoadEF *lf = (LoadEF *) ud;
    (void) L; /* not used */
    if (lf->n > 0) {                  /* are there pre-read characters to be read? */
        *size = lf->n; /* return them (chars already in buffer) */
        lf->n = 0;     /* no more pre-read characters */
    } else {
        /// 检查文件是否已读完
        if (feof(lf->f))
            return NULL;
        *size = fread(lf->buff, 1, READ_BLOCK, lf->f); /* read block */
        if (*size && lf->aes) decrypt(lf->buff, *size);
    }
    return lf->buff;
}

static void checkSaveError(JNIEnv *env, int ret) {
    switch (ret) {
        case 0:
            break;
        case FILE_NOT_FOUND:
            throwRuntimeError(env, "cannot open or find file!");
            break;
        case WRITE_FILE_ERROR:
            throwRuntimeError(env, "cannot write");
            break;
        case CLOSE_FILE_ERROR:
            throwRuntimeError(env, "cannot close");
            break;
    }
}

static int saveProto(lua_State *L, const Proto *p, const char *file) {
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

static jclass UndumpError;

static void throwUndumpError(JNIEnv *env, const char *msg) {
    ClearException(env);
    if (!UndumpError)
        UndumpError = GLOBAL(env, (*env)->FindClass(env, JAVA_PATH
                "exception/UndumpError"));
    (*env)->ThrowNew(env, UndumpError, msg);
}
///--------------------------------------------------------------------------------
///----------------------------------require---------------------------------------
///--------------------------------------------------------------------------------
#define BIN_CHAR 'b'
#define BINARY_SUFFIX_END "b"
#define isBinaryPath(p) (p[strlen(p) - 1] == BIN_CHAR)
#define isBinaryData(d) (memcmp(d, LUA_SIGNATURE, 4) == 0)

static int isAutosave(lua_State *L) {
    lua_getglobal(L, LUA_LOADLIBNAME); //-1 package table
    lua_getfield(L, -1, AUTO_SAVE);    //-1 v -- table
    int r = lua_toboolean(L, -1);
    lua_pop(L, 2);
    return r;
}

static const char *getAutoSavePath(lua_State *L) {
    lua_getglobal(L, LUA_LOADLIBNAME); //-1 package table
    lua_getfield(L, -1, AUTO_SAVE);    //-1 v -- table
    if (lua_toboolean(L, -1)) {
        lua_pop(L, 1);               //-1 table
        lua_getfield(L, -1, "path"); //-1 path -- table
        if (lua_isstring(L, -1)) {
            const char *r = lua_tostring(L, -1);
            lua_pop(L, 2);
            return r;
        }
    }
    lua_pop(L, 2);
    return NULL;
}

static int readable(const char *filename) {
    FILE *f = fopen(filename, "r"); /* try to open file */
    if (!f)
        return 0; /* open failed */
    fclose(f);
    return 1;
}

static char *getBinaryPath(const char *path) {
    int len = strlen(path);
    char *sp = (char *) m_malloc(NULL, 0, sizeof(char) * (len + 2));
    memcpy(sp, path, len);
    sp[len] = BIN_CHAR;
    sp[len + 1] = '\0';
    return sp;
}

static char *findfile4lua(lua_State *L, const char *name) {
    const char *path;
    lua_getfield(L, lua_upvalueindex(1), "path");
    path = lua_tostring(L, -1);
    if (!path)
        luaL_error(L, "'package.path' must be a string");
    name = luaL_gsub(L, name, ".", LUA_DIRSEP);
    char *ret = formatstr("%s" LUA_DIRSEP "%s.lua" BINARY_SUFFIX_END, path, name);
    size_t len = strlen(ret);
    lua_pop(L, 1);
    if (!ret)
        return NULL;
    if (readable(ret))
        return ret;
    ret[len - 1] = '\0';
    if (readable(ret))
        return ret;
    m_malloc(ret, (len + 1) * sizeof(char), 0);
    return NULL;
}

static int return_success(lua_State *L, char *filename, int autosave) {
    if (autosave) {
        char *bp = getBinaryPath(filename);
        LOGI("searcher_Lua---compile file success and save bin to %s", bp);
        saveProto(L, GET_PROTO(L), bp);
        m_malloc(bp, (strlen(bp) + 1) * sizeof(char), 0);
    }
    lua_pushstring(L, filename); /* will be 2nd argument to module */
#if defined(J_API_INFO)
    m_malloc(filename, (strlen(filename) + 1 + (isBinaryPath(filename) ? 0 : 1)) * sizeof(char), 0);
#else
    free(filename);
#endif
    return 2; /* return open function and file name */
}

static int return_failed(lua_State *L, char *filename) {
    const char *fn = lua_pushstring(L, filename);
#if defined(J_API_INFO)
    m_malloc(filename, (strlen(filename) + 1 + (isBinaryPath(filename) ? 0 : 1)) * sizeof(char), 0);
#else
    free(filename);
#endif
    lua_pop(L, 1);
    lua_pushfstring(L, "error loading module '%s' from file '%s':\n\t%s",
                    lua_tostring(L, 1), fn, lua_tostring(L, -1));
    return 1;
}

/**
 * loadlib.c createsearcherstable
 */
int searcher_Lua(lua_State *L) {
    lua_lock(L);
    char *filename;
    const char *name = luaL_checkstring(L, 1);
    filename = findfile4lua(L, name);
    if (!filename) {
        lua_unlock(L);
        return 1; /* module not found in this path */
    }
    int autosave = 0;
    lua_getfield(L, lua_upvalueindex(1), AUTO_SAVE);
    autosave = lua_toboolean(L, -1);
    lua_pop(L, 1);
    int isbin = isBinaryPath(filename);
    int result;

    if (real_loadfile(L, filename, name) == LUA_OK) {
        LOGI("searcher_Lua---compile file success %s", filename);
        result = return_success(L, filename, autosave && !isbin);
        lua_unlock(L);
        return result;
    }
    // 加载失败
    if (isbin) {
        LOGI("searcher_Lua---compile bin file failed. remove %s", filename);
        //删除二进制文件
        remove(filename);
#if defined(J_API_INFO)
        m_malloc(filename, (strlen(filename) + 1) * sizeof(char), 0);
#else
        free(filename);
#endif
        filename = findfile4lua(L, name);
        if (!filename) {
            lua_unlock(L);
            return 1; /* module not found in this path */
        }
        if (real_loadfile(L, filename, name)) {
            result = return_failed(L, filename);
            lua_unlock(L);
            return result;
        }
        result = return_success(L, filename, autosave);
        lua_unlock(L);
        return result;
    }
    result = return_failed(L, filename);
    lua_unlock(L);
    return result;
}

/**
 * 参数1 : name (string)
 * 返回2 : -1: string, -2: function(or nil)
 */
int searcher_java(lua_State *L) {
    JNIEnv *env;
    int need = getEnv(&env);
    lua_lock(L);
    const char *name = lua_tostring(L, -1);
    jstring str = newJString(env, name);
    jobject r = (*env)->CallStaticObjectMethod(env, Globals, Globals__onLuaRequire, (jlong) L, str);
    FREE(env, str);
    if (!r) {
        if (need) detachEnv();
        lua_pushfstring(L,
                        "call Globals.____onLuaRequire method return null for module %s",
                        name);
        lua_unlock(L);
        return 1;
    }
    int isstr = (*env)->IsInstanceOf(env, r, StringClass);

    if (isstr) // return a path(string), call real_loadfile
    {
        const char *path = GetString(env, r);
        if (real_loadfile(L, path, name) == LUA_OK) {
            if (!isBinaryPath(path) && isAutosave(L)) {
                char *sp = getBinaryPath(path);
                LOGI("compile file success and save bin to %s", sp);
                saveProto(L, GET_PROTO(L), sp);
                m_malloc(sp, (strlen(sp) + 1) * sizeof(char), 0);
            }
            lua_pushstring(L, path);
            ReleaseChar(env, r, path);
            FREE(env, r);
            if (need) detachEnv();
            lua_unlock(L);
            return 2;
        }
        const char *err = lua_pushfstring(L, "error loading module '%s' from file '%s':\n\t%s",
                                          name, path, lua_tostring(L, -1));
        ReleaseChar(env, r, path);
        FREE(env, r);
        lua_pop(L, 2);
        if (need) detachEnv();
        lua_unlock(L);
        return luaL_error(L, err);
    } else // return file content (byte array ), call real_loadbuffer
    {
        jbyteArray arr = (jbyteArray) r;
        jbyte *nd = (*env)->GetByteArrayElements(env, arr, 0);
        size_t size = (size_t) GetArrLen(env, arr);
        int isbin = isBinaryData(nd);
        int r = real_loadbuffer(L, (char *) nd, size, name);
        (*env)->ReleaseByteArrayElements(env, arr, nd, 0);
        FREE(env, arr);
        if (r == LUA_OK) {
            if (!isbin) {
                const char *bp = getAutoSavePath(L);
                if (bp) {
                    bp = lua_pushfstring(L, "%s" LUA_DIRSEP "%s.lua" BINARY_SUFFIX_END, bp,
                                         luaL_gsub(L, name, ".", LUA_DIRSEP));
                    LOGI("compile data success and save bin to %s", bp);
                    lua_pop(L, 2);
                    saveProto(L, GET_PROTO(L), bp);
                }
            }
            lua_pushstring(L, name);
            if (need) detachEnv();
            lua_unlock(L);
            return 2;
        }
        if (need) detachEnv();
        lua_unlock(L);
        return luaL_error(L, "error loading module '%s' from data:\n\t%s", name,
                          lua_tostring(L, -1));
    }
}

/**
 * require时调用
 */
int searcher_Lua_asset(lua_State *L) {
    const char *name = luaL_checkstring(L, 1);
    name = luaL_gsub(L, name, ".", LUA_DIRSEP);
    const char *filename = formatstr("%s.lua", name);
    AD ad;
    int code = initAssetsData(&ad, filename);
#if defined(J_API_INFO)
    m_malloc((void *) filename, (strlen(filename) + 1) * sizeof(char), 0);
#else
    free(filename);
#endif
    if (code != AR_OK) {
        lua_pushfstring(L, "find %s from native asset failed, code: %d", name, code);
        return 1;
    }

    if (opensaes) {
        unsigned short preReadLen;
        const char *preData = preReadData(&ad, HEADER_LEN + SOURCE_LEN, &preReadLen);
        if (!preData) {
            destroyAssetsData(&ad);
            lua_pushfstring(L, "preload %s from native asset failed!", name);
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

    code = lua_load(L, getFromAssets, &ad, name, NULL);
    destroyAssetsData(&ad);

    if (code == LUA_OK) {
        lua_pushvalue(L, 1);
        return 2;
    }
    lua_pushfstring(L, "error loading module '%s' from asset '%s', code: %d",
                      name, name, code);
    return 1;
}