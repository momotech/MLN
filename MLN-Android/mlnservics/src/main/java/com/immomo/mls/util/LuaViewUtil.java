/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import android.annotation.TargetApi;
import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import com.immomo.mls.LuaViewManager;

import org.luaj.vm2.Globals;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * LuaView相关的一些工具类
 *
 * @author song
 * @date 15/9/21
 */
public class LuaViewUtil {

    private static final AtomicInteger sNextGeneratedId = new AtomicInteger(1);

    /**
     * set id
     *
     * @param view
     */
    public static void setId(View view) {
        if (view != null) {
            try {
                view.setId(View.generateViewId());
            } catch (Exception e) {
                view.setId(generateViewId());
            }
        }
    }

    /**
     * Generate a value suitable for use in {@link View#setId(int)}.
     * This value will not collide with ID values generated at build time by aapt for R.id.
     *
     * @return a generated ID value
     */
    private static int generateViewId() {
        for (; ; ) {
            final int result = sNextGeneratedId.get();
            // aapt-generated IDs have the high byte nonzero; clamp to the range under that.
            int newValue = result + 1;
            if (newValue > 0x00FFFFFF) newValue = 1; // Roll over to 1, not 0.
            if (sNextGeneratedId.compareAndSet(result, newValue)) {
                return result;
            }
        }
    }

    /**
     * 设置背景
     *
     * @param view
     * @param drawable
     */
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    public static void setBackground(View view, Drawable drawable) {
        if (view != null) {
            view.setBackground(drawable);
        }
    }

    //--------------------------------------------remove--------------------------------------------

    /**
     * remove all views
     *
     * @param viewGroup
     */
    public static void removeAllViews(ViewGroup viewGroup) {
        if (viewGroup != null) {
            if (viewGroup.isInLayout()) {
                viewGroup.removeAllViewsInLayout();
            } else {
                viewGroup.removeAllViews();
            }
        }
    }

    /**
     * remove a view
     *
     * @param parent
     * @param view
     */
    public static void removeView(ViewGroup parent, View view) {
        //这里不使用post来做，这样代码更可控，而是改为将refresh下拉动作延后一帧处理，见@link
        //这里调用removeViewInLayout方法，可以在onLayout的时候调用，否则会产生问题
        if (parent != null && view != null) {
            if (parent.isInLayout()) {
                parent.removeViewInLayout(view);
            } else {
                parent.removeView(view);
            }
        }
    }

    /**
     * 从父容器中移除该view
     *
     * @param view
     * @return
     */
    public static View removeFromParent(View view) {
        if (view != null && view.getParent() instanceof ViewGroup) {
            removeView((ViewGroup) view.getParent(), view);
        }
        return view;
    }

    //------------------------------------------layout params---------------------------------------

    /**
     * create layout params MATCH_PARENT, MATCH_PARENT
     *
     * @return
     */
    public static RelativeLayout.LayoutParams createRelativeLayoutParamsMM() {
        return new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    }

}