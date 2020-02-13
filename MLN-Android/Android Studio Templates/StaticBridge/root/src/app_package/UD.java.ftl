package ${packageName};

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.LuaViewManager;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by MLN Template
 * 注册方法：
 * Register.newSHolder(${ClassName}.LUA_CLASS_NAME, ${ClassName}.class, ${ClassName}.methods),
 */
@LuaApiUsed
public class ${ClassName} {
    /**
     * Lua类名
     */
    public static final String LUA_CLASS_NAME = "${LuaClassName}";
    /**
     * 所有Bridge的名称
     * 且Java方法必须有{@link LuaApiUsed}注解
     */
    public static final String[] methods = {
            "methodA"
    };

    //<editor-fold desc="Bridge API">
    /**
     * 增加Bridge，Lua可通过 ${LuaClassName}:methodA(params)调用
     * @param j 虚拟机地址，可使用{@link org.luaj.vm2.Globals#getGlobalsByLState(long)}获取相关对象
     * @param params 非空，但长度可能为0
     */
    @LuaApiUsed
    static @Nullable LuaValue[] methodA(long j, @NonNull LuaValue[] params) {
//        return rBoolean(true);  //返回true
//        return rNumber(1);      //返回数字
//        return rString("a");    //返回String
//        return rNil();          //返回nil
//        return varargsOf(new UDDemo(getGlobals(), "other"));//返回一个userdata
        return null;            //等同于返回this：varargsOf(this)
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
