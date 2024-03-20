package com.immomo.mmui.util;

import android.annotation.TargetApi;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import com.facebook.yoga.FlexNode;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mmui.ui.LuaNodeLayout;

import java.util.concurrent.atomic.AtomicInteger;

import androidx.annotation.NonNull;

/**
 * 虚拟布局相关的一些工具类
 *
 * @author song
 * @date 15/9/21
 */
public class VirtualViewUtil {

    /**
     * @param view 必须是view
     */
    public static boolean isNotVirtualView(Object view) {
        return !(view instanceof LuaNodeLayout) || !((LuaNodeLayout) view).isVirtual();
    }

    /**
     * 从父容器中移除该view
     *
     * @param view
     * @return
     */
    public static View removeFromParent(View view, FlexNode node) {
        if (view != null && view.getParent() instanceof ViewGroup) {
            LuaViewUtil.removeView((ViewGroup) view.getParent(), view);
        } else if (view instanceof LuaNodeLayout && ((LuaNodeLayout) view).isVirtual()) {
            FlexNode owner = node.getOwner();
            if (owner != null) {
                for (int i = 0; i < owner.getChildCount(); i++) {
                    if (owner.getChildAt(i).equals(node)) {
                        owner.removeChildAt(i);
                        break;
                    }
                }
                ((LuaNodeLayout) view).onVirtualRemoved();
            }
        }
        return view;
    }


}
