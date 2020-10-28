/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.view.ViewGroup;

/**
 * Created by Xiong.Fangyu on 2018/10/31
 */
public class MLSConfigs {

    public static boolean defaultNotClip = true;
    public static boolean noStateBarHeight = false;
    public static long defaultClickEventTimeLimit = 300;
    public static float defaultNavBarHeight = 65; // 导航栏高度(tool bar|| action bar)， 单位dp

    public static boolean preCreateGlobals = true;
    public static int maxAutoPreloadByte = 0; //1M

    public static int maxRecyclerPoolSize = 5;
    public static boolean lazyFillCellData = false;
    public static int viewPagerConfig = 1;      //0 | 1

    public static int maxLoadCount = 2;
    /**
     * 默认加载超时为20s
     */
    public static long defaultLoadScriptTimeout = 20000;

    public static boolean defaultClipChildren = true;
    public static boolean defaultClipToPadding = true;
    public static boolean defaultClipContainer = false;

    public static boolean defaultLazyLoadImage = true;

    public static boolean catchOnLayoutException = false;
    public static OnLayoutException onLayoutException;

    static boolean openDebug = false;
    public static CharSequence uninitTitle = "当前版本不支持";
    public static CharSequence uninitMsg = "";

    public static void setUninitTitle(CharSequence uninitTitle) {
        MLSConfigs.uninitTitle = uninitTitle;
    }

    public static void setUninitMsg(CharSequence uninitMsg) {
        MLSConfigs.uninitMsg = uninitMsg;
    }

    public static interface OnLayoutException {

        void onCatch(ViewGroup v, NullPointerException e);
    }
}