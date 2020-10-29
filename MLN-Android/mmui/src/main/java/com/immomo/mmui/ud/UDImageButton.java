/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import com.facebook.yoga.YogaEdge;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.ui.LuaImageButton;
import com.immomo.mmui.weight.layout.IYogaGroup;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by XiongFangyu on 2018/8/3.
 */
@LuaApiUsed
public class UDImageButton extends UDImageView<LuaImageButton> {

    public static final String LUA_CLASS_NAME = "ImageButton";

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDImageButton(long L) {
        super(L);
    }

    @Override
    protected LuaImageButton<UDImageButton> newView(LuaValue[] init) {
        return new LuaImageButton<>(getContext(), this);
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
    //<editor-fold desc="API">
    @LuaApiUsed
    public void setImage(String normal, String press) {
        getView().setImage(normal, press);
    }

    /**
     * iOS只在文本控件中支持
     */
    @Override
    public void padding(double t, double r, double b, double l) {
        mPaddingTop = DimenUtil.dpiToPx(t);
        mPaddingRight = DimenUtil.dpiToPx(r);
        mPaddingBottom = DimenUtil.dpiToPx(b);
        mPaddingLeft = DimenUtil.dpiToPx(l);

        if (!(this instanceof IYogaGroup)) {
            setLeanPadding();//叶子节点，需要设置view的padding
        }
        //为了识别NaN，不能使用int
        mNode.setPadding(YogaEdge.TOP,  mPaddingTop);
        mNode.setPadding(YogaEdge.RIGHT,mPaddingRight);
        mNode.setPadding(YogaEdge.BOTTOM, mPaddingBottom);
        mNode.setPadding(YogaEdge.LEFT, mPaddingLeft);
        view.requestLayout();
    }
    //</editor-fold>
}