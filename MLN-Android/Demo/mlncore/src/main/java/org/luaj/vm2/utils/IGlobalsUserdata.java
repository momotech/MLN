package org.luaj.vm2.utils;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019/3/11
 *
 * 全局用户信息，存放在{@link Globals}中
 *
 * @see Globals#javaUserdata
 * @see Globals#setJavaUserdata(IGlobalsUserdata)
 */
public interface IGlobalsUserdata extends ILog {
    /**
     * Globals销毁时调用
     * @param g 虚拟机
     */
    void onGlobalsDestroy(Globals g);
}
