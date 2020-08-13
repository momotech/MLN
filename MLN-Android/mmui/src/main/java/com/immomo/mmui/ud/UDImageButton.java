/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.widget.ImageView;

import com.facebook.yoga.YogaEdge;
import com.immomo.mls.fun.ui.ILuaImageButton;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.ui.LuaImageButton;
import com.immomo.mmui.weight.layout.IYogaGroup;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by XiongFangyu on 2018/8/3.
 */
@LuaApiUsed
public class UDImageButton<I extends ImageView & ILuaImageButton> extends UDImageView<LuaImageButton> {

    public static final String LUA_CLASS_NAME = "ImageButton";

    public static final String[] methods = {
            "setImage",
            "padding"
    };

    @LuaApiUsed
    public UDImageButton(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected LuaImageButton newView(LuaValue[] init) {
        return new LuaImageButton(getContext(), this, init);
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] setImage(LuaValue[] values) {
        String normal = null;
        String press = null;
        if (values.length > 0 && values[0] != null) {
            normal = values[0].toJavaString();
        }
        if (values.length > 1 && values[1] != null) {
            press = values[1].toJavaString();
        }
        ((LuaImageButton) getView()).setImage(normal, press);
        return null;
    }

    /**
     * iOS只在文本控件中支持
     */
    @LuaApiUsed
    public LuaValue[] padding(LuaValue[] var) {
        mPaddingTop = DimenUtil.dpiToPx((float) var[0].toDouble());
        mPaddingRight = DimenUtil.dpiToPx((float) var[1].toDouble());
        mPaddingBottom = DimenUtil.dpiToPx((float) var[2].toDouble());
        mPaddingLeft = DimenUtil.dpiToPx((float) var[3].toDouble());

        if (!(this instanceof IYogaGroup)) {
            setLeanPadding();//叶子节点，需要设置view的padding
        }
        //为了识别NaN，不能使用int
        mNode.setPadding(YogaEdge.TOP,  DimenUtil.dpiToPxWithNaN(var[0]));
        mNode.setPadding(YogaEdge.RIGHT,DimenUtil.dpiToPxWithNaN(var[1]));
        mNode.setPadding(YogaEdge.BOTTOM, DimenUtil.dpiToPxWithNaN(var[2]));
        mNode.setPadding(YogaEdge.LEFT, DimenUtil.dpiToPxWithNaN(var[3]));
        view.requestLayout();
        return null;
    }
    //</editor-fold>
}