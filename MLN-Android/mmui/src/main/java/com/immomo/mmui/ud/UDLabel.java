/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.TypedValue;
import android.view.View;
import android.widget.TextView;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.TypeFaceAdapter;
import com.immomo.mls.fun.constants.BreakMode;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ILView;
import com.immomo.mmui.ui.LuaLabel;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.List;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed
public class UDLabel<U extends TextView & ILView> extends UDView<U> {

    public static final String LUA_CLASS_NAME = "Label";

    private int maxLines = 1;
    private UDStyleString styleString;

    private SpannableStringBuilder mSpannableStringBuilder;
    LuaFunction selectedFunction;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDLabel(long L) {
        super(L, null);
    }

    @Override
    protected U newView(LuaValue[] init) {
        return (U) new LuaLabel(getContext(), this);
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

    //<editor-fold desc="API">
    //<editor-fold desc="Property">
    @LuaApiUsed
    protected void setText(String text) {
        if (styleString != null)
            styleString.destroy();
        styleString = null;

        getView().setText(text);
        getFlexNode().dirty();
        getView().requestLayout();
    }

    @LuaApiUsed
    protected String getText() {
        return getView().getText().toString();
    }

    @LuaApiUsed
    public void setTextAlign(int g) {
        getView().setGravity(g);
    }

    @LuaApiUsed
    public int getTextAlign() {
        return getView().getGravity();
    }

    @LuaApiUsed
    public void setFontSize(float s) {
        getView().setTextSize(TypedValue.COMPLEX_UNIT_SP, s);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public float getFontSize() {
        return DimenUtil.pxToSp(getView().getTextSize());
    }

    @LuaApiUsed
    public void setTextColor(UDColor color) {
        if (styleString != null) {
            styleString.setFontColor(color);
            getView().setText(styleString.getText());
        }

        getView().setTextColor(color.getColor());
    }

    @LuaApiUsed
    public UDColor getTextColor() {
        UDColor ret = new UDColor(getGlobals(), 0);
        ret.setColor(getView().getTextColors().getDefaultColor());
        return ret;
    }

    @LuaApiUsed
    protected void setLines(int i) {
        maxLines = i <= 0 ? Integer.MAX_VALUE : i;
        getView().setSingleLine(false);
        getView().setMaxLines(maxLines);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    protected int getLines() {
        return maxLines == Integer.MAX_VALUE ? 0 : maxLines;
    }

    @LuaApiUsed
    public void setBreakMode(int i) {
        if (i < 0) {
            getView().setEllipsize(null);
        } else {
            if (i != BreakMode.TAIL && maxLines > 1) {
                ErrorUtils.debugAlert("警告：多行情况下，不支持非TAIL的模式", globals);
            }
            getView().setEllipsize(TextUtils.TruncateAt.values()[i]);
        }
    }

    @LuaApiUsed
    public int getBreakMode() {
        TextUtils.TruncateAt a = getView().getEllipsize();
        if (a == null)
            return -1;
        return a.ordinal();
    }

    @LuaApiUsed
    public void setStyleText(UDStyleString styleString) {
        if (this.styleString != null)
            this.styleString.destroy();
        this.styleString = styleString;
        this.styleString.setUDView(this);
        getView().setText(styleString.getText());
        getFlexNode().dirty();
        getView().requestLayout();
    }

    @LuaApiUsed
    public UDStyleString getStyleText() {
        return this.styleString;
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public void fontNameSize(String name, float size) {
        TypeFaceAdapter a = MLSAdapterContainer.getTypeFaceAdapter();
        if (a != null) {
            getView().setTypeface(a.create(name));
        }
        getView().setTextSize(TypedValue.COMPLEX_UNIT_SP, size);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public void setLineSpacing(float spacing) {
        getView().setLineSpacing(spacing, 1);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public void setTextFontStyle(int s) {
        getFlexNode().dirty();
        getView().setTypeface(null, s);
    }

    // 设置为 false  可以修复文字内容偏下问题 安卓私有方法
    @LuaApiUsed
    public void a_setIncludeFontPadding(boolean in) {
        getFlexNode().dirty();
        getView().setIncludeFontPadding(in);
    }

    @LuaApiUsed
    public void addTapTexts(UDArray targetTextsArray, LuaFunction selectedFunction, UDColor targetTextColor) {
        if (targetTextsArray == null)
            return;

        this.selectedFunction = selectedFunction;

        List textList = targetTextsArray.getArray();
        String finalValue = getView().getText().toString();

        initSpannableStringBuilder(finalValue);

        if (textList == null)
            return;

        for (int i = 0, size = textList.size(); i < size; i++) {
            String singleValue = (String) textList.get(i);

            if (finalValue.contains(singleValue)) {
                int start = finalValue.indexOf(singleValue);
                int end = start + singleValue.length();
                if (targetTextColor != null) {
                    mSpannableStringBuilder.setSpan(new ForegroundColorSpan(targetTextColor.getColor()), start, end,
                            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                    mSpannableStringBuilder.setSpan(new SelectedClickSpan(singleValue, i + 1), start, end,
                            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                }
            }
        }

        getView().setText(mSpannableStringBuilder);
        getView().setMovementMethod(LinkMovementMethod.getInstance());
        (getView()).setHighlightColor(getContext().getResources().getColor(android.R.color.transparent));
        getFlexNode().dirty();
    }

    private void initSpannableStringBuilder(String finalValue) {
        if (mSpannableStringBuilder == null)
            mSpannableStringBuilder = new SpannableStringBuilder();

        mSpannableStringBuilder.clear();
        mSpannableStringBuilder.append(finalValue);
    }

    //</editor-fold>
    //</editor-fold>

    class SelectedClickSpan extends ClickableSpan {

        String textValue = "";
        int position;

        public SelectedClickSpan(String value, int position) {
            this.textValue = value;
            this.position = position;
        }

        @Override
        public void onClick(View v) {
            if (selectedFunction != null)
                selectedFunction.invoke(varargsOf(LuaString.valueOf(textValue), LuaNumber.valueOf(position)));
        }

        @Override
        public void updateDrawState(TextPaint ds) {
            ds.setUnderlineText(false);
        }
    }
}