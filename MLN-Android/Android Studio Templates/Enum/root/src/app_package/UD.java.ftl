package ${packageName};

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by MLN Templates
 * 注册方法：
 * @see com.immomo.mls.MLSBuilder#registerConstants(Class[])
 */
@ConstantClass
public interface ${ClassName} {
    /**
     * Lua可通过 ${ClassName}.a 读取
     */
    @Constant
    ${enumType} a = 1;
    /**
     * Lua可通过 ${ClassName}.c 读取
     */
    @Constant(alias = "c")
    ${enumType} b = 2;
}
