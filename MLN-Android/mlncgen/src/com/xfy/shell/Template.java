package com.xfy.shell;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public interface Template {

    public static final String Start =
            "//\n" +
            "\n" +
            "#include <jni.h>\n" +
            "#include \"lauxlib.h\"\n" +
            "#include \"../juserdata.h\"\n" +
            "#include \"../jinfo.h\"\n" +
            "#include \"../juserdata.h\"\n" +
            "#include \"../m_mem.h\"\n" +
            "\n" +
            "#define PRE JNIEnv *env;                                            \\\n" +
            "            getEnv(&env);                                           \\\n" +
            "            UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);  \\\n" +
            "            jobject jobj = getUserdata(env, L, ud);                 \\\n" +
            "            if (!jobj) {                                            \\\n" +
            "                lua_pushfstring(L, \"get java object from java failed, id: %d\", ud->id); \\\n" +
            "                lua_error(L);                                       \\\n" +
            "                return 1;                                           \\\n" +
            "            }\n" +
            "\n\n";

    String DefineLuaClassName = "#define LUA_CLASS_NAME \"%s\"\n";

    String MethodCom = "\n" +
            "static jclass _globalClass;\n" +
            "//<editor-fold desc=\"method definition\">\n";
    String EditorEnd = "//</editor-fold>\n";

    public static final String METAStart = "/**\n" +
            " * -1: metatable\n" +
            " */\n" +
            "static void fillUDMetatable(lua_State *L) {\n" +
            "    static const luaL_Reg _methohds[] = {\n";

    public static final String METAEnd = "            {NULL, NULL}\n" +
            "    };\n" +
            "    const luaL_Reg *lib = _methohds;\n" +
            "    for (; lib->func; lib++) {\n" +
            "        lua_pushstring(L, lib->name);\n" +
            "        lua_pushcfunction(L, lib->func);\n" +
            "        lua_rawset(L, -3);\n" +
            "    }\n" +
            "}\n";

    public static final String JNIStart = "//<editor-fold desc=\"JNI methods\">\n" +
            "/**\n" +
            " * java层需要初始化的class静态调用\n" +
            " * 初始化各种jmethodID\n" +
            " */\n" +
            "JNIEXPORT void JNICALL Java_${ClassName}__1init\n" +
            "        (JNIEnv *env, jclass clz) {\n" +
            "    _globalClass = GLOBAL(env, clz);\n";

    public static final String JNIEnd = "}\n" +
            "/**\n" +
            " * java层需要将此ud注册到虚拟机里\n" +
            " * @param l 虚拟机\n" +
            " */\n" +
            "JNIEXPORT void JNICALL Java_${ClassName}__1register\n" +
            "        (JNIEnv *env, jclass o, jlong l) {\n" +
            "    lua_State *L = (lua_State *)l;\n" +
            "\n" +
            "    char *metaname = getUDMetaname(LUA_CLASS_NAME);\n" +
            "    luaL_newmetatable(L, metaname);\n" +
            "    SET_METATABLE(L);\n" +
            "    /// -1: metatable\n" +
            "    fillUDMetatable(L);\n" +
            "\n" +
            "    jclass clz = _globalClass;\n" +
            "\n" +
            "    /// 设置gc方法\n" +
            "    pushUserdataGcClosure(env, L, clz);\n" +
            "    /// 设置需要返回bool的方法，比如__eq\n" +
            "    pushUserdataBoolClosure(env, L, clz);\n" +
            "    /// 设置__tostring\n" +
            "    pushUserdataTostringClosure(env, L, clz);\n" +
            "    lua_pop(L, 1);\n" +
            "\n" +
            "    pushConstructorMethod(L, clz, getConstructor(env, clz), metaname);\n" +
            "    lua_setglobal(L, LUA_CLASS_NAME);\n" +
            "\n" +
            "#if defined(J_API_INFO)\n" +
            "    m_malloc(metaname, (strlen(metaname) + 1) * sizeof(char), 0);\n" +
            "#else\n" +
            "    free(metaname);\n" +
            "#endif\n" +
            "}\n" +
            "//</editor-fold>\n";

    String IMPStart = "//<editor-fold desc=\"lua method implementation\">\n";
}
