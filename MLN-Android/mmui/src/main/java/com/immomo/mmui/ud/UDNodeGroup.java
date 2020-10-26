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

import androidx.annotation.NonNull;

import com.facebook.yoga.FlexNode;
import com.facebook.yoga.YogaAlign;
import com.facebook.yoga.YogaJustify;
import com.facebook.yoga.YogaWrap;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ILViewGroup;
import com.immomo.mmui.gesture.ArgoTouchUtil;
import com.immomo.mmui.ui.LuaNodeLayout;
import com.immomo.mmui.weight.layout.IFlexLayout;
import com.immomo.mmui.weight.layout.IVirtualLayout;
import com.immomo.mmui.weight.layout.IYogaGroup;
import com.immomo.mmui.weight.layout.VirtualLayout;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.DisposableIterator;
import org.luaj.vm2.utils.LuaApiUsed;


@LuaApiUsed
public class UDNodeGroup<V extends VirtualLayout & ILViewGroup> extends UDView<V> implements IYogaGroup {
    public static final String LUA_CLASS_NAME = "_BaseFlexGroup";
    private boolean disableVirtual;//lua层禁用虚拟 开关

    @Override
    protected V newView(LuaValue[] init) {
        return (V) new LuaNodeLayout<>(getContext(), this);
    }

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDNodeGroup(long L) {
        super(L, null);
    }

    @CGenerate
    @LuaApiUsed
    protected UDNodeGroup(long L, boolean disableVirtual) {
        super(L, null);
        this.disableVirtual = disableVirtual;
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

    //<editor-fold desc="native method">
    /**
     * 初始化方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>

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
    public void addView(UDView v) {
        if (v == null) {
            ErrorUtils.debugLuaError("addView方法中不能传入nil!", globals);
        }
        insertView(v, 0);
    }

    @LuaApiUsed
    public void removeAllSubviews() {
        V v = getView();
        if (v == null)
            return;

        if (((IVirtualLayout) v).isVirtual()) {
            removeVirtualAllSubs((IVirtualLayout) v);
            return;
        }
        v.removeAllViews();
    }

    @LuaApiUsed
    public void children(LuaTable children) {
        DisposableIterator<LuaTable.KV> iterator = children.iterator();
        if (iterator == null)
            return;
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
    }

    @LuaApiUsed
    public void setMainAxis(int j) {
        mNode.setJustifyContent(YogaJustify.fromInt(j));
        view.requestLayout();
    }

    @LuaApiUsed
    public int getMainAxis() {
        return mNode.getJustifyContent().intValue();
    }

    @LuaApiUsed
    public void setCrossAxis(int a) {
        mNode.setAlignItems(YogaAlign.fromInt(a));
        view.requestLayout();
    }

    @LuaApiUsed
    public int getCrossAxis() {
        return mNode.getAlignItems().intValue();
    }

    @LuaApiUsed
    public void setCrossContent(int i) {
        mNode.setAlignContent(YogaAlign.fromInt(i));
        view.requestLayout();
    }

    @LuaApiUsed
    public int getCrossContent() {
        return mNode.getAlignContent().intValue();
    }

    @LuaApiUsed
    public void setWrap(int w) {
        mNode.setWrap(YogaWrap.fromInt(w));
        view.requestLayout();
    }

    @LuaApiUsed
    public int getWrap() {
        return mNode.getWrap().intValue();
    }

    @LuaApiUsed
    public void dispatchTouchTarget(float x, float y, int count) {
        ArgoTouchUtil.createDownTouch(this, x, y, count);
    }

    @LuaApiUsed
    public void insertView(UDView view, int index) {
        index --;
        V v = getView();
        if (v == null)
            return;
        View sub = view.getView();
        if (sub == null)
            return;
        ViewGroup.LayoutParams layoutParams = sub.getLayoutParams();

        if (index < 0) {
            index = -1;
        } else if (index > getView().getChildCount()) {
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
    //</editor-fold>

    //<editor-fold desc="other">

    protected void removeVirtualAllSubs(@NonNull IVirtualLayout v) {
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

    public boolean isDisableVirtual() {
        return disableVirtual;
    }
    //</editor-fold>
}