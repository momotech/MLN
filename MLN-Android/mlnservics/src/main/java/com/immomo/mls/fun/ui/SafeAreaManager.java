/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ui;

import android.app.Activity;
import android.content.Context;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.fun.constants.SafeAreaConstants;
import com.immomo.mls.fun.globals.UDLuaView;
import com.immomo.mls.util.AndroidUtil;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by zhang.ke
 * wiki:https://moji.wemomo.com/doc#/detail/89621
 * https://moji.wemomo.com/doc#/detail/93144
 * <p>
 * Safe Area适配概念
 * <p>
 * 为避免两端上布局起始位置的差异带来的适配问题，添加一个安全区域概念（Safe Area）, 开启Safe Area后，开发人只需要关注页面具体内容，不需要为各种设备的不同页面模式去适配顶部开始距离和底部留白的高度，MLN层会自动适配不同方位上的安全区域。
 * Safe Area 功能详细描述
 * <p>
 * Safe Area 枚举，用来区分当前页面内，安全区域的大小。
 * <p>
 * SafeArea.CLOSE (默认模式) 该状态代表不开启安全区域。
 * SafeArea.TOP 开启顶部安全区域，在任何设备或页面模式下，所有内容都不会被状态栏遮挡（即使是Android的沉浸式模式下）。
 * SafeArea.BOTTOM 开启底部安全区域，在任何设备或页面模式下，所有内容将被限制到虚拟home键区域之上（即使是Android的沉浸式模式下）。
 * SafeArea.LEFT （为大屏手势预留位置，暂时不开放）
 * SafeArea.RIGHT （为大屏手势预留位置，暂时不开放）
 * <p>
 * on 2019/11/5
 */
public class SafeAreaManager implements SafeAreaConstants {
    private boolean isTranslucent = false;//是否沉浸式
    private boolean isFullScreen = false;//是否全屏
    private int[] areas;

    public SafeAreaManager() {
        areas = new int[4];
    }

    public void safeArea(@SafeArea int area, UDLuaView window) {
        if (window == null) {
            return;
        }
        Context context = ((LuaViewManager) window.getGlobals().getJavaUserdata()).context;

        if (context instanceof Activity) {
            isTranslucent = AndroidUtil.isLayoutStable(((Activity) context));
            isFullScreen = AndroidUtil.isFullScreen(((Activity) context));
        }

        areas[0] = window.getView().getPaddingLeft();
        areas[1] = window.getView().getPaddingTop();
        areas[2] = window.getView().getPaddingRight();
        areas[3] = window.getView().getPaddingBottom();

        if ((area & LEFT) == LEFT) {
            areas[0] = 0;/*预留*/
        }
        if ((area & TOP) == TOP) {
            areas[1] = (isTranslucent && !isFullScreen) ? AndroidUtil.getStatusBarHeight(context) : 0;
        }
        if ((area & RIGHT) == RIGHT) {
            areas[2] = 0;/*预留*/
        }
        if ((area & BOTTOM) == BOTTOM) {//LuaSDk目前的沉浸式，不会隐藏底部导航栏，所以BOTTOM区域不需要
            areas[3] = 0;
        }


        window.getView().setPadding(areas[0], areas[1], areas[2], areas[3]);
    }
}
