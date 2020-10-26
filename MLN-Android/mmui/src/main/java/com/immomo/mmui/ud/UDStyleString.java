/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.graphics.Paint;
import android.os.Build;
import android.text.Layout;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.StaticLayout;
import android.text.TextPaint;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.BackgroundColorSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.text.style.TypefaceSpan;
import android.text.style.UnderlineSpan;

import com.immomo.mls.Environment;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.TypeFaceAdapter;
import com.immomo.mls.fun.constants.StyleImageAlign;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.fun.weight.span.ImageSpan;
import com.immomo.mls.fun.weight.span.UrlImageSpan;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.weight.WeightStyleSpan;
import com.immomo.mmui.ui.LuaLabel;

import org.luaj.vm2.Globals;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed
public class UDStyleString extends JavaUserdata implements UrlImageSpan.ILoadDrawableResult {
    public static final String LUA_CLASS_NAME = "StyleString";

    private SpannableStringBuilder text;
    private AbsoluteSizeSpan sizeSpan;
    private WeightStyleSpan weightSpan;
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
    private HashMap<CharSequence, UDStyleString> mImageUrlHashmap = new HashMap<>(); // 用于暂存同一个StyleString 对象，应对业务重复添加此对象
    private int mVerticalAlignment = StyleImageAlign.Default;//图片方向
    private List<StyleSpan> mFontStyleForRangeList;

    public UDStyleString(Globals g, Object jud) {
        super(g, jud);
        text = new SpannableStringBuilder(jud.toString());
        initPaint();
    }

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDStyleString(long L) {
        super(L, null);
        this.text = new SpannableStringBuilder();
        initPaint();
    }

