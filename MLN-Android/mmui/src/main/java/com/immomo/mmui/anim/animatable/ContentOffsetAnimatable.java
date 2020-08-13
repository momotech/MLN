/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.anim.animatable;

import android.view.View;

import com.immomo.mls.fun.other.Point;
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
                luaRecyclerView.pagerContentOffset(upDateValues[0], upDateValues[1]);
            } else {
                luaRecyclerView.setContentOffset(new Point(upDateValues[0], upDateValues[1]));
            }
        } else if (view instanceof IScrollView) {
            ((IScrollView) view).setContentOffset(new Point(upDateValues[0], upDateValues[1]));
        }
    }

    @Override
    public void readValue(View view, float[] upDateValues) {
        if (view instanceof LuaRecyclerView) {
            LuaRecyclerView luaRecyclerView = (LuaRecyclerView) view;
            float[] contentOffset;
            if (luaRecyclerView.isViewPager()) {
                contentOffset = luaRecyclerView.getPagerContentOffset();
            } else {
                Point offset = luaRecyclerView.getContentOffset();
                contentOffset = new float[]{offset.getX(), offset.getY()};
            }
            upDateValues[0] = contentOffset[0];
            upDateValues[1] = contentOffset[1];
        } else if (view instanceof IScrollView) {
            Point contentOffset = ((IScrollView) view).getContentOffset();
            upDateValues[0] = contentOffset.getX();
            upDateValues[1] = contentOffset.getY();
        }
    }

    @Override
    public int getValuesCount() {
        return 2;
    }
}
