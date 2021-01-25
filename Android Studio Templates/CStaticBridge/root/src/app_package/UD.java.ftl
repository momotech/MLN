package ${packageName};

import android.content.Context;

import androidx.annotation.NonNull;

import com.immomo.mls.LuaViewManager;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by MLN Template
 * 注册方法：
 * new Register.NewStaticHolder(${ClassName}.LUA_CLASS_NAME, ${ClassName}.class)
 */
@LuaApiUsed
public class ${ClassName} {
    /**
     * Lua类名
     */
    public static final String LUA_CLASS_NAME = "${LuaClassName}";
    //<editor-fold desc="native method">
    /**
     * 初始化方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewStaticHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewStaticHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>
    //<editor-fold desc="Bridge API">
    /**
     * 在C层中调用
     */
    @LuaApiUsed
    static void methodA(int a) {
        /// 逻辑
    }
    //</editor-fold>

    /**
     * 获取上下文，一般情况，此上下文为Activity
     * @param globals 虚拟机，可通过构造函数存储
     */
    protected static Context getContext(@NonNull Globals globals) {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }
}
