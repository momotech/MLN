/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.anim.animatable;

import android.view.View;

import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.ui.IScrollView;
import com.immomo.mmui.ui.LuaRecyclerView;

/**
 * 专门用于Scrollview和RecycleView 内容滚动的动画
 * Created by wang.yang on 2020-07-23
 */
public class ContentOffsetAnimatable extends Animatable {

    @Override
    public void writeValue(View view, float[] upDateValues) {
        if (view instanceof LuaRecyclerView) {
            LuaRecyclerView luaRecyclerView = (LuaRecyclerView) view;
            if (luaRecyclerView.isViewPager()) {
                luaRecyclerView.setPagerContentOffset(DimenUtil.dpiToPx(upDateValues[0]),
                        DimenUtil.dpiToPx(upDateValues[1]));
            } else {
                luaRecyclerView.scrollTo(DimenUtil.dpiToPx(upDateValues[0]),
                        DimenUtil.dpiToPx(upDateValues[1]));
            }
        } else if (view instanceof IScrollView) {
            view.scrollTo(DimenUtil.dpiToPx(upDateValues[0]),
                    DimenUtil.dpiToPx(upDateValues[1]));
        }
    }

    @Override
    public void readValue(View view, float[] upDateValues) {
        if (view instanceof LuaRecyclerView) {
            LuaRecyclerView luaRecyclerView = (LuaRecyclerView) view;
            if (luaRecyclerView.isViewPager()) {
                upDateValues[0] = DimenUtil.pxToDpi(luaRecyclerView.getPagerContentOffsetX());
                upDateValues[1] = DimenUtil.pxToDpi(luaRecyclerView.getPagerContentOffsetY());
            } else {
                upDateValues[0] = DimenUtil.pxToDpi(luaRecyclerView.getScrollOffsetX());
                upDateValues[1] = DimenUtil.pxToDpi(luaRecyclerView.getScrollOffsetY());
            }
        } else if (view instanceof IScrollView) {
            upDateValues[0] = DimenUtil.pxToDpi(view.getScrollX());
            upDateValues[1] = DimenUtil.pxToDpi(view.getScrollY());
        }
    }

    @Override
    public int getValuesCount() {
        return 2;
    }
}
