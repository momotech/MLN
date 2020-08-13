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
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ILViewGroup;
import com.immomo.mmui.ui.LuaNodeLayout;
import com.facebook.yoga.YogaAlign;
import com.facebook.yoga.YogaJustify;
import com.facebook.yoga.YogaWrap;
import com.immomo.mmui.weight.layout.IFlexLayout;
import com.immomo.mmui.weight.layout.IVirtualLayout;
import com.immomo.mmui.weight.layout.IYogaGroup;
import com.immomo.mmui.weight.layout.NodeLayout;
import com.immomo.mmui.weight.layout.VirtualLayout;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.DisposableIterator;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.annotation.NonNull;


@LuaApiUsed
public class UDNodeGroup<V extends VirtualLayout & ILViewGroup> extends UDViewGroup<V> implements IYogaGroup {
    public static final String LUA_CLASS_NAME = "_BaseFlexGroup";
    public static final String[] methods = {
        "children",
        "mainAxis", "crossAxis", "crossContent",
        "wrap",
    };
    private boolean disableVirtual;//lua层禁用虚拟 开关

    @Override
    protected V newView(LuaValue[] init) {
        return (V) new LuaNodeLayout<>(getContext(), this);
    }

    @LuaApiUsed
    protected UDNodeGroup(long L, LuaValue[] v) {
        super(L, v);
        if (v.length > 0) {
            disableVirtual = v[0].isBoolean() && v[0].toBoolean();
        }
    }

    public UDNodeGroup(Globals g, V jud) {
        super(g, jud);
    }

    public UDNodeGroup(Globals g) {
        super(g);
    }

    @Override
    protected boolean clipToPadding() {
        return MLSConfigs.defaultClipContainer;
    }

    @Override
    protected boolean clipChildren() {
        return MLSConfigs.defaultClipContainer;
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] children(LuaValue[] var) {
        if (var.length > 0) {
            LuaTable children = var[0].toLuaTable();

            DisposableIterator<LuaTable.KV> iterator = children.iterator();
            if (iterator == null)
                return null;
            while (iterator.hasNext()) {
                LuaValue value = iterator.next().value;
                if (value.isNil()) {
                    ErrorUtils.debugLuaError("children table has nil value!", globals);
                    continue;
                }
                if (AssertUtils.assertUserData(value, UDView.class, "addView", getGlobals()))
                    insertView((UDView) value, -1);
            }
            iterator.dispose();
//            children.destroy();
        }

        return null;
    }

    @LuaApiUsed
    public LuaValue[] mainAxis(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setJustifyContent(YogaJustify.fromInt(var[0].toInt()));
            view.requestLayout();
            return null;
        }

        YogaJustify justify = mNode.getJustifyContent();
        return LuaValue.varargsOf(LuaNumber.valueOf(justify.intValue()));
    }

    @LuaApiUsed
    public LuaValue[] crossAxis(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setAlignItems(YogaAlign.fromInt(var[0].toInt()));
            view.requestLayout();
            return null;
        }

        YogaAlign alignItems = mNode.getAlignItems();
        return LuaValue.varargsOf(LuaNumber.valueOf(alignItems.intValue()));
    }

    @LuaApiUsed
    public LuaValue[] crossContent(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setAlignContent(YogaAlign.fromInt(var[0].toInt()));
            view.requestLayout();
            return null;
        }

        YogaAlign alignContent = mNode.getAlignContent();
        return LuaValue.varargsOf(LuaNumber.valueOf(alignContent.intValue()));
    }

    @LuaApiUsed
    public LuaValue[] wrap(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setWrap(YogaWrap.fromInt(var[0].toInt()));
            view.requestLayout();
            return null;
        }

        YogaWrap wrap = mNode.getWrap();
        return LuaValue.varargsOf(LuaNumber.valueOf(wrap.intValue()));
    }
    //</editor-fold>

    @Override
    public void insertView(UDView view, int index) {
        V v = getView();
        if (v == null)
            return;
        View sub = view.getView();
        if (sub == null)
            return;
        ViewGroup.LayoutParams layoutParams = sub.getLayoutParams();

        if (index > getView().getChildCount()) {
            index = -1;//index越界时，View放在末尾
        }

        //判断Layout，是否需要转换virtual
        if (sub instanceof IVirtualLayout &&
            !((IVirtualLayout) sub).isVirtual() &&//非虚拟layout
            view.needConvertVirtual()) {//无交互或背景
            ((IVirtualLayout) sub).changeToVirtual();
        }

        if (view instanceof IFlexLayout) {
            if (layoutParams != null) {
                v.addView(LuaViewUtil.removeFromParent(sub), index, layoutParams, ((IFlexLayout) view).getFlexNode());
            } else {
                v.addView(LuaViewUtil.removeFromParent(sub), index, ((IFlexLayout) view).getFlexNode());
            }
        } else {
            if (layoutParams != null) {
                v.addView(LuaViewUtil.removeFromParent(sub), index, layoutParams);
            } else {
                v.addView(LuaViewUtil.removeFromParent(sub), index);
            }
        }
    }

    public boolean isDisableVirtual() {
        return disableVirtual;
    }
}