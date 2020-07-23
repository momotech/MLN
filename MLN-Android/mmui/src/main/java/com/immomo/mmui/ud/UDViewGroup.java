/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.view.View;
import android.view.ViewGroup;

import com.facebook.yoga.FlexNode;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ui.LuaViewGroup;
import com.immomo.mmui.weight.layout.IVirtualLayout;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
@LuaApiUsed
public class UDViewGroup<V extends ViewGroup> extends UDNodeView<V> {
    public static final String[] LUA_CLASS_NAME = {"View", "AnimationZone"};
    public static final String[] methods = {
            "addView", "insertView", "removeAllSubviews"
    };

    protected UDViewGroup(long L, LuaValue[] v) {
        super(L, v);
    }

    public UDViewGroup(Globals g, V jud) {
        super(g, jud);
    }

    public UDViewGroup(Globals g) {
        super(g);
    }

    @Override
    protected V newView(LuaValue[] init) {
        return (V) new LuaViewGroup(getContext(), this);
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] addView(LuaValue[] var) {
        if (var.length == 1) {
            if (var[0].isNil()) {
                ErrorUtils.debugLuaError("call addView(nil)!", globals);
                return null;
            }
            if (AssertUtils.assertUserData(var[0], UDView.class, "addView", getGlobals()))
                insertView((UDView) var[0], -1);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] insertView(LuaValue[] var) {
        LuaValue v = var[0];
        insertView(v.isNil() ? null : (UDView) v, var[1].toInt() - 1);
        return null;
    }

    protected void insertView(UDView view, int index) {
        V v = getView();
        if (v == null || view == null)
            return;
        View sub = view.getView();
        if (sub == null)
            return;
        ViewGroup.LayoutParams layoutParams = sub.getLayoutParams();
        //TODO yoga
//        if (v instanceof ILViewGroup) {
//            ILViewGroup g = (ILViewGroup) v;
//            layoutParams = g.applyLayoutParams(layoutParams,
//                    view.udLayoutParams);
//            layoutParams = g.applyChildCenter(layoutParams, view.udLayoutParams);
//        }

        if (index > getView().getChildCount()) {
            index = -1;//index越界时，View放在末尾
        }

        if (sub.getParent() != null) {//和ios统一报错，如果addView的View有parent
            ErrorUtils.debugLuaError("This child view has a parent view . It is recommended to removing it from the original parent view and then add it .", getGlobals());
        }
        if (layoutParams != null) {
            v.addView(LuaViewUtil.removeFromParent(sub), index, layoutParams);
        } else {
            v.addView(LuaViewUtil.removeFromParent(sub), index);
        }
    }

    @LuaApiUsed
    public LuaValue[] removeAllSubviews(LuaValue[] p) {
        V v = getView();
        if (v == null)
            return null;

        if (v instanceof IVirtualLayout && ((IVirtualLayout) v).isVirtual()) {
            removeVirtualAllSubs((IVirtualLayout) v);
            return null;
        }
        v.removeAllViews();
        return null;
    }


    void removeVirtualAllSubs(@NonNull IVirtualLayout v) {
        FlexNode node = v.getFlexNode();
        if (node != null) {
            final int count = node.getChildCount();
            if (count <= 0) {
                return;
            }
            for (int i = count - 1; i >= 0; i--) {
                FlexNode subNode = node.getChildAt(i);
                View view = (View) subNode.getData();
                LuaViewUtil.removeFromParent(view);
            }
        }
    }
    //</editor-fold>
}