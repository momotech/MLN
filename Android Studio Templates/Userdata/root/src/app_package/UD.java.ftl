package ${packageName};

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSBuilder;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by MLN Template
 * 注册方法：
 * Register.newUDHolder(${ClassName}。LUA_CLASS_NAME, ${ClassName}.class, true)
 */
@LuaApiUsed
public class ${ClassName} extends LuaUserdata<${WrapClass}> {
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

    //<editor-fold desc="Constructors">

    /**
     * 提供给Lua的构造函数
     * 必须存在
     * @param L 虚拟机底层地址
     * @param v 初始化参数，非空，但长度可能为0
     */
    @LuaApiUsed
    protected ${ClassName}(long L, @NonNull LuaValue[] v) {
        super(L, v);
        /// 必须完成包裹对象的初始化
        javaUserdata = new ${WrapClass}();
    }

    /**
     * 提供给Java的构造函数
     * @param g 虚拟机
     * @param o 初始化对象
     */
    @LuaApiUsed
    public ${ClassName}(@NonNull Globals g, ${WrapClass} o) {
        super(g, o);
    }
    //</editor-fold>

    /**
     * 获取上下文，一般为Activity
     */
    protected Context getContext() {
        LuaViewManager m = (LuaViewManager) getGlobals().getJavaUserdata();
        return m != null ? m.context : null;
    }

    //<editor-fold desc="Bridge API">

    /**
     * 增加Bridge，Lua可通过 obj:methodA(params)调用
     * @param params 非空，但长度可能为0
     */
    @LuaApiUsed
    protected @Nullable LuaValue[] methodA(@NonNull LuaValue[] params) {
//        return rBoolean(true);  //返回true
//        return rNumber(1);      //返回数字
//        return rString("a");    //返回String
//        return rNil();          //返回nil
//        return varargsOf(new ${ClassName}(getGlobals(), "other"));//返回一个userdata
        return null;            //等同于返回this：varargsOf(this)
    }
    //</editor-fold>

    //<editor-fold desc="Other">

    /**
     * 此对象被Lua GC时调用，可不实现
     * 可做相关释放操作
     */
    /*@CallSuper
    @Override
    protected void __onLuaGc() {
        super.__onLuaGc();
    }*/

    /**
     * Lua判断相等时，可能会调用此方法
     * 可通过实现{@link #equals(Object)}来实现
     */
    //@Override
    //protected boolean __onLuaEq(Object other) { }

    /**
     * 若{@link #__onLuaEq}默认实现，则Lua判断相等时，可能调用此方法
     */
    //@Override
    //public boolean equals(Object o) { }
    //</editor-fold>

    //<editor-fold desc="Auto Convert">
    /**
     * 将Lua类型自动转换为Java类型，一般在基础类中使用，或选择默认转换方式
     * 注册方法：
     * @see com.immomo.mls.MLSBuilder#registerCovert(MLSBuilder.CHolder...)
     * @see MLSBuilder.CHolder
     */
    /*public static final IJavaObjectGetter<${ClassName}, ${WrapClass}> J = new IJavaObjectGetter<${ClassName}, ${WrapClass}>() {
        @Override
        public ${WrapClass} getJavaObject(${ClassName} lv) {
            return lv.getJavaUserdata();
        }
    };*/

    /**
     * 将Java类型转换为Lua类型，一般在基础类中使用，或选择默认转换方式
     * 注册方法：
     * @see com.immomo.mls.MLSBuilder#registerCovert(MLSBuilder.CHolder...)
     * @see MLSBuilder.CHolder
     */
    /*public static final ILuaValueGetter<${ClassName}, ${WrapClass}> L = new ILuaValueGetter<${ClassName}, ${WrapClass}>() {
        @Override
        public ${ClassName} newInstance(Globals g, ${WrapClass} obj) {
            return new ${ClassName}(g, obj);
        }
    };*/
    //</editor-fold>
}
