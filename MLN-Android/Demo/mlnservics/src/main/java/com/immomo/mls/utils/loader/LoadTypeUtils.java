package com.immomo.mls.utils.loader;

import com.immomo.mls.Constants;

/**
 * Created by Xiong.Fangyu on 2019-08-08
 *
 * Load Type 类型处理
 */
public final class LoadTypeUtils {

    private LoadTypeUtils() {}

    /**
     * 向src中增加类型type
     */
    public static int add(int src, @Constants.LoadType int type) {
        return src | type;
    }

    /**
     * 移除src中类型type
     */
    public static int remove(int src, @Constants.LoadType int type) {
        return src &(~type);
    }

    /**
     * 判断src中是否有类型type
     */
    public static boolean has(int src, @Constants.LoadType int type) {
        return (src & type) == type;
    }
}
