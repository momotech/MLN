/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import android.content.res.AssetManager;

import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2019/2/22
 * <p>
 * jni层类，不对外
 *
 * @see LuaValue
 * @see LuaTable
 * @see Globals
 * @see LuaFunction
 */
@LuaApiUsed
class LuaCApi {
    private static Boolean is32bit;

    static {
        try {
            System.loadLibrary("luajapi");
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    static boolean is32bit() {
        if (is32bit == null) {
            is32bit = _check32bit();
        }
        return is32bit;
    }

    static native void _setAndroidVersion(int v);

    private static native boolean _check32bit();

    //<editor-fold desc="isolate">
    static native void _callMethod(long L, long method, long args);

//    static native void _isolateOnThreadRun(long args);
    //</editor-fold>

    //<editor-fold desc="Pre register">
    static native void _preRegisterUD(String className, String[] methods);

    static native void _preRegisterStatic(String className, String[] methods);
    //</editor-fold>

    static native long _lvmMemUse(long L);

    static native long _allLvmMemUse();

    static native long _globalObjectSize();

    static native void _logMemoryInfo();

    static native void _setGcOffset(int offset);

    static native void _setDatabasePath(String s);

    static native void _setAssetManager(AssetManager as);
    //<editor-fold desc="saes">
    static native boolean _isSAESFile(String path);

    static native void _openSAES(boolean open);
    //</editor-fold>

    //<editor-fold desc="for Globals">
    static native int _compileAndSave(long L, String file, String chunkName, byte[] data);

    static native int _compilePathAndSave(long L, String file, String src, String chunkName);

    static native int _savePreloadData(long L, String savePath, String chunkname);

    static native int _saveChunk(long L, String savePath, String chunkname);

    static native long _createLState(boolean debug);

    static native void _setBasePath(long L, String basePath, boolean autoSave);

    static native void _setSoPath(long L, String path);

    static native void _close(long L_state);

    static native void _reset(long L_state);

    static native int _registerIndex();

    static native LuaValue[] _dumpStack(long L_state);

    static native void _removeStack(long L, int stackIndex);

    static native void _pop(long L, int num);

    static native int _getTop(long L);

    static native void _lgc(long L);

    static native int _removeNativeValue(long L, long k, int type);
    //</editor-fold>

    //<editor-fold desc="load and execute">
    static native int _startDebug(long L, byte[] debug, String ip, int port);

    static native int _loadData(long L_state, String chunkName, byte[] data);

    static native int _loadFile(long L_state, String path, String chunkName);

    static native int _doLoadedData(long L_state);

    static native boolean _setMainEntryFromPreload(long L, String chunkname);

    static native void _preloadData(long L, String chunkName, byte[] data);

    static native void _preloadFile(long L, String chunkName, String path);
    //</editor-fold>

    //<editor-fold desc="Table api">
    static native long _createTable(long L);

    static native int _getTableSize(long L, long table);

    static native void _clearTableArray(long L, long table, int from, int to);

    static native void _setTableNumber(long L, long table, int k, double n);

    static native void _setTableBoolean(long L, long table, int k, boolean v);

    static native void _setTableString(long L, long table, int k, String v);

    static native void _setTableNil(long L, long table, int k);

    static native void _setTableChild(long L, long table, int k, Object child);

    static native void _setTableChild(long L, long table, int k, long child, int type);

    static native void _setTableNumber(long L, long table, String k, double n);

    static native void _setTableBoolean(long L, long table, String k, boolean v);

    static native void _setTableString(long L, long table, String k, String v);

    static native void _setTableNil(long L, long table, String k);

    static native void _setTableChild(long L, long table, String k, Object child);

    static native void _setTableChild(long L, long table, String k, long child, int type);

    static native Object _getTableValue(long L, long table, int k);

    static native Object _getTableValue(long L, long table, String k);

    /**
     * 返回 {@link LuaTable.Entrys}
     */
    static native Object _getTableEntry(long L, long table);

    static native boolean _startTraverseTable(long L, long table);

    static native LuaValue[] _nextEntry(long L, boolean isGlobal);

    static native void _endTraverseTable(long L);
    //</editor-fold>

    //<editor-fold desc="function">
    static native LuaValue[] _invoke(long global, long gk, LuaValue[] params, int returnCount);

    static native void _registerStaticClassSimple(long L, String javaClassName, String luaClassName, String lpcn);

    static native void _registerJavaMetatable(long L, String jcn, String lcn);

    static native void _registerUserdata(long L, String lcn, String lpcn, String jcn);

    static native void _registerAllUserdata(long L, String[] lcns, String[] lpcns, String[] jcns, boolean[] lazy);

    static native void _registerUserdataLazy(long L, String lcn, String lpcn, String jcn);

    static native void _registerNumberEnum(long L, String lcn, String[] keys, double[] values);

    static native void _registerStringEnum(long L, String lcn, String[] keys, String[] values);

    /**
     * Global使用，创建一个userdata，并加入到Global表里
     *
     * @param name    key名称
     * @param luaName userdata的名称
     * @return 对应userdata实例
     */
    static native Object _createUserdataAndSet(long L, String name, String luaName, LuaValue[] params);
    //</editor-fold>
}
