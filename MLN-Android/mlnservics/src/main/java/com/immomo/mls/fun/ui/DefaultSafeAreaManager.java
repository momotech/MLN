/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ui;

import android.content.Context;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.fun.constants.SafeAreaConstants;
import com.immomo.mls.fun.globals.UDLuaView;
import com.immomo.mls.fun.ud.UDSafeAreaRect;
import com.immomo.mls.util.AndroidUtil;

import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;


/**
 * Created by zhang.ke
 * wiki:https://moji.wemomo.com/doc#/detail/89621
 * https://moji.wemomo.com/doc#/detail/93144
 * <p>
 * Safe Area适配概念
 * <p>
 * 为避免两端上布局起始位置的差异带来的适配问题，添加一个安全区域概念（Safe Area）,
 * 开启Safe Area后，开发人只需要关注页面具体内容，不需要为各种设备的不同页面模式去适配顶部开始距离和底部留白的高度，MLN层会自动适配不同方位上的安全区域。
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
 * safeAreaInsets功能描述补充：
 * 安全区域的原则：确保在用户开启以后，布局的内容不会被电量栏、刘海、底部导航栏等遮挡。专注于内容。
 * 安全区域会判断，手机的全屏、沉浸式、非全屏、刘海屏等。并提供扩展接口。
 * 如需手动去适配上述机型。用户可以用safeAreaInsets*系列方法，获取安全填充距离。手动设置margin属性。
 * safeAreaInsets系列方法，只会在可能存在遮挡的场景，返回填充值。（如：全屏带刘海、沉浸式等）。其余情况返回：0；（如：非全屏、全屏无刘海等）
 * <p>
 * {@link DefaultSafeAreaManager#setSafeAreaAdapter(UDSafeAreaRect, UDLuaView)}
 * 安全区域适配器。主要用于自定义安全区域的偏移
 * on 2019/11/5
 */
public class DefaultSafeAreaManager implements SafeAreaConstants {

    private int[] areas;
    private int area = SafeAreaConstants.CLOSE;//默认关闭
    private Context context;
    private UDSafeAreaRect settedRect;//用户设置的rect，默认为空
    private MLNSafeAreaAdapter safeAreaAdapter;

    public DefaultSafeAreaManager(Context context) {
        this.context = context;
        safeAreaAdapter = MLSAdapterContainer.getSafeAreaAdapter();//获取默认/外部安全区域适配器，
        areas = new int[4];
    }

    public void updataArea(UDLuaView window) {
        safeArea(this.area, window);
    }

    public void safeArea(@SafeArea int area, UDLuaView window) {
        if (window == null) {
            return;
        }
        this.area = area;

        boolean hasAdapter = settedRect != null;
        boolean result = safeAreaAdapter.needSafeArea(context);

        areas[0] = window.getPaddingLeft();
        areas[1] = window.getPaddingTop();
        areas[2] = window.getPaddingRight();
        areas[3] = window.getPaddingBottom();

        if ((area & LEFT) == LEFT) {
            /*预留*/
            areas[0] = hasAdapter ? areas[0] + settedRect.getRect().left : areas[0];
        }
        if ((area & TOP) == TOP) {
            areas[1] = result
                    ? areas[1] + (hasAdapter ? settedRect.getRect().top : AndroidUtil.getStatusBarHeight(context))
                    : areas[1];
        }
        if ((area & RIGHT) == RIGHT) {
            /*预留*/
            areas[2] = hasAdapter ? areas[2] + settedRect.getRect().right : areas[2];
        }
        if ((area & BOTTOM) == BOTTOM) {
            //LuaSDk目前的沉浸式，不会隐藏底部导航栏，所以BOTTOM区域不需要
            areas[3] = hasAdapter ? areas[3] + settedRect.getRect().bottom : areas[3];
        }

        window.getView().setPadding(areas[0], areas[1], areas[2], areas[3]);
    }


    public LuaValue[] safeAreaInsetsTop() {
        return LuaNumber.rNumber(safeAreaAdapter.needSafeArea(context)
                ? settedRect != null ? settedRect.getRect().top : AndroidUtil.getStatusBarHeight(context)
                : 0);
    }

    public LuaValue[] safeAreaInsetsBottom() {

        return LuaNumber.rNumber(settedRect != null ? settedRect.getRect().bottom : 0);
    }

    public LuaValue[] safeAreaInsetsLeft() {

        return LuaNumber.rNumber(settedRect != null ? settedRect.getRect().left : 0);
    }

    public LuaValue[] safeAreaInsetsRight() {

        return LuaNumber.rNumber(settedRect != null ? settedRect.getRect().right : 0);
    }

    /**
     * 安全区域适配器。主要用于自定义安全区域的偏移
     */
    public void setSafeAreaAdapter(UDSafeAreaRect safeAreaAdapter, UDLuaView window) {
        this.settedRect = safeAreaAdapter;
        updataArea(window);
    }
}
