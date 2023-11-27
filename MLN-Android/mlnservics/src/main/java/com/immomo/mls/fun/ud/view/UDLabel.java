/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

import android.graphics.Typeface;
import android.os.Build;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.TypeFaceAdapter;
import com.immomo.mls.fun.constants.BreakMode;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ud.UDStyleString;
import com.immomo.mls.fun.ui.LuaLabel;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.ErrorUtils;

import kotlin.Unit;
import kotlin.jvm.functions.Function2;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.List;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDLabel<U extends TextView> extends UDView<U> {

    public static final String LUA_CLASS_NAME = "Label";

    public static final String[] methods = {
            "text",
            "textAlign",
            "fontSize",
            "textColor",
            "lines",
            "breakMode",
            "styleText",
            "setTextBold",
            "fontNameSize",
            "setLineSpacing",
            "setTextFontStyle",
            "addTapTexts",
            "setAutoFit",
            "setMaxWidth",
            "setMaxHeight",
            "setMinWidth",
            "setMinHeight",
            "a_setIncludeFontPadding",
    };

    private int maxLines = 1;
    private UDStyleString styleString;

    private SpannableStringBuilder mSpannableStringBuilder;
    LuaFunction selectedFunction;

    private int breakMode = BreakMode.CLIPPING;


    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public UDLabel(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected U newView(LuaValue[] init) {
        return (U) new LuaLabel(getContext(), this, init);
    }


    //<editor-fold desc="API">
    //<editor-fold desc="Property">
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(String.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(String.class)),
    })
    public LuaValue[] text(LuaValue[] var) {
        String text = null;
        if (var.length == 1) {
            text = var[0].toJavaString();

            if (var[0].isNil())
                text = "";
        }
        if (text != null) {
            setText(text);
            return null;
        }
        return varargsOf(LuaString.valueOf(getView().getText().toString()));
    }

    protected void setText(String text) {
        if (styleString != null)
            styleString.destroy();
        styleString = null;

        try {
            getView().setText(text);
        } catch (Exception e) {
            LogUtil.w("Label text()  bridge   Exception ", e);
        }
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class)),
    })
    public LuaValue[] textAlign(LuaValue[] var) {
        if (var.length == 1) {
            getView().setGravity(var[0].toInt());
            return null;
        }
        return varargsOf(LuaNumber.valueOf(getView().getGravity()));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Double.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Double.class)),
    })
    public LuaValue[] fontSize(LuaValue[] var) {
        if (var.length == 1) {
            getView().setTextSize(TypedValue.COMPLEX_UNIT_SP, (float) var[0].toDouble());
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToSp(getView().getTextSize())));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDColor.class)),
    })
    public LuaValue[] textColor(LuaValue[] var) {
        if (var.length == 1 && var[0] instanceof UDColor) {
            UDColor color = (UDColor) var[0];
            if (styleString != null) {
                styleString.fontColor(var);
                getView().setText(styleString.getText());
            }

            getView().setTextColor(color.getColor());
            return null;
        }

        UDColor ret = new UDColor(getGlobals(), 0);
        ret.setColor(getView().getTextColors().getDefaultColor());
        return varargsOf(ret);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class)),
    })
    public LuaValue[] lines(LuaValue[] var) {
        if (var.length == 1) {
            int i = var[0].toInt();
            if (i == 0 && breakMode != BreakMode.CLIPPING) {
                ErrorUtils.debugAlert("警告：设置lines为0，breakMode只能表现出CLIPPING模式", globals);
            }
            setLines(i);
            return null;
        }
        return varargsOf(maxLines == Integer.MAX_VALUE ? LuaNumber.valueOf(0) : LuaNumber.valueOf(maxLines));
    }

    protected void setLines(int i) {
        maxLines = i <= 0 ? Integer.MAX_VALUE : i;
        getView().setSingleLine(false);
        getView().setMaxLines(maxLines);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class)),
    })
    public LuaValue[] breakMode(LuaValue[] var) {
        if (var.length == 1) {
            int i = var[0].toInt();
            breakMode = i;
            if (i < 0) {
                getView().setEllipsize(null);
            } else {
                if (maxLines > 1 && i == BreakMode.TAIL) {
                    ErrorUtils.debugAlert("警告：多行情况下，不支持非TAIL的模式", globals);
                }

                if(maxLines == Integer.MAX_VALUE && breakMode != BreakMode.CLIPPING) {
                    ErrorUtils.debugAlert("警告：设置lines为0，breakMode只能表现出CLIPPING模式", globals);
                }

                getView().setEllipsize(TextUtils.TruncateAt.values()[i]);
            }
            return null;
        }
        TextUtils.TruncateAt a = getView().getEllipsize();
        if (a == null)
            return varargsOf(LuaNumber.valueOf(-1));
        return varargsOf(LuaNumber.valueOf(a.ordinal()));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDStyleString.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDStyleString.class)),
    })
    public LuaValue[] styleText(LuaValue[] var) {
        if (var.length == 1) {
            if (styleString != null)
                styleString.destroy();
            this.styleString = (UDStyleString) var[0];
            this.styleString.setUDView(this);
            getView().setMovementMethod(LinkMovementMethod.getInstance());
            getView().setText(styleString.getText());
            return null;
        }
        if (this.styleString == null)
            return rNil();
        return varargsOf(this.styleString);
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @Deprecated
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] setTextBold(LuaValue[] var) {
        getView().setTypeface(getView().getTypeface(), Typeface.BOLD);
        deprecatedMethodPrint(UDLabel.class.getSimpleName(), "setTextBold()");
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(String.class),
                    @LuaApiUsed.Type(Double.class)
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] fontNameSize(LuaValue[] var) {
        String name = var[0].toJavaString();
        float size = (float) var[1].toDouble();
        TypeFaceAdapter a = MLSAdapterContainer.getTypeFaceAdapter();
        if (a != null) {
            getView().setTypeface(a.create(name));
        }
        getView().setTextSize(TypedValue.COMPLEX_UNIT_SP, size);
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Double.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Double.class))
    })
    public LuaValue[] setLineSpacing(LuaValue[] spacing) {
        if (spacing.length == 1) {
            getView().setLineSpacing((float) spacing[0].toDouble(), 1);
            return null;
        }

        return varargsOf(LuaNumber.valueOf(getView().getLineSpacingExtra()));

    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] setTextFontStyle(LuaValue[] style) {
        getView().setTypeface(null, style[0].toInt());
        return null;
    }

    @Deprecated
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] setAutoFit(LuaValue[] autoFit) {
        udLayoutParams.useRealMargin = false;
        if (autoFit[0].toBoolean()) {
            ViewGroup.LayoutParams p = getView().getLayoutParams();
            if (p != null) {
                p.width = ViewGroup.LayoutParams.WRAP_CONTENT;
                p.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            } else {
                p = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            }
            getView().setLayoutParams(p);
        }

        deprecatedMethodPrint(UDLabel.class.getSimpleName(), "setAutoFit()");

        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] setMaxWidth(LuaValue[] w) {
        getView().setMaxWidth((int) DimenUtil.dpiToPx((float) w[0].toDouble()));
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] setMaxHeight(LuaValue[] h) {
        maxLines = Integer.MAX_VALUE;
        getView().setSingleLine(false);
        getView().setMaxHeight((int) DimenUtil.dpiToPx((float) h[0].toDouble()));
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] setMinWidth(LuaValue[] minWidth) {
        getView().setMinWidth((int) DimenUtil.dpiToPx((float) minWidth[0].toDouble()));
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] setMinHeight(LuaValue[] minHeight) {
        maxLines = Integer.MAX_VALUE;
        getView().setSingleLine(false);
        getView().setMinHeight((int) DimenUtil.dpiToPx((float) minHeight[0].toDouble()));
        return null;
    }

    @LuaApiUsed(ignore = true)
    public LuaValue[] notClip(LuaValue[] p) {
        return null;
    }

    // 设置为 false  可以修复文字内容偏下问题 安卓私有方法
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class),
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] a_setIncludeFontPadding(LuaValue[] values) {
        getView().setIncludeFontPadding(values[0].toBoolean());
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = UDArray.class),
                    @LuaApiUsed.Type(value = Function2.class,typeArgs = {
                            String.class, Integer.class, Unit.class
                    }),
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(UDLabel.class))
    })
    public LuaValue[] addTapTexts(LuaValue[] vars) {
        UDArray targetTextsArray = vars.length > 0 ? (UDArray) vars[0] : null;
        LuaFunction selectedFunction = vars.length > 1 ? (LuaFunction) vars[1] : null;
        UDColor targetTextColor = vars.length > 2 ? (UDColor) vars[2] : null;

        if (targetTextsArray == null)
            return null;

        this.selectedFunction = selectedFunction;

        List textList = targetTextsArray.getArray();
        String finalValue = getView().getText().toString();

        initSpannableStringBuilder(finalValue);

        if (textList == null)
            return null;

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
        return null;
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