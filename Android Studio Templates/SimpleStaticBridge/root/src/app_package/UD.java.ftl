package ${packageName};

import android.content.Context;

import androidx.annotation.NonNull;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.wrapper.callback.IVoidCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by MLN Template
 * 注册方法：
 * Register.newSHolderWithLuaClass(${ClassName}.LUA_CLASS_NAME, ${ClassName}.class)
 */
@LuaClass(isStatic = true)
public class ${ClassName} {
    /**
     * Lua类名
     */
    public static final String LUA_CLASS_NAME = "${LuaClassName}";

    //<editor-fold desc="Bridge API">
    /**
     * 直接在属性中增加注解，可让Lua有相关属性
     * eg:
     *  ${LuaClassName}:property()      --获取相关值
     *  ${LuaClassName}:property(10)    --设置相关值
     */
    @LuaBridge
    static int property;

    /**
     * Lua可通过对象方法调用此方法
     * eg:
     *  ${LuaClassName}:methodA()
     */
    @LuaBridge
    static void methodA() { }

    /**
     * 通过{@link LuaBridge#alias()}设置别名，使Lua通过别名调用此方法
     * Lua调用方法：
     *  ${LuaClassName}:methodC() --不可使用methodB()调用
     *
     * 参数类型可选择:
     *  0. 虚拟机对象
     *  1. 基本数据类型，及其数组类型
     *  2. String，及其数组类型
     *  3. Callback {@link IVoidCallback}
     *              {@link com.immomo.mls.wrapper.callback.IBoolCallback}
     *              {@link com.immomo.mls.wrapper.callback.IIntCallback}
     *              {@link com.immomo.mls.wrapper.callback.IStringCallback}
     *              {@link com.immomo.mls.utils.LVCallback}
     *  4. 任意Lua原始类型
     *  5. 已注册自动转换的类型，如{@link java.util.Map} {@link java.util.List}
     *
     * 返回类型可选择:
     *  1. 基本数据类型，及其数组类型
     *  2. String，及其数组类型
     *  3. 任意Lua原始类型
     *  4。已注册自动转换的类型，如{@link java.util.Map} {@link java.util.List}
     */
    @LuaBridge(alias = "methodC")
    static String[] methodB(Globals g, int a, boolean b, String c, IVoidCallback d, LuaValue e) {
        return null;
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
