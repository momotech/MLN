/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud;

import android.graphics.Paint;
import android.os.Build;
import android.text.Layout;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.StaticLayout;
import android.text.TextPaint;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.BackgroundColorSpan;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.text.style.TypefaceSpan;
import android.text.style.UnderlineSpan;
import android.view.View;

import com.immomo.mls.Environment;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.TypeFaceAdapter;
import com.immomo.mls.fun.constants.StyleImageAlign;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.view.UDLabel;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.ui.LuaLabel;
import com.immomo.mls.fun.weight.span.ImageSpan;
import com.immomo.mls.fun.weight.span.UrlImageSpan;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.LVCallback;
import com.immomo.mls.weight.WeightStyleSpan;
import com.immomo.mls.wrapper.CustomClickableSpan;
import com.immomo.mls.wrapper.Translator;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import org.luaj.vm2.Globals;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed
public class UDStyleString extends JavaUserdata implements UrlImageSpan.ILoadDrawableResult {
    public static final String LUA_CLASS_NAME = "StyleString";
    public static final String[] methods = new String[]{
            "fontName",
            "fontSize",
            "fontWeight",
            "fontStyle",
            "fontColor",
            "backgroundColor",
            "underline",
            "append",
            "calculateSize",
            "setFontNameForRange",
            "setFontSizeForRange",
            "setFontStyleForRange",
            "setFontColorForRange",
            "setBackgroundColorForRange",
            "setUnderlineForRange",
            "showAsImage",
            "setText",
            "imageAlign",
            "setLinkCallback",
    };

    private SpannableStringBuilder text;
    private AbsoluteSizeSpan sizeSpan;
    private WeightStyleSpan weightSpan;
    private ClickableSpan clickableSpan;
    private TypefaceSpan typefaceSpan;
    private int weight;
    private StyleSpan styleSpan;
    private ForegroundColorSpan colorSpan;
    private BackgroundColorSpan backgroundColorSpan;
    private UnderlineSpan underlineSpan;
    private final TextPaint caculatePaint = new TextPaint(Paint.ANTI_ALIAS_FLAG);
    private UrlImageSpan imageSpan;
    private StaticLayout layout;
    private int lastMaxWidth = -1;
    private boolean changeSizePan = false;
    private boolean changeText = false;
    private UDSize lastSize;
    private Size imageSize;
    private HashMap mImageUrlHashmap = new HashMap(); // 用于暂存同一个StyleString 对象，应对业务重复添加此对象
    private int mVerticalAlignment = StyleImageAlign.Default;//图片方向
    private List<StyleSpan> mFontStyleForRangeList;

    public UDStyleString(Globals g, Object jud) {
        super(g, jud);
        text = new SpannableStringBuilder(jud.toString());
        initPaint();
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = String.class, nullable = true)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    protected UDStyleString(long L, LuaValue[] v) {
        super(L, v);
        if (v != null && v.length >= 1) {
            text = new SpannableStringBuilder(v[0].toJavaString());
        } else {
            text = new SpannableStringBuilder();
        }
        initPaint();
    }

    private void initPaint() {
        caculatePaint.setTextSize(DimenUtil.spToPx(14));
    }

    private static Object cloneSpan(Object span) {
        if (span instanceof AbsoluteSizeSpan) {
            return new AbsoluteSizeSpan(((AbsoluteSizeSpan) span).getSize());
        }
        if (span instanceof WeightStyleSpan) {
            return new WeightStyleSpan(((WeightStyleSpan) span).getWeight());
        }
        if (span instanceof TypefaceSpan) {
            return new TypefaceSpan(((TypefaceSpan) span).getFamily());
        }
        if (span instanceof StyleSpan) {
            return new StyleSpan(((StyleSpan) span).getStyle());
        }
        if (span instanceof ForegroundColorSpan) {
            return new ForegroundColorSpan(((ForegroundColorSpan) span).getForegroundColor());
        }
        if (span instanceof BackgroundColorSpan) {
            return new BackgroundColorSpan(((BackgroundColorSpan) span).getBackgroundColor());
        }
        if (span instanceof UnderlineSpan) {
            return new UnderlineSpan();
        }
        return span;
    }