    @CGenerate
    @LuaApiUsed
    protected UDStyleString(long L, String text) {
        super(L, null);
        this.text = new SpannableStringBuilder(text);
        initPaint();
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
    @LuaApiUsed
    public void setFontName(String name) {
        if (typefaceSpan != null) {
            removeSpan(typefaceSpan);
        }
        TypeFaceAdapter a = MLSAdapterContainer.getTypeFaceAdapter();
        if (a != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            typefaceSpan = new TypefaceSpan(a.create(name));
            setSpan(typefaceSpan);
        }
    }

    @LuaApiUsed
    public String getFontName() {
        return typefaceSpan != null ? typefaceSpan.getFamily() : null;
    }

    @LuaApiUsed
    public void setFontSize(float s) {
        if (sizeSpan != null) {
            removeSpan(sizeSpan);
        }
        sizeSpan = new AbsoluteSizeSpan(DimenUtil.spToPx(s));
        setSpan(sizeSpan);
        changeSizePan = true;
    }

    @LuaApiUsed
    public float getFontSize() {
        return sizeSpan == null ? 0 : DimenUtil.pxToSp(sizeSpan.getSize());
    }

    @LuaApiUsed
    public void setFontWeight(int weight) {
        if (weightSpan != null) {
            removeSpan(weightSpan);
        }
        this.weight = weight;
        weightSpan = new WeightStyleSpan(weight);
        setSpan(weightSpan);
    }

    @LuaApiUsed
    public int getFontWeight() {
        return this.weight;
    }

    @LuaApiUsed
    public void setFontStyle(int s) {
        if (styleSpan != null) {
            removeSpan(styleSpan);
        }
        removeStyleForRange(text);

        styleSpan = new StyleSpan(s);
        setSpan(styleSpan);
    }

    @LuaApiUsed
    public int getFontStyle() {
        return styleSpan != null ? styleSpan.getStyle() : 0;
    }

    @LuaApiUsed
    public void setFontColor(UDColor color) {
        if (colorSpan != null) {
            removeSpan(colorSpan);
        }
        colorSpan = new ForegroundColorSpan(color.getColor());
        setSpan(colorSpan);
    }

    @LuaApiUsed
    public UDColor getFontColor() {
        if (colorSpan == null)
            return null;
        return new UDColor(globals, colorSpan.getForegroundColor());
    }

    @LuaApiUsed
    public void setBackgroundColor(UDColor color) {
        if (backgroundColorSpan != null) {
            removeSpan(backgroundColorSpan);
        }
        backgroundColorSpan = new BackgroundColorSpan(color.getColor());
        setSpan(backgroundColorSpan);
    }

    @LuaApiUsed
    public UDColor getBackgroundColor() {
        return backgroundColorSpan != null
                ? new UDColor(globals, backgroundColorSpan.getBackgroundColor())
                : null;
    }

    @LuaApiUsed
    public void setUnderline(int i) {
        if (i > 0 && underlineSpan == null) {
            underlineSpan = new UnderlineSpan();
            setSpan(underlineSpan);
        } else if (i <= 0 && underlineSpan != null) {
            removeSpan(underlineSpan);
            underlineSpan = null;
        }
    }

    @LuaApiUsed
    public int getUnderline() {
        return underlineSpan != null ? 1 : 0;
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public void append(UDStyleString styleString) {
        CharSequence charSequence = styleString.text;

        UDStyleString charSequenceLuaValue = mImageUrlHashmap.get(charSequence);

        if (isImageSpan(charSequence) && charSequenceLuaValue == styleString && ((UDStyleString) charSequenceLuaValue).imageSize != null) {
            imageSpan = new UrlImageSpan(((LuaViewManager) globals.getJavaUserdata()).context, charSequence.toString(), ((UDStyleString) charSequenceLuaValue).imageSize, this, mVerticalAlignment);
            text.append(charSequence);
            int imgLength = charSequence.toString().length();
            text.setSpan(imageSpan, text.length() - imgLength, text.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } else {
            text.append(charSequence);
        }

        if (charSequence != null)
            mImageUrlHashmap.put(charSequence, styleString);

        changeText = true;
    }

    @LuaApiUsed
    public UDSize calculateSize(float mw) {
        int maxWidth = DimenUtil.dpiToPx(mw);
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
            return lastSize;
        }
        if (layout != null && lastMaxWidth == maxWidth && !changeText && !changeSizePan) {
            return lastSize;
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
        return lastSize;
    }

    /**
     * 下列setSpan系列方法，lua传的参数3是lenght，setspan接受的是end
     * 需要用start+lenght
     * 如：p[2].toInt() - 1 + p[1].toInt() - 1
     */
    @LuaApiUsed
    public void setFontNameForRange(String name, int s, int end) {
        checkStartPosition(s);
        try {
            int location = s - 1;
            text.setSpan(new TypefaceSpan(name), location, end - 1 + location, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } catch (IndexOutOfBoundsException e) {
            LogUtil.e(e);
        }
    }

    @LuaApiUsed
    public void setFontSizeForRange(float s, int start, int end) {
        checkStartPosition(start);
        try {
            text.setSpan(new AbsoluteSizeSpan(DimenUtil.spToPx(s)),
                    start - 1,
                    end + start - 1,
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } catch (IndexOutOfBoundsException e) {
            LogUtil.e(e);
        }
    }

    @LuaApiUsed
    public void setFontStyleForRange(int style, int start, int end) {
        checkStartPosition(start);
        try {
            start--;
            end = end + start;
            SpannableStringBuilder before = null;
            if (start > 0) {
                before = (SpannableStringBuilder) text.subSequence(0, start);
                removeStyleForRange(before);
            }

            SpannableStringBuilder target = (SpannableStringBuilder) text.subSequence(start, end);
            removeStyleForRange(target);
            StyleSpan styleSpan = new StyleSpan(style);
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
    }

    @LuaApiUsed
    public void setFontColorForRange(UDColor color, int start, int end) {
        checkStartPosition(start);
        try {
            text.setSpan(new ForegroundColorSpan(color.getColor()), start - 1, end + start - 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } catch (IndexOutOfBoundsException e) {
            LogUtil.e(e);
        }
    }

    @LuaApiUsed
    public void setBackgroundColorForRange(UDColor color, int start, int end) {
        checkStartPosition(start);
        try {
            start--;
            end = end + start - 1;

            SpannableStringBuilder current = (SpannableStringBuilder) text.subSequence(start, end);
            current.clearSpans();

            text.setSpan(new BackgroundColorSpan(color.getColor()), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } catch (IndexOutOfBoundsException e) {
            LogUtil.e(e);
        }
    }

    @LuaApiUsed
    public void setUnderlineForRange(int underline, int start, int end) {
        checkStartPosition(start);
        start--;
        end = end + start - 1;
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
    }

    @LuaApiUsed
    public void showAsImage(UDSize size) {
        imageSize = size.getSize();
        imageSpan = new UrlImageSpan(((LuaViewManager) globals.getJavaUserdata()).context, text.toString(), imageSize, this, mVerticalAlignment);
        setSpan(imageSpan);
    }

    @LuaApiUsed
    public void setText(String text) {
        this.text.clear();
        this.text.append(text);
        changeText = true;
    }

    @LuaApiUsed
    public void imageAlign() {
        mVerticalAlignment = StyleImageAlign.Default;
    }

    @LuaApiUsed
    public void imageAlign(int a) {
        mVerticalAlignment = a;
    }
    //</editor-fold>
    //</editor-fold>


    @Override
    public void loadDrawableResult(ImageSpan imageSpan) {
        if (imageSpan != null){
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
    public void setUDView(UDView udView){
        mUDView = udView;
    }

    private void checkStartPosition(int p) {
        if (p <= 0) {
            IllegalArgumentException e = new IllegalArgumentException("StyleString xxxforRange方法的开始位置必须大于0");
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