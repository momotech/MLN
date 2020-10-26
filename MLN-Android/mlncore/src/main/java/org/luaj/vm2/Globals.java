/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import android.content.res.AssetManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import androidx.collection.LongSparseArray;

import com.immomo.mlncore.MLNCore;

import org.luaj.vm2.exception.InvokeError;
import org.luaj.vm2.exception.UndumpError;
import org.luaj.vm2.utils.IGlobalsUserdata;
import org.luaj.vm2.utils.LuaApiUsed;
import org.luaj.vm2.utils.NativeLog;
import org.luaj.vm2.utils.OnEmptyMethodCalledListener;
import org.luaj.vm2.utils.ResourceFinder;
import org.luaj.vm2.utils.SignatureUtils;

import java.io.File;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by Xiong.Fangyu on 2019/2/22
 * <p>
 * Global表
 * <p>
 * @see #createLState               创建全局表
 * @see #setResourceFinder          设置资源查找器
 * @see #loadString                 加载Lua源码
 * @see #loadData                   加载Lua源码或二进制码
 * @see #callLoadedData             执行已加载成功的Lua源码或二进制码
 * @see #getState                   获取加载或执行的状态码
 * @see #createUserdataAndSet       在全局表中注册一个userdata实例
 * @see #destroy()                  销毁当前虚拟机
 * <p>
 *
 * 资源查找流程：
 * 1、native层，通过接口{@link #setBasePath(String, boolean)}获取根路径，在根路径下查找，若失败，进入java层查找
 * 2、java层，{@link #__onLuaRequire(long, String)} {@link #onRequire(String)}，通过设置的{@link ResourceFinder}查找
 */
@LuaApiUsed
public final class Globals extends LuaTable {
    /**
     * luac 版本号
     */
    public static final int LUAC_VERSION = 83;
    /**
     * Luac 版本
     */
    public static final String LUAC_VERSION_STR = "5.2.4";
    /**
     * Lua所有状态码
     */
    public static final int LUA_OK = 0;
    public static final int LUA_YIELD = 1;
    public static final int LUA_ERRRUN = 2;
    public static final int LUA_ERRSYNTAX = 3;
    public static final int LUA_ERRMEM = 4;
    public static final int LUA_ERRGCMM = 5;
    public static final int LUA_ERRERR = 6;
    public static final int LUA_ERRINJAVA = -1;
    public static final int LUA_CALLING = 100;
    /**
     * 统计开关
     */
    public static final char STATISTIC_BRIDGE = 1;
    public static final char STATISTIC_REQUIRE = 2;
    /**
     * 标记底层库是否load完成
     */
    private static boolean init;
    /**
     * 标记底层库的size_t是否是32位
     */
    private static boolean is32bit;
    /**
     * 表示虚拟机状态刚初始化，并未加载脚本或执行脚本
     */
    private static final int JUST_INIT = Integer.MIN_VALUE;
    /**
     * GC间隔时间，默认10s
     * @see #gc()
     * @see #removeStack(LuaValue)
     */
    private static long LUA_GC_OFFSET = 10000;
    /**
     * 默认销毁100个lua对象将执行gc
     * @see #gc()
     * @see #removeStack(LuaValue)
     */
    private static int LUA_GC_NUM_VALUES = 100;

    /**
     * Naive注册表栈位置
     * 取地址最大值
     */
    final static long GLOBALS_INDEX = 0xffffffffffffffffL;

    /**
     * 虚拟机native地址
     */
    long L_State;
    /**
     * 父虚拟机native地址
     * 若不为0，表示由isolate创建
     */
    final long parent_L_State;
    /**
     * 标记正在调用的lua函数个数
     * @see LuaFunction#invoke
     */
    long calledFunction = 0;
    /**
     * 当前虚拟机加载的脚本状态、或执行脚本状态
     */
    private int state = JUST_INIT;
    /**
     * 错误日志
     */
    private String errorMsg = null;
    /**
     * 异常
     */
    private Throwable error = null;
    /**
     * require错误信息
     * @see #__onLuaRequire(long, String)
     * @see #onRequire
     */
    private StringBuilder requireErrorMsg = null;
    /**
     * 资源寻找器，Lua脚本调用require时需要
     * 优先级比{@link #resourceFinders}高
     *
     * @see #setResourceFinder(ResourceFinder)
     * @see #__onLuaRequire(long, String)
     * @see #onRequire(String)
     */
    private ResourceFinder resourceFinder;
    /**
     * 资源寻找器，Lua脚本调用require时需要
     *
     * 低优先
     *
     * @see #addResourceFinder(ResourceFinder)
     * @see #__onLuaRequire(long, String)
     * @see #onRequire(String)
     */
    private Set<ResourceFinder> resourceFinders;
    /**
     * class -> luaClassName
     */
    private final HashMap<Class, String> luaClassNameMap;
    /**
     * 全局用户信息
     */
    private IGlobalsUserdata javaUserdata;
    /**
     * 虚拟机销毁监听
     */
    private List<OnDestroyListener> onDestroyListeners;
    /**
     * 此虚拟机是否可debug
     */
    private boolean debuggable;
    /**
     * 此虚拟机是否已经加载了debug文件
     */
    private boolean debugOpened;
    /**
     * 创建线程
     */
    private Thread mainThread;
    /**
     * 若有消息队列，则创建handler
     */
    Handler handler;
    /**
     * userdata缓存
     */
    final UserdataCache userdataCache;
    /**
     * @see #setBasePath(String, boolean)
     * @see #__onNativeCreateGlobals(long, long, boolean)
     */
    private String basePath;
    /**
     * @see #setSoPath(String)
     * @see #__onNativeCreateGlobals(long, long, boolean)
     */
    private String soPath;
    /**
     * 是否是全局虚拟机
     */
    private boolean isGlobal;
    /**
     * 上一次执行lua gc时间
     */
    private long lastGcTime = 0;
    /**
     * gc中
     */
    private boolean inGC = false;
    /**
     * 已被销毁的个数
     */
    private int destroyedValues = 0;
    /**
     * 是否正在使用中
     */
    private boolean running;
    /**
     * 唯一标示符
     */
    private final String TAG;

    /**
     * 保存Native虚拟机指针和Java Globals表对应关系
     *
     * @see #createLState(boolean)
     * @see #getGlobalsByLState(long)
     */
    private static LongSparseArray<Globals> cache = new LongSparseArray<>();
    /**
     * 全局虚拟机
     */
    private static LongSparseArray<Globals> g_cahce = new LongSparseArray<>();
    /**
     * 空方法回调
     */
    private static OnEmptyMethodCalledListener onEmptyMethodCalledListener;
    /**
     * 开启虚拟机统计
     * @see #setStatistic
     * @see #STATISTIC_BRIDGE
     * @see #STATISTIC_REQUIRE
     */
    private static char statisticsStatus;

    /**
     * @see #createLState(boolean)
     */
    private Globals(long L_State, long parent_L_State) {
        super(GLOBALS_INDEX);
        userdataCache = new UserdataCache();
        running = false;
        mainThread = Thread.currentThread();
        if (Looper.myLooper() != null) {
            handler = new Handler();
        }
        this.L_State = L_State;
        luaClassNameMap = new HashMap<>();
        this.parent_L_State = parent_L_State;
        TAG = "tag_" + hashCode();
    }

    //<editor-fold desc="public Method">

    //<editor-fold desc="static Method">

    /**
     * 判断底层库是否初始化成功
     */
    public static boolean isInit() {
        if (!init) {
            try {
                is32bit = LuaCApi.is32bit();
                LuaCApi._setAndroidVersion(Build.VERSION.SDK_INT);
                init = true;
            } catch (Throwable ignore) {
                init = false;
            }
        }
        return init;
    }

    /**
     * 判断平台是否是32位平台
     */
    @Deprecated
    public static boolean isIs32bit() {
        return is32bit;
    }

    /**
     * 判断平台是否是32位平台
     */
    public static boolean is32bit() {
        return is32bit;
    }

    /**
     * 打开统计bridge或require调用
     * @see #STATISTIC_BRIDGE
     * @see #STATISTIC_REQUIRE
     */
    public static void setStatistic(char status) {
        if (status != STATISTIC_BRIDGE
                && status != STATISTIC_REQUIRE
                && status != (STATISTIC_REQUIRE + STATISTIC_BRIDGE)
                && status != 0)
            return;
        statisticsStatus = status;
        LuaCApi._setStatisticsOpen(statisticsStatus != 0);
    }

    /**
     * 添加统计bridge或require调用
     * @see #STATISTIC_BRIDGE
     * @see #STATISTIC_REQUIRE
     */
    public static void addStatisticStatus(char status) {
        if (status != STATISTIC_BRIDGE && status != STATISTIC_REQUIRE)
            return;
        if (statisticsStatus == 0) {
            LuaCApi._setStatisticsOpen(true);
        }
        statisticsStatus = (char) (statisticsStatus | status);
    }

    /**
     * 是否打开了统计开关
     */
    public static boolean isOpenStatistics() {
        return ((statisticsStatus & STATISTIC_BRIDGE) == STATISTIC_BRIDGE)
                || ((statisticsStatus & STATISTIC_REQUIRE) == STATISTIC_REQUIRE);
    }

    /**
     * 通知打印统计信息
     */
    public static void notifyStatisticsCallback() {
        if ((statisticsStatus & STATISTIC_BRIDGE) == STATISTIC_BRIDGE)
            LuaCApi._notifyStatisticsCallback();
        if ((statisticsStatus & STATISTIC_REQUIRE) == STATISTIC_REQUIRE)
            LuaCApi._notifyRequireCallback();
    }

    /**
     * 尝试执行所有虚拟机的full gc
     * 只尝试非全局global
     *
     * @param num 尝试full gc虚拟机的个数
     *            -2：全部尝试full gc
     */
    public static void tryFullGc(int num) {
        if (num == 0) return;

        long now = System.currentTimeMillis();
        for (int i = 0, l = cache.size(); i < l; i ++) {
            final Globals g = cache.valueAt(i);
            if (g.canGc(now)) {
                num--;
                g.post(new Runnable() {
                    @Override
                    public void run() {
                        g.gc();
                    }
                });

                if (num == 0)
                    return;
            }
        }
    }

    /**
     * 判断文件是否被加密过
     */
    public static boolean isENFile(String p) {
        return LuaCApi._isSAESFile(p);
    }

    /**
     * 是否打开文件加密
     * 打开后，读取文件会判断是否是加密文件，写入文件会写入加密数据
     * 关闭后，读写文件都不使用加密
     * @param open false default
     */
    public static void openSAES(boolean open) {
        LuaCApi._openSAES(open);
    }

    /**
     * 设置AssetManager，让native层有能力读取数据
     */
    public static void setAssetManagerForNative(AssetManager am) {
        LuaCApi._setAssetManager(am);
    }

    /**
     * 创建Lua虚拟机，并返回Global表
     *
     * @return 返回Global表
     */
    public static Globals createLState(boolean debuggable) {
        long vmPointer = LuaCApi._createLState(debuggable);
        Globals g = new Globals(vmPointer, 0);
        g.setSoPath(LuaConfigs.soPath);
        g.debuggable = debuggable;
        saveGlobals(g);
        return g;
    }

    /**
     * 为每个Bridge注册空方法，调用空方法不会报错，会返回调用者本身
     * 回调用{@link #__onEmptyMethodCall(long, String, String)}
     */
    public static void preRegisterEmptyMethods(String... methods) {
        LuaCApi._preRegisterEmptyMethods(methods);
    }

    /**
     * 提前加载userdata
     */
    public static void preRegisterUserdata(String clz, String... methods) {
        LuaCApi._preRegisterUD(clz, methods);
    }

    /**
     * 提前加载static
     */
    public static void preRegisterStatic(String clz, String... methods) {
        LuaCApi._preRegisterStatic(clz, methods);
    }

    /**
     * 缓存虚拟机
     */
    private static void saveGlobals(Globals g) {
        if (g.isGlobal) {
            g_cahce.put(g.L_State, g);
        } else {
            cache.put(g.L_State, g);
        }
    }

    /**
     * lua中使用isolate，将在native层创建虚拟机
     * 回调该方法
     * @param p_vm  父虚拟机
     * @param vm    当前虚拟机native层指针
     * @param debuggable 能否debug
     */
    @LuaApiUsed
    static void __onNativeCreateGlobals(long p_vm, long vm, boolean debuggable) {
        Globals g = new Globals(vm, p_vm);
        g.debuggable = debuggable;
        /// 全局Globals
        if (p_vm == 0) {
            g.isGlobal = true;
            g.setBasePath(LuaConfigs.soPath, false);
            addAllPathRFFromGlobals(g);
        } else {
            Globals parent = getGlobalsByLState(p_vm);
            g.setJavaUserdata(parent.javaUserdata);
            g.setBasePath(parent.basePath, false);
            g.setSoPath(parent.soPath);
            g.setResourceFinder(parent.resourceFinder);
            if (parent.resourceFinders != null)
                g.resourceFinders = new HashSet<>(parent.resourceFinders);
        }
        saveGlobals(g);
        MLNCore.onNativeCreateGlobals(g, p_vm == 0);
    }

    /**
     * lua中使用isolate创建的虚拟机会自动销毁，销毁时回调
     * @param vm 虚拟机native层指针
     */
    @LuaApiUsed
    static void __onGlobalsDestroyInNative(long vm) {
        Globals globals = null;
        int index = cache.indexOfKey(vm);
        if (index >= 0) {
            globals = cache.valueAt(index);
            cache.removeAt(index);
        } else {
            index = g_cahce.indexOfKey(vm);
            if (index > 0) {
                globals = g_cahce.valueAt(index);
                g_cahce.removeAt(index);
            }
        }
        if (globals != null) {
            globals.destroy();
        }
    }

    /**
     * 通过Native虚拟机指针获取Java Globals表
     * 必须通过{@link #createLState(boolean)}创建的虚拟机才能返回对应的表
     *
     * @param state Native lua_State指针
     * @return Globals表
     * @see #createLState(boolean)
     */
    public static Globals getGlobalsByLState(long state) {
        Globals g = cache.get(state);
        if (g == null) g = g_cahce.get(state);
        return g;
    }

    /**
     * 返回所有的虚拟机指针
     */
    public static String debugGlobalsPointers() {
        int count = cache.size();
        StringBuilder sb = new StringBuilder("normal globals pointers:[");
        for (int i = 0; i < count; i ++) {
            long p = cache.keyAt(i);
            if (i == 0) {
                sb.append(Long.toHexString(p));
            } else {
                sb.append(',').append(Long.toHexString(p));
            }
        }
        sb.append(']')
                .append("\nspecial globals pointers:[");
        count = g_cahce.size();
        for (int i = 0; i < count; i ++) {
            long p = g_cahce.keyAt(i);
            if (i == 0) {
                sb.append(Long.toHexString(p));
            } else {
                sb.append(',').append(Long.toHexString(p));
            }
        }
        return sb.append(']').toString();
    }

    /**
     * 获取正在运行中的lua虚拟机数量
     */
    public static int getLuaVmSize() {
        return cache.size() + g_cahce.size();
    }

    /**
     * 获取所有lua虚拟机使用的内存量，单位Byte
     * @return 如果编译时，没有打开J_API_INFO编译选项，则返回为0
     * @see #getLVMMemUse() 获取单个虚拟机的内存使用量
     */
    public static long getAllLVMMemUse() {
        return LuaCApi._allLvmMemUse();
    }

    /**
     * 打印native层泄漏内存信息
     * 如果编译时，没有打开J_API_INFO编译选项，则不会有信息
     */
    public static void logMemoryLeakInfo() {
        LuaCApi._logMemoryInfo();
    }

    /**
     * 设置lua gc回调java gc时间间隔
     * 若小于等于0，表示关闭回调
     * @see #__onLuaGC(long)
     * @param offset <=0 mean close
     */
    public static void setGcOffset(int offset) {
        LuaCApi._setGcOffset(offset);
    }

    /**
     * 设置gc间隔时间
     * @see #gc()
     * @see #removeStack(LuaValue)
     * @param ms 毫秒
     */
    public static void setLuaGcOffset(long ms) {
        LUA_GC_OFFSET = ms;
    }

    /**
     * 设置需要销毁多少lua对象才执行gc
     * @see #gc()
     * @see #removeStack(LuaValue)
     * @param n 个数，默认100
     */
    public static void setNeedDestroyNumber(int n) {
        LUA_GC_NUM_VALUES = n;
    }

    /**
     * 设置Lua中db文件存储路径
     * @param path 路径必须存在
     */
    public static void setDatabasePath(String path) {
        if (!new File(path).exists())
            throw new IllegalStateException(path + " is not exists!");
        LuaCApi._setDatabasePath(path);
    }
    //</editor-fold>

    //<editor-fold desc="compile and execute">

    /**
     * 开启debug
     */
    public final void openDebug() {
        if (!debuggable) {
            LuaCApi._openDebug(L_State);
            debuggable = true;
        }
    }

    /**
     * 是否由isolate 创建
     */
    public final boolean isIsolate() {
        return parent_L_State != 0;
    }

    /**
     * 设置lua包根路径，require时使用
     * 优先级最高
     * @param basePath 根路径
     * @param autoSave 是否自动保存二进制文件
     *                 true：native查找到相关文件luab后缀是否可用，若可用，直接使用；
     *                       若不可用，查找lua相关文件是否可用，若可用，保存编译后二进制文件(luab)
     *                 false：native只查找已lua为后缀的相关文件
     */
    public final void setBasePath(String basePath, boolean autoSave) {
        checkDestroy();
        this.basePath = basePath == null ? "" : basePath;
        LuaCApi._setBasePath(L_State, this.basePath, autoSave);
    }

    /**
     * 设置lua查找so文件的路径
     * require时使用
     * @param path 路径，可使用;分割多个路径
     */
    public final void setSoPath(String path) {
        if (path == null)
            return;
        checkDestroy();
        soPath = path;
        LuaCApi._setSoPath(L_State, path);
    }

    /**
     * 打开调试
     * 需要在脚本未执行时打开，否则不生效
     * @param debug debug脚本
     * @param ip    ip地址
     * @param port  port
     * @return true：开启成功
     */
    public final boolean startDebug(byte[] debug, String ip, int port) {
        checkDestroy();
        if (debugOpened)
            return true;
        if (!debuggable) {
            openDebug();
        }
        try {
            state = LuaCApi._startDebug(L_State, debug, ip, port);
        } catch (Throwable t) {
            error = t;
            errorMsg = t.getMessage();
            state = LUA_ERRINJAVA;
        }
        debugOpened = state == LUA_OK;
        return debugOpened;
    }

    /**
     * 加载lua源码字符串
     *
     * @param chunkName 名称
     * @param lua       Lua源码
     * @return 编译状态，true: 成功，可以通过{@link #callLoadedData()}执行
     * false: 失败，可通过{@link #getState()}获取加载状态
     */
    public final boolean loadString(String chunkName, String lua) {
        return loadData(chunkName, lua.getBytes());
    }

    /**
     * 加载Lua源码或二进制码
     * 其他机器编译出的二进制码不一定可用
     *
     * @param chunkName 名称
     * @param data      Lua源码或二进制码
     * @return 编译状态，true: 成功，可以通过{@link #callLoadedData()}执行
     * false: 失败，可通过{@link #getState()}获取加载状态
     */
    public final boolean loadData(String chunkName, byte[] data) {
        checkDestroy();
        try {
            state = LuaCApi._loadData(L_State, chunkName, data);
        } catch (Throwable e) {
            error = e;
            errorMsg = e.getMessage();
            state = LUA_ERRINJAVA;
        }
        return state == LUA_OK;
    }

    /**
     * 加载Lua源码或二进制码
     * 其他机器编译出的二进制码不一定可用
     *
     * @param path 脚本绝对路径
     * @return 编译状态，true: 成功，可以通过{@link #callLoadedData()}执行
     * false: 失败，可通过{@link #getState()}获取加载状态
     */
    public final boolean loadFile(String path, String chunkName) {
        checkDestroy();
        try {
            state = LuaCApi._loadFile(L_State, path, chunkName);
        } catch (Throwable e) {
            error = e;
            errorMsg = e.getMessage();
            state = LUA_ERRINJAVA;
        }
        return state == LUA_OK;
    }

    /**
     * 加载Assets目录下，Lua源码或二进制码
     * 其他机器编译出的二进制码不一定可用
     *
     * @param path 脚本绝对路径
     * @return 编译状态，true: 成功，可以通过{@link #callLoadedData()}执行
     * false: 失败，可通过{@link #getState()}获取加载状态
     */
    public final boolean loadAssetsFile(String path, String chunkName) {
        checkDestroy();
        try {
            state = LuaCApi._loadAssetsFile(L_State, path, chunkName);
        } catch (Throwable e) {
            error = e;
            errorMsg = e.getMessage();
            state = LUA_ERRINJAVA;
        }
        return state == LUA_OK;
    }

    /**
     * 预加载Lua脚本
     * @param chunkName 脚本名称，Lua代码中require()时使用
     * @param data      源码或二进制码
     * @throws UndumpError 若编译出错，则抛出异常
     */
    public final void preloadData(String chunkName, byte[] data) throws UndumpError {
        checkDestroy();
        LuaCApi._preloadData(L_State, chunkName, data);
    }

    /**
     * 预加载Lua文件
     * @param chunkName 脚本名称，Lua代码中require()时使用
     * @param path      脚本绝对路径
     * @throws UndumpError 若编译出错，则抛出异常
     */
    public final void preloadFile(String chunkName, String path) throws UndumpError {
        checkDestroy();
        LuaCApi._preloadFile(L_State, chunkName, path);
    }

    /**
     * 预加载Lua文件，并将二进制码存储到savePath中
     * @param chunkName 脚本名称，Lua代码中require()时使用
     * @param path      脚本asset路径
     * @param savePath  二进制码存储文件
     * @throws UndumpError 若编译出错，则抛出异常
     * @return 0: 成功
     * @see org.luaj.vm2.LuaValue.ErrorCode
     */
    public final @ErrorCode int preloadAssetsAndSave(String chunkName, String path, String savePath) throws UndumpError {
        checkDestroy();
        File parent = new File(savePath).getParentFile();
        if (!parent.exists()) {
            if (!parent.mkdirs())
                return ERR_CREATE_DIR;
        }
        return LuaCApi._preloadAssetsAndSave(L_State, chunkName, path, savePath);
    }

    /**
     * 预加载Lua文件
     * @param chunkName 脚本名称，Lua代码中require()时使用
     * @param path      脚本asset路径
     * @throws UndumpError 若编译出错，则抛出异常
     */
    public final void preloadAssets(String chunkName, String path) throws UndumpError {
        checkDestroy();
        LuaCApi._preloadAssets(L_State, chunkName, path);
    }

    /**
     * 相当于调用lua的require函数
     * @param path 支持绝对路径、相对路径、lua写法: dir.name
     */
    public final boolean require(String path) throws InvokeError {
        checkDestroy();
        return LuaCApi._require(L_State, path) == LUA_OK;
    }

    /**
     * 设置主入口，必须已通过{@link #preloadData} 或 {@link #preloadFile} 预加载成功
     * @param chunkname 预加载时的米
     * @return true: 设置成功，可通过 {@link #callLoadedData()}执行
     */
    public final boolean setMainEntryFromPreload(String chunkname) {
        checkDestroy();
        if (LuaCApi._setMainEntryFromPreload(L_State, chunkname)) {
            state = LUA_OK;
            return true;
        } else {
            state = -404;
            errorMsg = "Did not find " + chunkname + " module from _preload table";
            error = new Exception(errorMsg);
        }
        return false;
    }

    /**
     * 若已通过
     *      {@link #loadString}
     *      {@link #loadData}
     *      {@link #setMainEntryFromPreload}
     * 加载成功，可通过此方法执行加载脚本，并返回执行状态
     *
     * @return true: 成功，false: 失败，可通过{@link #getState()}查看执行状态
     */
    public final boolean callLoadedData() {
        checkDestroy();
        if (state != LUA_OK) {
            if (state == JUST_INIT) {
                throw new IllegalStateException("Lua script is not loaded!");
            }
            throw new IllegalStateException("state of loading lua script is not ok, code: " + state);
        }
        try {
            state = LUA_CALLING;
            state = LuaCApi._doLoadedData(L_State);
        } catch (Throwable t) {
            error = t;
            state = LUA_ERRINJAVA;
            MLNCore.hookLuaError(t, this);
            errorMsg = t.getMessage();
        }
        return state == LUA_OK;
    }

    /**
     * 若已通过
     *      {@link #loadString}
     *      {@link #loadData}
     *      {@link #setMainEntryFromPreload}
     * 加载成功，可通过此方法执行加载脚本，并返回执行状态
     * @return lua执行结果，可能为空
     * @throws IllegalStateException 当前虚拟机状态不可用时，抛出
     * @throws InvokeError 执行出错，抛出（由C层）
     */
    public final LuaValue[] callLoadedDataAndGetResult() throws IllegalStateException, InvokeError {
        checkDestroy();
        if (state != LUA_OK) {
            if (state == JUST_INIT) {
                throw new IllegalStateException("Lua script is not loaded!");
            }
            throw new IllegalStateException("state of loading lua script is not ok, code: " + state);
        }
        state = LUA_CALLING;
        LuaValue[] ret = LuaCApi._doLoadedDataAndGetResult(L_State);
        state = LUA_OK;
        return ret;
    }

    /**
     * 获取加载lua的状态，加载失败时使用
     *
     * @return 状态码
     * @see #loadString(String, String)
     * @see #loadData(String, byte[])
     */
    public final int getState() {
        return state;
    }

    /**
     * 获取加载或执行Lua的错误信息
     * 当加载和执行状态码都为{@link #LUA_OK}时，信息为空
     *
     * @return 错误信息
     */
    public final String getErrorMsg() {
        return errorMsg;
    }

    /**
     * 获取加载或执行Lua的错误堆栈
     * 当加载和执行状态码都为{@link #LUA_OK}时，为空
     *
     * @return 错误堆栈
     */
    public final Throwable getError() {
        return error;
    }
    //</editor-fold>

    //<editor-fold desc="Register">

    /**
     * 注册所有的静态Bridge
     * 在Lua中可通过 luaClassName:method()调用
     *
     * 方法必须返回LuaValue数组，且参数必须为 (long, LuaValue[])
     *
     * 必须和{@link #callLoadedData()}在同一线程！
     *
     * @param lcns          lua调用的类名
     * @param lpcns         继承自lua的类名
     * @param jcns          java的class {@link SignatureUtils#getClassName(Class)}
     */
    public final void registerAllStaticClass(String[] lcns, String[] lpcns, String[] jcns) {
        checkDestroy();
        final int len = lcns.length;
        if (len != lpcns.length || len != jcns.length)
            throw new IllegalArgumentException("lcns lpcns jcns must have same length");
        LuaCApi._registerAllStaticClass(L_State, lcns, lpcns, jcns);
    }

    /**
     * 注册所有的java userdata
     * 注意java构造函数一定需要有 Globals, LuaValue[] 参数
     * 方法的返回值和参数都必须是 LuaValue[]类型
     *
     * 若注册的class为{@link LuaUserdata}的子类，则会将对象保存到GNV表中，不可释放
     * 直到原生调用{@link LuaUserdata#destroy()}
     *
     * 注册后，马上设置元表，提升使用时性能
     *
     * 必须和{@link #callLoadedData()}在同一线程！
     * @param lcns          lua调用的类名
     * @param lpcns         继承自lua的类名
     * @param jcns          java的class {@link SignatureUtils#getClassName(Class)}
     * @param lazy          每个userdata是否是lazy
     */
    public final void registerAllUserdata(String[] lcns, String[] lpcns, String[] jcns, boolean[] lazy) throws RuntimeException {
        checkDestroy();
        final int len = lcns.length;
        if (len != lpcns.length || len != jcns.length)
            throw new IllegalArgumentException("lcns lpcns jcns must have same length");
        LuaCApi._registerAllUserdata(L_State, lcns, lpcns, jcns, lazy);
    }

    /**
     * 注册只包含静态__index方法的类
     */
    public final void registerJavaMetatable(Class clz, String name) {
        LuaCApi._registerJavaMetatable(L_State,
                SignatureUtils.getClassName(clz),
                name);
    }

    /**
     * 注册数字型枚举变量
     * @param lcn       lua中的名称
     * @param keys      枚举名称
     * @param values    数值
     */
    public final void registerNumberEnum(String lcn, String[] keys, double[] values) {
        checkDestroy();
        if (keys == null || values == null)
            return;
        if (keys.length != values.length) {
            throw new IllegalArgumentException("keys and values must have same length!");
        }
        LuaCApi._registerNumberEnum(L_State, lcn, keys, values);
    }

    /**
     * 注册字符串型枚举变量
     * @param lcn       lua中的名称
     * @param keys      枚举名称
     * @param values    数值
     */
    public final void registerStringEnum(String lcn, String[] keys, String[] values) {
        checkDestroy();
        if (keys == null || values == null)
            return;
        if (keys.length != values.length) {
            throw new IllegalArgumentException("keys and values must have same length!");
        }
        LuaCApi._registerStringEnum(L_State, lcn, keys, values);
    }
    //</editor-fold>

    //<editor-fold desc="Resource finder">

    /**
     * 给全局虚拟机设置finder
     */
    private static void addAllPathRFFromGlobals(Globals gg) {
        for (int i = 0, l = cache.size(); i < l;i ++) {
            Globals g = cache.valueAt(i);
            Set<ResourceFinder> grfs = g.resourceFinders;
            if (grfs == null) continue;
            gg.resourceFinders.addAll(grfs);
            if (g.resourceFinder != null)
                gg.resourceFinders.add(g.resourceFinder);
        }
    }

    /**
     * 给全局虚拟机设置finder
     */
    private static void addRFToGlobals(ResourceFinder rf) {
        for (int i = 0, l = g_cahce.size(); i < l;i ++) {
            g_cahce.valueAt(i).resourceFinders.add(rf);
        }
    }

    /**
     * 设置资源寻找器
     *
     * 高优先
     *
     * @see #resourceFinder
     * @see ResourceFinder
     * @see #__onLuaRequire(long, String)
     * @see #onRequire(String)
     */
    public void setResourceFinder(ResourceFinder rf) {
        resourceFinder = rf;
        if (!isGlobal) {
            addRFToGlobals(rf);
        }
    }

    /**
     * 设置资源寻找器集合
     * @param rfs 集合
     */
    public void setResourceFinders(Collection<ResourceFinder> rfs) {
        resourceFinders = new HashSet<>(rfs);
    }

    /**
     * 添加资源寻找器
     *
     * 低优先
     *
     * @see #resourceFinders
     * @see ResourceFinder
     * @see #__onLuaRequire(long, String)
     * @see #onRequire(String)
     */
    public void addResourceFinder(ResourceFinder rf) {
        if (resourceFinders == null) {
            resourceFinders = new HashSet<>();
        }
        resourceFinders.add(rf);
        if (!isGlobal) {
            addRFToGlobals(rf);
        }
    }

    /**
     * 清除资源寻找器
     */
    public void clearResourceFinder() {
        if (resourceFinders != null)
            resourceFinders.clear();
    }
    //</editor-fold>

    /**
     * 是否加载了debug脚本
     */
    public final boolean isDebugOpened() {
        return debugOpened;
    }

    /**
     * 设置是否正在使用中
     */
    public final void setRunning(boolean running) {
        this.running = running;
    }

    /**
     * 是否在使用中
     */
    public final boolean isRunning() {
        return this.running;
    }

    /**
     * 获取当前虚拟机使用的内存量，单位Byte
     * @return 如果编译时，没有打开J_API_INFO编译选项，则返回为0
     * @see #getAllLVMMemUse() 获取所有虚拟机的内存使用量
     */
    public final long getLVMMemUse() {
        return LuaCApi._lvmMemUse(L_State);
    }

    /**
     * dump出当前虚拟机堆栈
     * 测试SDK时使用
     *
     * @return 堆栈信息
     */
    public final LuaValue[] dump() {
        checkDestroy();
        return LuaCApi._dumpStack(L_State);
    }

    /**
     * 获取Lua调用栈
     */
    public final String luaTraceBack() {
        checkDestroy();
        return LuaCApi._traceback(L_State);
    }

    /**
     * 判断当前是否在lua函数调用过程中
     */
    public final boolean isInLuaFunction() {
        return state == LUA_CALLING || calledFunction > 0;
    }

    /**
     * post事件
     * @return true post成功
     */
    public final boolean post(Runnable r) {
        if (handler != null) {
            return handler.post(r);
        }
        return false;
    }

    /**
     * 延迟post事件
     * @return true post 成功
     */
    public final boolean postDelayed(Runnable r, long ms) {
        Message message = Message.obtain(handler, r);
        message.obj = TAG;

        return handler.sendMessageDelayed(message, ms);
    }

    @Override
    public final boolean isDestroyed() {
        return destroyed || L_State == 0;
    }

    /**
     * 销毁当前虚拟机
     */
    public final void destroy() {
        checkMainThread();
        if (!isDestroyed() && MLNCore.DEBUG && (state == LUA_CALLING || calledFunction > 0)) {
            throw new IllegalStateException("throw in debug mode, cannot destroy lua vm when lua function is calling!");
        }
        if (isDestroyed())
            return;
        MLNCore.onGlobalsDestroy(this);
        if (onDestroyListeners != null) {
            for (OnDestroyListener l : onDestroyListeners) {
                l.onDestroy(this);
            }
            onDestroyListeners.clear();
        }
        destroyed = true;
        final long pointer = L_State;
        L_State = 0;
        if (handler != null) {
            handler.removeCallbacksAndMessages(TAG);
        }
        if (!isIsolate()) LuaCApi._close(pointer);
        userdataCache.onDestroy();
        if (javaUserdata != null) {
            javaUserdata.onGlobalsDestroy(this);
        }
        javaUserdata = null;
        NativeLog.release(pointer);
        cache.remove(pointer);
        g_cahce.remove(pointer);
        luaClassNameMap.clear();
        resourceFinder = null;
        if (resourceFinders != null)
            resourceFinders.clear();
    }

    /**
     * 创建一个userdata，并设置到Global表里
     * luaClassName必须已经注册过
     *
     * @param key          键名称
     * @param luaClassName lua类名
     * @return 创建的对象
     */
    public final Object createUserdataAndSet(String key, String luaClassName, LuaValue... params) throws RuntimeException {
        checkDestroy();
        return LuaCApi._createUserdataAndSet(L_State, key, luaClassName, params);
    }

    /**
     * 获取虚拟机地址
     */
    public final long getL_State() {
        return L_State;
    }

    /**
     * 设置Java环境的用户数据
     */
    public final void setJavaUserdata(IGlobalsUserdata userdata) {
        this.javaUserdata = userdata;
        NativeLog.register(L_State, userdata);
    }

    /**
     * 获取java环境的用户数据
     */
    public final IGlobalsUserdata getJavaUserdata() {
        return javaUserdata;
    }

    /**
     * 通过class获取在lua中的名称
     * @param c clz
     * @return may be null
     *
     * @see LuaUserdata
     */
    public final String getLuaClassName(Class c) {
        return luaClassNameMap.get(c);
    }

    /**
     * 设置class和luaclassname的对应关系
     */
    public final void putLuaClassName(Class<? extends LuaUserdata> clz, String lcn) {
        luaClassNameMap.put(clz, lcn);
    }

    /**
     * 设置class和luaclassname的对应关系
     */
    public final void putLuaClassName(Map<Class, String> other) {
        luaClassNameMap.putAll(other);
    }

    /**
     * 增加销毁监听
     */
    public synchronized void addOnDestroyListener(OnDestroyListener l) {
        if (l == null)
            return;
        if (onDestroyListeners == null) {
            onDestroyListeners = new ArrayList<>();
        }
        onDestroyListeners.add(l);
    }

    /**
     * 移除销毁监听
     */
    public synchronized void removeOnDestroyListener(OnDestroyListener l) {
        if (onDestroyListeners != null)
            onDestroyListeners.remove(l);
    }

    /**
     * 设置空方法监听
     */
    public static void setOnEmptyMethodCalledListener(OnEmptyMethodCalledListener listener) {
        onEmptyMethodCalledListener = listener;
    }

    /**
     * 查找class对象或其父class对象的注册信息
     * @param c class对象
     * @return 注册到Lua的类名
     */
    public static String findLuaParentClass(Class c, Map<Class, String> luaClassNameMap) {
        Class p = c.getSuperclass();
        while (p != null && p != Object.class && p != JavaUserdata.class && p != LuaUserdata.class) {
            String s = luaClassNameMap.get(p);
            if (s != null)
                return s;
            p = p.getSuperclass();
        }
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Package Methods">

    /**
     * 判断是否有消息队列
     */
    boolean hasLooper() {
        return handler != null;
    }

    /**
     * 判断当前线程是否是创建的线程
     */
    boolean isMainThread() {
        return mainThread == Thread.currentThread();
    }

    /**
     * 检查并抛错
     */
    void checkMainThread() {
        if (!isMainThread())
            throw new IllegalStateException("must called in main thread: " + globals.mainThread);
    }

    /**
     * 获取global表的位置
     * @see LuaUserdata
     */
    long globalsIndex() {
        return GLOBALS_INDEX;
    }

    /**
     * 在Lua栈上删除对应数据，如果此数据不是{@link NLuaValue}，或为Globals表，则无操作
     * 若数据不在当前Lua栈栈顶，则保留数据，直到下次触发删除数据
     *
     * @param value Lua数据
     * @return 是否真正将对应栈数据清除
     */
    boolean removeStack(final LuaValue value) {
        if (value instanceof Globals)
            return false;
        checkDestroy();
        final long key = value.nativeGlobalKey();
        if (key == 0 || key == GLOBALS_INDEX)
            return true;
        if (isMainThread() && canDestroySync()) {
            boolean destroy =  LuaCApi._removeNativeValue(L_State, key, value.type()) <= 0;
            if (destroy) {
                destroyedValues++;
                gc();
            }
            return destroy;
        } else if (handler != null) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    if (isDestroyed()) return;
                    value.destroyed = LuaCApi._removeNativeValue(L_State, key, value.type()) <= 0;
                    if (value.destroyed) {
                        destroyedValues++;
                        gc();
                    }
                }
            });
        }
        return true;
    }

    /**
     * 判断是否可以同步销毁lua对象
     * 1. 不在gc中
     * 2. 若在gc中，gc执行时间必须小于10ms
     */
    private boolean canDestroySync() {
        return !inGC || System.currentTimeMillis() - lastGcTime < 10;
    }

    /**
     * 某个时间点上是否可以执行full gc
     */
    private boolean canGc(long time) {
        if (inGC || state == JUST_INIT || isDestroyed()) return false;

        return time - lastGcTime > LUA_GC_OFFSET;
    }

    /**
     * 执行一次lua整体gc
     */
    private boolean gc() {
        long now = System.currentTimeMillis();
        if (canGc(now) && destroyedValues > LUA_GC_NUM_VALUES) {
            destroyedValues = 0;
            lastGcTime = now;
            inGC = true;
            LuaCApi._lgc(L_State);
            lastGcTime = System.currentTimeMillis();
            MLNCore.luaGcCast(this, lastGcTime - now);
            inGC = false;
            return true;
        }
        return false;
    }
    //</editor-fold>

    //<editor-fold desc="Table unsupported set get">
    public final void set(int index, LuaValue value) {
        unsupported();
    }

    public final void set(int index, double num) {
        unsupported();
    }

    public final void set(int index, boolean b) {
        unsupported();
    }

    public final void set(int index, String s) {
        unsupported();
    }

    public final void set(int index, Class<?> clz, Method method) {
        unsupported();
    }

    @Override
    public final LuaValue get(int index) {
        unsupported();
        return null;
    }

    private void unsupported() {
        throw new UnsupportedOperationException("global is not support set/get a number key!");
    }
    //</editor-fold>

    /**
     * Lua脚本调用require时
     *
     * @param L    Lua虚拟机地址
     * @param name require名称
     * @return null | absolutePath(LuaString) | lua byte data(LuaUserdata)
     * @see #onRequire
     */
    @LuaApiUsed
    private static Object __onLuaRequire(long L, String name) {
        return getGlobalsByLState(L).onRequire(name);
    }

    /**
     * Lua脚本调用require时，获取错误信息
     * @param L Lua虚拟机地址
     * @return 可为空
     */
    @LuaApiUsed
    private static String __getRequireError(long L) {
        return getGlobalsByLState(L).getRequireErrorMsg();
    }

    /**
     * Lua脚本执行GC时调用
     *
     * @see #setGcOffset(int)
     */
    @LuaApiUsed
    private static void __onLuaGC(long L) {
        System.gc();
    }

    /**
     * 调用注册的空方法时，会走到这
     */
    @LuaApiUsed
    private static void __onEmptyMethodCall(long L, String clz, String methodName) {
        if (onEmptyMethodCalledListener != null) {
            Globals g = getGlobalsByLState(L);
            if (g != null)
                onEmptyMethodCalledListener.onCalled(g, clz, methodName);
        }
    }

    /**
     * isolate 状态
     */
    private static final int DESTROYED = -2;
    private static final int NONE_LOOP = -3;
    private static final int SUCCESS   = 0;

    /**
     * Called by jinfo.c
     * 不同lua进程发送消息
     * @param L     目标进程
     * @param args  传递参数
     */
    @LuaApiUsed
    private static int __postCallback(final long L, final long method, final long args) {
        final Globals g = Globals.getGlobalsByLState(L);
        if (g == null || g.isDestroyed()) return DESTROYED;
        if (!g.hasLooper()) return NONE_LOOP;
        g.handler.post(new Runnable() {
            @Override
            public void run() {
                long l = g.isDestroyed() ? 0 : L;
                LuaCApi._callMethod(l, method, args);
            }
        });
        return SUCCESS;
    }

    /**
     * Lua脚本调用require时
     *
     * @param name require名称，一般不带后缀
     * @return null | absolutePath(LuaString) | lua byte data(LuaUserdata)
     * @see #__onLuaRequire
     */
    private Object onRequire(String name) {
        if (requireErrorMsg != null) {
            requireErrorMsg.setLength(0);
        }
        if (resourceFinder == null && resourceFinders == null) {
            if (requireErrorMsg == null)
                requireErrorMsg = new StringBuilder();
            requireErrorMsg.append("\n\t\tno resource finder set in java!");
            return null;
        }
        Object ret = findResource(resourceFinder, name);
        if (ret != null)
            return ret;
        combineErrorMessage(resourceFinder);
        if (resourceFinders != null) {
            for (ResourceFinder rf : resourceFinders) {
                ret = findResource(rf, name);
                if (ret != null) {
                    return ret;
                } else {
                    combineErrorMessage(rf);
                }
            }
        }
        return null;
    }

    private String getRequireErrorMsg() {
        if (requireErrorMsg == null || requireErrorMsg.length() == 0)
            return null;
        return requireErrorMsg.toString();
    }

    private void combineErrorMessage(ResourceFinder rf) {
        if (rf == null)
            return;
        String error = rf.getError();
        if (error == null || error.length() == 0)
            return;
        if (requireErrorMsg == null) {
            requireErrorMsg = new StringBuilder();
        }
        requireErrorMsg.append("\n\t\t").append(error);
    }

    /**
     * 获取缓存的userdata
     * 提供给native调用
     * @param L  虚拟机
     * @param id id
     * @return 返回缓存的userdata
     */
    @LuaApiUsed
    static Object __getUserdata(long L, long id) {
        Globals g = Globals.getGlobalsByLState(L);
        if (g == null)
            return null;
        return g.userdataCache.get(id);
    }

    private void checkDestroy() {
        if (isDestroyed()) {
            throw new IllegalStateException("this lua vm is destroyed!");
        }
    }

    private static Object findResource(ResourceFinder rf, String name) {
        if (rf != null) {
            name = rf.preCompress(name);
            String path = rf.findPath(name);
            if (path != null) {
                return path;
            }
            byte[] data = rf.getContent(name);
            if (data != null) {
                rf.afterContentUse(name);
                return data;
            }
        }
        return null;
    }

    @Override
    public String toString() {
        return "Globals#" + hashCode();
    }

    @Override
    public int hashCode() {
        return (int)(L_State ^ (L_State >>> 32));
    }

    @Override
    public boolean equals(Object o) {
        return o == this;
    }

    /**
     * 监听虚拟机销毁
     */
    public static interface OnDestroyListener {
        /**
         * 在虚拟机销毁前调用
         * 可调用lua接口
         * @param g 虚拟机
         */
        void onDestroy(Globals g);
    }
}