    //<editor-fold desc="API">
    //<editor-fold desc="Property">

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(String.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] fontName(LuaValue[] p) {
        if (p.length == 0) {
            return typefaceSpan == null ? rNil() : rString(typefaceSpan.getFamily());
        }
        if (typefaceSpan != null) {
            removeSpan(typefaceSpan);
        }
        String name = p[0].toJavaString();
        TypeFaceAdapter a = MLSAdapterContainer.getTypeFaceAdapter();
        if (a != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            typefaceSpan = new TypefaceSpan(a.create(name));
            setSpan(typefaceSpan);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] fontSize(LuaValue[] p) {
        if (p.length != 0) {
            if (sizeSpan != null) {
                removeSpan(sizeSpan);
            }
            sizeSpan = new AbsoluteSizeSpan(DimenUtil.spToPx((float) p[0].toDouble()));
            setSpan(sizeSpan);
            changeSizePan = true;
            return null;
        }
        if (sizeSpan == null)
            return rNumber(0);
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToSp(sizeSpan.getSize())));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class))
    })
    public LuaValue[] fontWeight(LuaValue[] p) {
        if (p.length != 0) {
            if (weightSpan != null) {
                removeSpan(weightSpan);
            }
            this.weight = p[0].toInt();
            weightSpan = new WeightStyleSpan(weight);
            setSpan(weightSpan);
            return null;
        }
        return rNumber(this.weight);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class))
    })
    public LuaValue[] fontStyle(LuaValue[] p) {
        if (p.length != 0) {
            if (styleSpan != null) {
                removeSpan(styleSpan);
            }
            removeStyleForRange(text);

            styleSpan = new StyleSpan(p[0].toInt());
            setSpan(styleSpan);
            return null;
        }
        if (styleSpan == null)
            return rNumber(0);
        return rNumber(styleSpan.getStyle());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDColor.class))
    })
    public LuaValue[] fontColor(LuaValue[] p) {
        if (p.length != 0) {
            if (colorSpan != null) {
                removeSpan(colorSpan);
            }
            colorSpan = new ForegroundColorSpan(((UDColor) p[0]).getColor());
            setSpan(colorSpan);
            return null;
        }
        if (colorSpan == null)
            return rNil();
        return varargsOf(new UDColor(globals, colorSpan.getForegroundColor()));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDColor.class))
    })
    public LuaValue[] backgroundColor(LuaValue[] p) {
        if (p.length != 0) {
            if (backgroundColorSpan != null) {
                removeSpan(backgroundColorSpan);
            }
            backgroundColorSpan = new BackgroundColorSpan(((UDColor) p[0]).getColor());
            setSpan(backgroundColorSpan);
            return null;
        }
        if (backgroundColorSpan == null)
            return rNil();
        return varargsOf(new UDColor(globals, backgroundColorSpan.getBackgroundColor()));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function0.class, typeArgs = {Unit.class}),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] setLinkCallback(LuaValue[] p) {
        if (p.length != 0) {
            if (clickableSpan != null) {
                removeSpan(clickableSpan);
            }
            LVCallback callback = ((p.length > 0 && !p[0].isNil()) ? (LVCallback) Translator.fromGlobals(getGlobals()).translateLuaToJava(p[0], LVCallback.class) : null);

            clickableSpan = new CustomClickableSpan(callback, p.length > 1 && p[1].toBoolean(),getColor());
            setSpan(clickableSpan);
            return null;
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class))
    })
    public LuaValue[] underline(LuaValue[] p) {
        if (p.length != 0) {
            int i = p[0].toInt();
            if (i > 0 && underlineSpan == null) {
                underlineSpan = new UnderlineSpan();
                setSpan(underlineSpan);
            } else if (i <= 0 && underlineSpan != null) {
                removeSpan(underlineSpan);
                underlineSpan = null;
            }
            return null;
        }
        return rNumber(underlineSpan != null ? 1 : 0);
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDStyleString.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] append(LuaValue[] p) {
        CharSequence charSequence = ((UDStyleString) p[0]).text;

        LuaValue charSequenceLuaValue = (LuaValue) mImageUrlHashmap.get(charSequence);

        if (isImageSpan(charSequence) && charSequenceLuaValue == p[0] && ((UDStyleString) charSequenceLuaValue).imageSize != null) {
            imageSpan = new UrlImageSpan(((LuaViewManager) globals.getJavaUserdata()).context, charSequence.toString(), ((UDStyleString) charSequenceLuaValue).imageSize, this, mVerticalAlignment);
            text.append(charSequence);
            int imgLength = charSequence.toString().length();
            text.setSpan(imageSpan, text.length() - imgLength, text.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } else {
            text.append(charSequence);
        }

        if (charSequence != null)
            mImageUrlHashmap.put(charSequence, p[0]);

        changeText = true;

        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] calculateSize(LuaValue[] p) {
        int maxWidth = DimenUtil.dpiToPx((float) p[0].toDouble());
        if (maxWidth < 0) {
            if (MLSEngine.DEBUG) {
                IllegalArgumentException e = new IllegalArgumentException("max width must be more than 0");
                if (!Environment.hook(e, getGlobals())) {
                    throw e;
                }
            }
            if (lastSize == null) {
                lastSize = new UDSize(globals, new Size());
                lastSize.onJavaRef();
            }
            return varargsOf(lastSize);
        }
        if (layout != null && lastMaxWidth == maxWidth && !changeText && !changeSizePan) {
            return varargsOf(lastSize);
        }
        if (lastSize == null) {
            lastSize = new UDSize(globals, new Size());
            lastSize.onJavaRef();
        }
        lastMaxWidth = maxWidth;
        changeText = false;
        changeSizePan = false;
        if (sizeSpan != null) {
            caculatePaint.setTextSize(sizeSpan.getSize());
        }
        layout = new StaticLayout(text, caculatePaint, maxWidth, Layout.Alignment.ALIGN_NORMAL, 1, 0, true);
        int size = layout.getLineCount();
        float r = 0;
        float temp;
        for (int i = 0; i < size; i++) {
            if (r < (temp = layout.getLineWidth(i))) {
                r = temp;
            }
        }
        float dp = DimenUtil.pxToDpi(r);
        int w = (int) Math.ceil(dp);
        int h = (int) Math.ceil(DimenUtil.pxToDpi(layout.getHeight()));
        lastSize.setWidth(w);
        lastSize.setHeight(h);
        return varargsOf(lastSize);
    }

    /**
     * 下列setSpan系列方法，lua传的参数3是lenght，setspan接受的是end
     * 需要用start+lenght
     * 如：p[2].toInt() - 1 + p[1].toInt() - 1
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(String.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] setFontNameForRange(LuaValue[] p) {
        checkStartPosition(p[1]);
        try {
            int location = p[1].toInt() - 1;
            text.setSpan(new TypefaceSpan(p[0].toJavaString()), location, p[2].toInt() - 1 + location, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } catch (IndexOutOfBoundsException e) {
            LogUtil.e(e);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] setFontSizeForRange(LuaValue[] p) {
        checkStartPosition(p[1]);
        try {
            text.setSpan(new AbsoluteSizeSpan(DimenUtil.spToPx((float) p[0].toDouble())),
                    p[1].toInt() - 1,
                    p[2].toInt() + p[1].toInt() - 1,
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } catch (IndexOutOfBoundsException e) {
            LogUtil.e(e);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] setFontStyleForRange(LuaValue[] p) {
        checkStartPosition(p[1]);
        try {
            int start = p[1].toInt() - 1;
            int end = p[2].toInt() + start;
            SpannableStringBuilder before = null;
            if (start > 0) {
                before = (SpannableStringBuilder) text.subSequence(0, start);
                removeStyleForRange(before);
            }

            SpannableStringBuilder target = (SpannableStringBuilder) text.subSequence(start, end);
            removeStyleForRange(target);
            StyleSpan styleSpan = new StyleSpan(p[0].toInt());
            target.setSpan(styleSpan, 0, target.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

            initFontStyleForRangeList();
            mFontStyleForRangeList.add(styleSpan);

            SpannableStringBuilder after = null;
            if (end < text.length()) {
                after = (SpannableStringBuilder) text.subSequence(end, text.length());
                removeStyleForRange(after);
            }

            SpannableStringBuilder newtext = new SpannableStringBuilder();

            if (before != null) {
                newtext.append(before);

                Object[] spans = text.getSpans(0, start, Object.class);
                int min = start, max = 0;
                for (Object span : spans) {
                    int ss = text.getSpanStart(span);
                    int se = text.getSpanEnd(span);
                    if (se >= start) {
                        se = start;
                    }
                    min = Math.min(min, ss);
                    max = Math.max(max, se);
                    newtext.setSpan(cloneSpan(span), ss, se, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                }
            }

            newtext.append(target);

            if (after != null) {
                newtext.append(after);
                Object[] spans = text.getSpans(end, text.length(), Object.class);
                for (Object span : spans) {
                    int ss = text.getSpanStart(span);
                    int se = text.getSpanEnd(span);
                    if (ss <= end) {
                        ss = end;
                    }
                    newtext.setSpan(cloneSpan(span), ss, se, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                }
            }


            text = newtext;
        } catch (IndexOutOfBoundsException e) {
            LogUtil.e(e);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] setFontColorForRange(LuaValue[] p) {
        checkStartPosition(p[1]);
        try {
            text.setSpan(new ForegroundColorSpan(((UDColor) p[0]).getColor()), p[1].toInt() - 1, p[2].toInt() + p[1].toInt() - 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } catch (IndexOutOfBoundsException e) {
            LogUtil.e(e);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] setBackgroundColorForRange(LuaValue[] p) {
        checkStartPosition(p[1]);
        try {

            int start = p[1].toInt() - 1;
            int end = p[2].toInt() + p[1].toInt() - 1;

            SpannableStringBuilder current = (SpannableStringBuilder) text.subSequence(start, end);
            current.clearSpans();

            text.setSpan(new BackgroundColorSpan(((UDColor) p[0]).getColor()), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } catch (IndexOutOfBoundsException e) {
            LogUtil.e(e);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] setUnderlineForRange(LuaValue[] p) {
        checkStartPosition(p[1]);
        int underline = p[0].toInt();
        int start = p[1].toInt() - 1;
        int end = p[2].toInt() + p[1].toInt() - 1;
        if (underline > 0) {   //设置 UnderlineStyle.LINE
            try {
                text.setSpan(new UnderlineSpan(), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            } catch (IndexOutOfBoundsException e) {
                LogUtil.e(e);
            }
        } else {     // 设置  UnderlineStyle.NONE
            if (underlineSpan != null) {
                removeSpan(underlineSpan);
                underlineSpan = null;
                text.setSpan(new UnderlineSpan(), end, text.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                text.setSpan(new UnderlineSpan(), 0, start, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDSize.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] showAsImage(LuaValue[] p) {
        imageSize = ((UDSize) p[0]).getSize();
        imageSpan = new UrlImageSpan(((LuaViewManager) globals.getJavaUserdata()).context, text.toString(), imageSize, this, mVerticalAlignment);
        setSpan(imageSpan);
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(String.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] setText(LuaValue[] p) {
        text.clear();
        text.append(p[0].toJavaString());
        changeText = true;
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDStyleString.class))
    })
    public LuaValue[] imageAlign(LuaValue[] p) {
        mVerticalAlignment = p.length > 0 ? p[0].toInt() : StyleImageAlign.Default;
        return null;
    }
    //</editor-fold>
    //</editor-fold>


    @Override
    public void loadDrawableResult(ImageSpan imageSpan) {
        if (imageSpan != null) {
            setSpan(imageSpan);
            invalidaLabelText();
        }
    }

    private void invalidaLabelText() {
        if (mUDView != null) {
            mUDView.getView().invalidate();
            if (mUDView instanceof UDLabel)
                ((LuaLabel) mUDView.getView()).setText(((LuaLabel) (mUDView).getView()).getText());
        }
    }

    public CharSequence getText() {
        return text;
    }

    public int getColor() {
        if (colorSpan != null)
            return colorSpan.getForegroundColor();

        return -1;
    }

    public float getTextSize() {
        if (sizeSpan != null)
            return DimenUtil.pxToSp(sizeSpan.getSize());

        return -1;
    }

    @Override
    public String toString() {
        if (text != null) {
            return text.toString();
        }
        return "";
    }

    private void setSpan(Object o) {
        text.setSpan(o, 0, text.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
    }

    private void removeSpan(Object o) {
        text.removeSpan(o);
    }

    public StaticLayout getLayout() {
        return null;
    }

    private boolean isImageSpan(CharSequence charSequence) {
        return charSequence != null && (charSequence.toString().endsWith("jpg") || charSequence.toString().endsWith("png"));
    }

    UDView mUDView;

    public void setUDView(UDView udView) {
        mUDView = udView;
    }

    private void checkStartPosition(LuaValue luaValue) {
        if (luaValue.toInt() <= 0) {
            IllegalArgumentException e = new IllegalArgumentException("StyleString forRange(), start position cannot below equal zero");
            if (!Environment.hook(e, getGlobals())) {
                throw e;
            }
        }
    }

    private void initFontStyleForRangeList() {
        if (mFontStyleForRangeList == null)
            mFontStyleForRangeList = new ArrayList<>();
    }

    private void removeStyleForRange(SpannableStringBuilder text) {
        if (mFontStyleForRangeList != null && mFontStyleForRangeList.size() > 0) {
            for (StyleSpan sty : mFontStyleForRangeList) {
                text.removeSpan(sty);
            }
            mFontStyleForRangeList.clear();
        }
    }
}