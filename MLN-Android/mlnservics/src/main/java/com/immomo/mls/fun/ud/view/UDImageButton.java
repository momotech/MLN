/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

import android.widget.ImageView;

import com.immomo.mls.fun.ui.ILuaImageButton;
import com.immomo.mls.fun.ui.LuaImageButton;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by XiongFangyu on 2018/8/3.
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDImageButton<I extends ImageView & ILuaImageButton> extends UDImageView<LuaImageButton> {

    public static final String LUA_CLASS_NAME = "ImageButton";

    public static final String[] methods = {
            "setImage",
            "padding"
    };

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(value = UDImageButton.class))
    })
    public UDImageButton(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected LuaImageButton newView(LuaValue[] init) {
        return new LuaImageButton(getContext(), this, init);
    }

    //<editor-fold desc="API">
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(String.class),
                    @LuaApiUsed.Type(String.class)
            }, returns = @LuaApiUsed.Type(UDImageButton.class))
    })
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
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDImageButton.class))
    })
    public LuaValue[] padding(LuaValue[] values) {
        int topvalue = DimenUtil.dpiToPx(values[0].toInt());
        int rightvalue = DimenUtil.dpiToPx(values[1].toInt());
        int bottomvalue = DimenUtil.dpiToPx(values[2].toInt());
        int leftvalue = DimenUtil.dpiToPx(values[3].toInt());

        getView().setPadding(leftvalue, topvalue, rightvalue, bottomvalue);

        return null;
    }
    //</editor-fold>
}