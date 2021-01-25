/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.xfy.shell;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public interface Template {
    String BLANK = "{B}";
    String CONSTRUCTOR = "{PC}";

    String CreatedByGenerator = "//\n" +
            "// Created by Generator on ";

    String Start =
            "//\n" +
            "\n" +
            "#include <jni.h>\n" +
            "#include \"lauxlib.h\"\n" +
            "#include \"cache.h\"\n" +
            "#include \"statistics.h\"\n" +
            "#include \"jinfo.h\"\n" +
            "#include \"jtable.h\"\n";

    String PushNumberAndStringDef = "\n" +
            "static inline void push_number(lua_State *L, jdouble num) {\n" +
            "    lua_Integer li1 = (lua_Integer) num;\n" +
            "    if (li1 == num) {\n" +
            "        lua_pushinteger(L, li1);\n" +
            "    } else {\n" +
            "        lua_pushnumber(L, num);\n" +
            "    }\n" +
            "}\n" +
            "\n" +
            "static inline void push_string(JNIEnv *env, lua_State *L, jstring s) {\n" +
            "    const char *str = GetString(env, s);\n" +
            "    if (str)\n" +
            "        lua_pushstring(L, str);\n" +
            "    else\n" +
            "        lua_pushnil(L);\n" +
            "    ReleaseChar(env, s, str);\n" +
            "}\n";

    String DumpParams = "\n" +
            "static inline void dumpParams(lua_State *L, int from) {\n" +
            "    const int SIZE = 100;\n" +
            "    const int MAX = SIZE - 4;\n" +
            "    char type[SIZE] = {0};\n" +
            "    int top = lua_gettop(L);\n" +
            "    int i;\n" +
            "    int idx = 0;\n" +
            "    for (i = from; i <= top; ++i) {\n" +
            "        const char *n = lua_typename(L, lua_type(L, i));\n" +
            "        size_t len = strlen(n);\n" +
            "        if (len + idx >= MAX) {\n" +
            "            memcpy(type + idx, \"...\", 3);\n" +
            "            break;\n" +
            "        }\n" +
            "        if (i != from) {\n" +
            "            type[idx ++] = ',';\n" +
            "        }\n" +
            "        memcpy(type + idx, n, len);\n" +
            "        idx += len;\n" +
            "    }\n" +
            "    lua_pushstring(L, type);\n" +
            "}\n";

    String UserdataStart = Start +
            "#include \"juserdata.h\"\n" +
            "#include \"m_mem.h\"\n" +
            "\n" +
            "#define PRE if (!lua_isuserdata(L, 1)) {                            \\\n" +
            "        lua_pushstring(L, \"use ':' instead of '.' to call method!!\");\\\n" +
            "        lua_error(L);                                               \\\n" +
            "        return 1;                                                   \\\n" +
            "    }                                                               \\\n" +
            "            JNIEnv *env;                                            \\\n" +
            "            getEnv(&env);                                           \\\n" +
            "            UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);  \\\n" +
            "            jobject jobj = getUserdata(env, L, ud);                 \\\n" +
            "            if (!jobj) {                                            \\\n" +
            "                lua_pushfstring(L, \"get java object from java failed, id: %d\", ud->id); \\\n" +
            "                lua_error(L);                                       \\\n" +
            "                return 1;                                           \\\n" +
            "            }\n" +
            "\n" +
            "#define REMOVE_TOP(L) while (lua_gettop(L) > 0 && lua_isnil(L, -1)) lua_pop(L, 1);\n" +
            PushNumberAndStringDef +
            DumpParams;

    String StaticStart = Start +
            "\n" +
            "#define PRE JNIEnv *env;                                                        \\\n" +
            "            getEnv(&env);                                                       \\\n" +
            "            if (!lua_istable(L, 1)) {                                           \\\n" +
            "                lua_pushstring(L, \"use ':' instead of '.' to call method!!\");   \\\n" +
            "                return lua_error(L);                                            \\\n" +
            "            }\n" +
            "\n" +
            "#define REMOVE_TOP(L) while (lua_gettop(L) > 0 && lua_isnil(L, -1)) lua_pop(L, 1);\n" +
            "\n" +
            DumpParams;

    String GetArrayLength = "int size = (*env)->GetArrayLength(env, ret);\n";
    String GetPrimitiveArray = "%s *arr = (*env)->Get%sArrayElements(env, ret, 0);\n";
    String ReleasePrimitiveArray = "(*env)->Release%sArrayElements(env, ret, arr, 0);\n";

    String GetArrayElement = "(*env)->GetObjectArrayElement(env, i);";
    String GetObjectArray = "jobject t = " + GetArrayElement + "\n";

    String TraverseArr =
            BLANK + "int i;\n" +
            BLANK + "for (i = 0; i < size; ++i) {\n" +
            BLANK + "    %s\n" +
            BLANK + "}\n";

    String DefineLuaClassName = "#define LUA_CLASS_NAME \"%s\"\n";
    String DefineMultiLuaClassName = "#define LUA_CLASS_NAME%d \"%s\"\n";
    String DefineMetaName = "#define META_NAME METATABLE_PREFIX \"\" LUA_CLASS_NAME\n";

    String MethodCom = "\nstatic jclass _globalClass;\n";
    String ConstructorDefine = "static jmethodID _constructor%d;\n";
    String ConstructorFind = "_constructor%d = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, \"(%s)V\");\n";
    String ConstructorFunctionDefine =
            "static int _execute_new_ud(lua_State *L);\n" +
            "static int _new_java_obj(JNIEnv *env, lua_State *L);\n";

    String MethodDefineFolderStart = "//<editor-fold desc=\"method definition\">\n";
    String EditorEnd = "//</editor-fold>\n";

    String METAStart = "/**\n" +
            " * -1: metatable\n" +
            " */\n" +
            "static void fillUDMetatable(lua_State *L) {\n" +
            "    static const luaL_Reg _methohds[] = {\n";

    String UDMETAStart = "/**\n" +
            " * -1: metatable\n" +
            " */\n" +
            "static void fillUDMetatable(lua_State *L, const char *parentMeta) {\n" +
            "    static const luaL_Reg _methohds[] = {\n";

    String METAEnd = "            {NULL, NULL}\n" +
            "    };\n" +
            "    const luaL_Reg *lib = _methohds;\n" +
            "    for (; lib->func; lib++) {\n" +
            "        lua_pushstring(L, lib->name);\n" +
            "        lua_pushcfunction(L, lib->func);\n" +
            "        lua_rawset(L, -3);\n" +
            "    }\n" +
            "}\n";

    String UDMETAEnd = "            {NULL, NULL}\n" +
            "    };\n" +
            "    const luaL_Reg *lib = _methohds;\n" +
            "    for (; lib->func; lib++) {\n" +
            "        lua_pushstring(L, lib->name);\n" +
            "        lua_pushcfunction(L, lib->func);\n" +
            "        lua_rawset(L, -3);\n" +
            "    }\n\n" +
            "    if (parentMeta) {\n" +
            "        JNIEnv *env;\n" +
            "        getEnv(&env);\n" +
            "        setParentMetatable(env, L, parentMeta);\n" +
            "    }\n" +
            "}\n";

    String JNIStart = "//<editor-fold desc=\"JNI methods\">\n" +
            "#define JNIMETHODDEFILE(s) Java_${ClassName}_ ## s\n" +
            "/**\n" +
            " * java层需要初始化的class静态调用\n" +
            " * 初始化各种jmethodID\n" +
            " */\n" +
            "JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)\n" +
            "        (JNIEnv *env, jclass clz) {\n" +
            "    _globalClass = GLOBAL(env, clz);\n";

    String UserdataJNIEnd = "}\n" +
            "/**\n" +
            " * java层需要将此ud注册到虚拟机里\n" +
            " * @param l 虚拟机\n" +
            " * @param parent 父类，可为空\n" +
            " */\n" +
            "JNIEXPORT void JNICALL JNIMETHODDEFILE(_1register)\n" +
            "        (JNIEnv *env, jclass o, jlong l, jstring parent) {\n" +
            "    lua_State *L = (lua_State *)l;\n" +
            "\n" +
            "    u_newmetatable(L, META_NAME);\n" +
            "    /// get metatable.__index\n" +
            "    lua_pushstring(L, LUA_INDEX);\n" +
            "    lua_rawget(L, -2);\n" +
            "    /// 未初始化过，创建并设置metatable.__index\n" +
            "    if (!lua_istable(L, -1)) {\n" +
            "        lua_pop(L, 1);\n" +
            "        lua_pushvalue(L, -1);\n" +
            "        lua_pushstring(L, LUA_INDEX);\n" +
            "        lua_pushvalue(L, -2);\n" +
            "        /// -1:nt -2:__index -3:nt -4:mt\n" +
            "        /// mt.__index=nt\n" +
            "        lua_rawset(L, -4);\n" +
            "    }\n" +
            "    /// -1:nt -2: metatable\n" +
            "    const char *luaParent = GetString(env, parent);\n" +
            "    if (luaParent) {\n" +
            "        char *parentMeta = getUDMetaname(luaParent);\n" +
            "        fillUDMetatable(L, parentMeta);\n" +
            "#if defined(J_API_INFO)\n" +
            "        m_malloc(parentMeta, (strlen(parentMeta) + 1) * sizeof(char), 0);\n" +
            "#else\n" +
            "        free(parentMeta);\n" +
            "#endif\n" +
            "        ReleaseChar(env, parent, luaParent);\n" +
            "    } else {\n" +
            "        fillUDMetatable(L, NULL);\n" +
            "    }\n" +
            "\n" +
            "    jclass clz = _globalClass;\n" +
            "\n" +
            "    /// 设置gc方法\n" +
            "    pushUserdataGcClosure(env, L, clz);\n" +
            "    /// 设置需要返回bool的方法，比如__eq\n" +
            "    pushUserdataBoolClosure(env, L, clz);\n" +
            "    /// 设置__tostring\n" +
            "    pushUserdataTostringClosure(env, L, clz);\n" +
            "    lua_pop(L, 2);\n" +
            "\n" +
            CONSTRUCTOR +
            "}\n" +
            "//</editor-fold>\n";

    String PushNativeConstructor =
            "    lua_pushcfunction(L, _execute_new_ud);\n" +
            "    lua_setglobal(L, LUA_CLASS_NAME);\n";
    String PushMultiNativeConstructor =
                    "    lua_pushcfunction(L, _execute_new_ud);\n" +
                    "    lua_setglobal(L, LUA_CLASS_NAME%d);\n";
    String PushConstructor = "    pushConstructorMethod(L, clz, getConstructor(env, clz), META_NAME);\n" +
            "    lua_setglobal(L, LUA_CLASS_NAME);\n" +
            "\n";

    String StaticJNIEnd = "}\n" +
            "/**\n" +
            " * java层需要将此ud注册到虚拟机里\n" +
            " * @param l 虚拟机\n" +
            " * @param parent 父类，可为空\n" +
            " */\n" +
            "JNIEXPORT void JNICALL JNIMETHODDEFILE(_1register)\n" +
            "        (JNIEnv *env, jclass o, jlong l, jstring parent) {\n" +
            "    lua_State *L = (lua_State *)l;\n" +
            "\n" +
            "    lua_getglobal(L, LUA_CLASS_NAME);\n" +
            "    if (!lua_istable(L, -1)) {\n" +
            "        lua_pop(L, 1);\n" +
            "        lua_newtable(L);\n" +
            "    }\n" +
            "    /// -1:table\n" +
            "    const char *luaParent = GetString(env, parent);\n" +
            "    if (luaParent) {\n" +
            "        lua_getglobal(L, luaParent);\n" +
            "        if (!lua_istable(L, -1)) {\n" +
            "            lua_pop(L, 1);\n" +
            "            lua_newtable(L);\n" +
            "            lua_pushvalue(L, -1);\n" +
            "            lua_setglobal(L, luaParent);\n" +
            "        }\n" +
            "        /// -1:parent -2:mytable\n" +
            "        setParentTable(L, -2, -1);\n" +
            "        lua_pop(L, 1);\n" +
            "        ReleaseChar(env, parent, luaParent);\n" +
            "    }\n" +
            "    /// -1:table\n" +
            "    fillUDMetatable(L);\n" +
            "    lua_setglobal(L, LUA_CLASS_NAME);\n" +
            "}\n" +
            "//</editor-fold>\n";

    String IMPStart = "//<editor-fold desc=\"lua method implementation\">\n";

    String LUA_IS_NIL = "lua_isnil(L, %d)";
    String LUA_IS_NONE_OR_NIL = "lua_isnoneornil(L, %d)";
    String LUA_IS_BOOL = "lua_isboolean(L, %d)";
    String LUA_IS_NUMBER = "lua_type(L, %d) == LUA_TNUMBER";
    String LUA_IS_STRING = "lua_type(L, %d) == LUA_TSTRING";
    String LUA_IS_FUNCTION = "lua_isfunction(L, %d)";
    String LUA_IS_USERDATA = "lua_isuserdata(L, %d)";
    String LUA_IS_TABLE = "lua_istable(L, %d)";
    String LUA_SET_TOP = "lua_settop(L, %d)";
    String LUA_CHECK_TYPE = "luaL_checktype(L, %d, %s)";
    String LUA_CHECK_FUNCTION = "luaL_checktype(L, %d, LUA_TFUNCTION)";
    String LUA_CHECK_TABLE = "luaL_checktype(L, %d, LUA_TTABLE)";
    String LUA_CHECK_USERDATA = "luaL_checktype(L, %d, LUA_TUSERDATA)";
    String TO_GNV = "copyValueToGNV(L, %d)";
    String LUA_FUNCTION = "LUA_TFUNCTION";
    String LUA_TABLE = "LUA_TTABLE";
    String LUA_USERDATA = "LUA_TUSERDATA";
    String GET_GNV = "getValueFromGNV(L, (ptrdiff_t) ret, %s);\n";

    String IF_LUA_PARAMS_COUNT = "if (lua_gettop(L) == %d) {\n";

    String CallbackInclude = "//\n" +
            "\n" +
            "#include \"lua.h\"\n" +
            "#include \"jfunction.h\"\n" +
            "#include <jni.h>\n";
    String CallDef = "#define _Call(R) JNIEXPORT R JNICALL\n";
    String MethodDef = "#define _Method(s) Java_%s_ ## s\n";
    String Pre4ParamsDef = "#define _PRE4PARAMS JNIEnv *env, jobject jobj, jlong Ls, jlong function\n";

    /**
     * format : pName, Type, pName, Type, pName, return
     */
    String PUSH_NATIVE_VALUE =
                    "getValueFromGNV(L, (ptrdiff_t) %s, %s);\n" +
                    BLANK + "if (%s && lua_isnil(L, -1)) {\n" +
                    BLANK + "    throwInvokeError(env, \"%s %s is destroyed.\");\n" +
                    BLANK + "    lua_settop(L, oldTop);\n" +
                    BLANK + "    lua_unlock(L);\n" +
                    BLANK + "    return %s;\n" +
                    BLANK + "}\n";

    String catchJavaException =
            BLANK + "if (catchJavaException(env, L, LUA_CLASS_NAME \".%s\")) {\n" +
            "%s"+
            BLANK + "    return lua_error(L);\n" +
            BLANK + "}\n";

    String statisticDefine = "#ifdef STATISTIC_PERFORMANCE\n";
    String endif = "#endif\n";

    String statisticHeader = statisticDefine +
            "#include <time.h>\n" +
            "#define _get_milli_second(t) ((t)->tv_sec*1000.0 + (t)->tv_usec / 1000.0)\n" +
            endif;

    String statisticStart = statisticDefine +
            "    struct timeval start = {0};\n" +
            "    struct timeval end = {0};\n" +
            "    gettimeofday(&start, NULL);\n" +
            endif;

    String staticStatisticEnd = statisticDefine +
            BLANK + "gettimeofday(&end, NULL);\n" +
            BLANK + "staticMethodCall(LUA_CLASS_NAME, \"%s\", _get_milli_second(&end) - _get_milli_second(&start));\n" +
            endif;

    String userdataStatisticEnd = statisticDefine +
            BLANK + "gettimeofday(&end, NULL);\n" +
            BLANK + "userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), \"%s\", _get_milli_second(&end) - _get_milli_second(&start));\n" +
            endif;

    String ExecuteNewUdImpl =
            "static int _execute_new_ud(lua_State *L) {\n" +
            "#ifdef STATISTIC_PERFORMANCE\n" +
            "    struct timeval start = {0};\n" +
            "    struct timeval end = {0};\n" +
            "    gettimeofday(&start, NULL);\n" +
            "#endif\n" +
            "\n" +
            "    JNIEnv *env;\n" +
            "    int need = getEnv(&env);\n" +
            "\n" +
            "    if (_new_java_obj(env, L)) {\n" +
            "        if (need) detachEnv();\n" +
            "        lua_error(L);\n" +
            "        return 1;\n" +
            "    }\n" +
            "\n" +
            "    luaL_getmetatable(L, META_NAME);\n" +
            "    lua_setmetatable(L, -2);\n" +
            "\n" +
            "    if (need) detachEnv();\n" +
            "\n" +
            "#ifdef STATISTIC_PERFORMANCE\n" +
            "    gettimeofday(&end, NULL);\n" +
            "    double offset = _get_milli_second(&end) - _get_milli_second(&start);\n" +
            "    userdataMethodCall(LUA_CLASS_NAME, InitMethodName, offset);\n" +
            "#endif\n" +
            "\n" +
            "    return 1;\n" +
            "}";
    String NewJavaObjImpl = "static int _new_java_obj(JNIEnv *env, lua_State *L) {\n";
    String NewJavaObjImpl_Top =
            "    int pc = lua_gettop(L);\n" +
            "    jobject javaObj = NULL;\n";
    String NewJavaObjPre = "javaObj = (*env)->NewObject(env, _globalClass, _constructor%d, (jlong) L";
    String NewJavaObjImplEnd = "\n" +
            "    char *info = joinstr(LUA_CLASS_NAME, InitMethodName);\n" +
            "\n" +
            "    if (catchJavaException(env, L, info)) {\n" +
            "        if (info)\n" +
            "            m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);\n" +
            "        FREE(env, javaObj);\n" +
            "        return 1;\n" +
            "    }\n" +
            "    if (info)\n" +
            "        m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);\n" +
            "\n" +
            "    UDjavaobject ud = (UDjavaobject) lua_newuserdata(L, sizeof(javaUserdata));\n" +
            "    ud->id = getUserdataId(env, javaObj);\n" +
            "    if (isStrongUserdata(env, _globalClass)) {\n" +
            "        setUDFlag(ud, JUD_FLAG_STRONG);\n" +
            "        copyUDToGNV(env, L, ud, -1, javaObj);\n" +
            "    }\n" +
            "    FREE(env, javaObj);\n" +
            "    ud->refCount = 0;\n" +
            "\n" +
            "    ud->name = lua_pushstring(L, META_NAME);\n" +
            "    lua_pop(L, 1);\n" +
            "    return 0;\n" +
            "}";

    String ConstructorParamsCountError =
            "        lua_pushstring(L, LUA_CLASS_NAME \"构造函数有: %s，当前参数个数不支持任意一种\");\n" +
            "        return lua_error(L);\n";

    /**
     * methodName, paramCount, paramTypes
     */
    String MethodParamsCountError =
            BLANK + "dumpParams(L, 2);\n" +
            BLANK + "lua_pushfstring(L, LUA_CLASS_NAME \".%s函数%d个参数有: %s ，当前参数不匹配 (%%s)\", lua_tostring(L, -1));\n";
    String ReturnLuaError = "return lua_error(L);\n";
}