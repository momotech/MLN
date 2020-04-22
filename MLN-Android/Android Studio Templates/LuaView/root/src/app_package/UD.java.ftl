package ${packageName};

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.fun.ud.view.UDView<#if ViewGroup>Group</#if>;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by MLN Template
 * 注册方法：
 * Register.newUDHolder(${ClassName}.LUA_CLASS_NAME, ${ClassName}.class, true, ${ClassName}.methods)
 */
@LuaApiUsed
public class ${ClassName} extends UDView<#if ViewGroup>Group</#if><${WrapClass}> {

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

    //<editor-fold desc="Init">
    /**
     * 提供给Lua的构造函数
     * 必须存在
     * @param L 虚拟机底层地址
     * @param v 初始化参数，非空，但长度可能为0
     */
    @LuaApiUsed
    protected ${ClassName}(long L, @NonNull LuaValue[] v) {
        super(L, v);
    }

    /**
     * 提供给Java的构造函数
     * @param g 虚拟机
     * @param o 初始化对象
     */
    public ${ClassName}(Globals g, @NonNull ${WrapClass} o) {
        super(g, o);
    }

    /**
     * 初始化View
     * @param init Lua传入的初始化参数，非空，长度可能为0
     * @return 非空
     */
    @NonNull
    @Override
    protected ${WrapClass} newView(@NonNull LuaValue[] init) {
        return new ${WrapClass}(getContext());
    }
    //</editor-fold>


    //<editor-fold desc="Bridge API">

    /**
     * 增加Bridge，Lua可通过 obj:methodA(params)调用
     * @param params 非空，但长度可能为0
     */
    @LuaApiUsed
    protected @Nullable
    LuaValue[] methodA(@NonNull LuaValue[] params) {
//        return rBoolean(true);  //返回true
//        return rNumber(1);      //返回数字
//        return rString("a");    //返回String
//        return rNil();          //返回nil
//        return varargsOf(new UDDemo(getGlobals(), "other"));//返回一个userdata
        return null;            //等同于返回this：varargsOf(this)
    }
    //</editor-fold>

    /**
     * 此对象被Lua GC时调用，可不实现
     * 可做相关释放操作
     */
    /*@CallSuper
    @Override
    protected void __onLuaGc() {
        super.__onLuaGc();
    }*/
}
