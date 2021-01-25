/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.content.Context;
import android.text.Editable;
import android.text.InputFilter;
import android.text.InputType;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.HideReturnsTransformationMethod;
import android.text.method.PasswordTransformationMethod;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.constants.EditTextViewInputMode;
import com.immomo.mls.fun.ud.view.IShowKeyboard;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ILView;
import com.immomo.mmui.ui.LuaEditText;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import static android.view.inputmethod.EditorInfo.IME_ACTION_UNSPECIFIED;


/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed
public class UDEditText<L extends EditText & ILView> extends UDLabel<L> implements TextWatcher, TextView.OnEditorActionListener, IShowKeyboard {
    public static final String LUA_CLASS_NAME = "EditTextView";

    private static final String TAG = UDEditText.class.getSimpleName();

    private boolean passwordMode = false;
    private boolean singleLineMode = false;
    private int inputType = InputType.TYPE_CLASS_TEXT;

    private LuaFunction beginChangingCallback;
    private LuaFunction changingCallback;
    private LuaFunction endChangedCallback;
    private LuaFunction returnCallback;
    private LuaFunction mSetShouldChangeFunction;

    private boolean textWatcherAdded = false;
    private boolean editorActionSetted = false;

    private int maxlength = 0;
    private int maxBytes = 0;
    private boolean hasMaxBytesLisenter = false;
    private int mTextAlign;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDEditText(long L) {
        super(L);
    }

    @Override
    protected L newView(LuaValue[] init) {
        return (L) new LuaEditText(getContext(), this);
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

    @Override
    protected void setText(String text) {
        try {
            super.setText(text);
            getView().setSelection(text.length());
        } catch (Exception e) {
            if (MLSEngine.DEBUG)
                e.printStackTrace();
        }
    }

    @LuaApiUsed
    public void setPlaceholder(String value) {
        if (singleLineMode) {
            value = value.replace("\n", "");
        }

        getView().setHint(value);
    }

    @LuaApiUsed
    public String getPlaceholder() {
        return getView().getHint().toString();
    }

    @LuaApiUsed
    public void setPlaceholderColor(UDColor color) {
        getView().setHintTextColor(color.getColor());
    }

    @LuaApiUsed
    public UDColor getPlaceholderColor() {
        UDColor udColor = new UDColor(getGlobals(), getView().getHintTextColors().getDefaultColor());
        return udColor;
    }

    @LuaApiUsed
    public void setInputMode(int value) {
        inputType = value;
        if (passwordMode) {
            value = value | InputType.TYPE_TEXT_VARIATION_PASSWORD;
        }

        if (value == EditTextViewInputMode.Number) {//Number系统自动为单行，这里同步为lua的singleLine模式
            getView().setInputType(value);
            singleLineMode = false;
            setSingleLine(true);
        } else {
            if (!singleLineMode) {//Normal模式，根据lua的singleLine，设置flag
                getView().setInputType(value | EditorInfo.TYPE_TEXT_FLAG_MULTI_LINE);
            } else {
                getView().setInputType(value & ~EditorInfo.TYPE_TEXT_FLAG_MULTI_LINE);
            }
        }
    }

    @LuaApiUsed
    public int getInputMode() {
        return inputType;
    }

    /**
     * 设置单行横向滑动模式，对齐方式切换为居中
     */
    @LuaApiUsed
    public void setSingleLine(boolean isSingleLine) {
        if (singleLineMode != isSingleLine) {
            singleLineMode = isSingleLine;
            getView().setSingleLine(isSingleLine);
            if (isSingleLine) {
                getView().setGravity(Gravity.CENTER_VERTICAL | mTextAlign);
                CharSequence hint = getView().getHint();
                if (hint != null)
                    setPlaceholder(hint.toString());
            } else {
                getView().setGravity(Gravity.TOP | mTextAlign);
            }
            resetPassWordMode(passwordMode);
        }

        Editable editor = getView().getText();
        if (editor != null && !TextUtils.isEmpty(editor.toString()) && singleLineMode) {
            String text = editor.toString();
            text = text.replace("\n", " ");
            setText(text);
        }
    }

    @LuaApiUsed
    public boolean isSingleLine() {
        return singleLineMode;
    }

    @LuaApiUsed
    public void setTextAlign(int a) {
        mTextAlign = a;
        getView().setGravity((singleLineMode ? Gravity.CENTER_VERTICAL : Gravity.TOP) | mTextAlign);
    }

    @LuaApiUsed
    public int getTextAlign() {
        return getView().getGravity();
    }

    @LuaApiUsed
    public void setPasswordMode(boolean enable) {
        int sectionStart = getView().getSelectionStart();
        passwordMode = enable;
        resetPassWordMode(passwordMode);
        setSelectionPosition(sectionStart);
    }

    @LuaApiUsed
    public boolean isPasswordMode() {
        return passwordMode;
    }

    @LuaApiUsed
    public void setMaxLength(int length) {
        this.maxlength = length;
        setLengthFilter(length);
    }

    @LuaApiUsed
    public int getMaxLength() {
        return maxlength;
    }

    private boolean setLengthFilter(int length) {
        InputFilter[] filters = getView().getFilters();

        final int count = filters.length;
        for (int i = 0; i < count; i++) {
            if (filters[i] instanceof InputFilter.LengthFilter) {
                filters[i] = new InputFilter.LengthFilter(length);
                getView().setFilters(filters);
                return true;
            }
        }
        final InputFilter[] newFilters = new InputFilter[filters.length + 1];
        System.arraycopy(filters, 0, newFilters, 0, count);
        newFilters[count] = new InputFilter.LengthFilter(length);

        getView().setFilters(newFilters);
        return false;
    }

    @LuaApiUsed
    public void setMaxBytes(int max) {
        this.maxBytes = max;

        setLengthFilter((this.maxBytes / 2));
        if (!hasMaxBytesLisenter) {
            hasMaxBytesLisenter = true;
            getView().addTextChangedListener(new LuaLimitTextWatcher());
        }
    }

    @LuaApiUsed
    public int getMaxBytes() {
        return maxBytes;
    }

    @LuaApiUsed
    public void setReturnMode(int r) {
        getView().setImeOptions(r);
        if (singleLineMode) {//为了和IOS同步，实时更新效果
            getView().setSingleLine(false);
            getView().setSingleLine(singleLineMode);
            resetPassWordMode(passwordMode);
        }
    }

    @LuaApiUsed
    public int returnMode() {
        return getView().getImeOptions();
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public void setBeginChangingCallback(LuaFunction fun) {
        if (beginChangingCallback != null)
            beginChangingCallback.destroy();
        beginChangingCallback = fun;
        addTextWatcher();
    }

    @LuaApiUsed
    public void setDidChangingCallback(LuaFunction callback) {
        if (changingCallback != null)
            changingCallback.destroy();
        changingCallback = callback;
        addTextWatcher();
    }

    @LuaApiUsed
    public void setEndChangedCallback(LuaFunction callback) {
        if (endChangedCallback != null)
            endChangedCallback.destroy();
        endChangedCallback = callback;
        addTextWatcher();
    }

    @LuaApiUsed
    public void setReturnCallback(LuaFunction callback) {
        if (returnCallback != null)
            returnCallback.destroy();
        returnCallback = callback;
        if (returnCallback != null && !editorActionSetted) {
            editorActionSetted = true;
        }
    }

    @LuaApiUsed
    public void setCursorColor(UDColor color) {
        if (getView() instanceof LuaEditText) {
            ((LuaEditText) getView()).setCursorColor(color.getColor());
        }
    }

    @LuaApiUsed
    public void setCanEdit(boolean enable) {
        getView().setEnabled(enable);
    }

    @LuaApiUsed
    public void setShouldChangeCallback(LuaFunction p) {
        if (mSetShouldChangeFunction != null)
            mSetShouldChangeFunction.destroy();
        mSetShouldChangeFunction = p;

        InputFilter[] filters = getView().getFilters();
        final int count = filters.length;
        for (int i = 0; i < count; i++) {
            if (filters[i] instanceof BlockingFilter) {
                filters[i] = new BlockingFilter(mSetShouldChangeFunction, getView());
                getView().setFilters(filters);
            }
        }
        final InputFilter[] newFilters = new InputFilter[filters.length + 1];
        System.arraycopy(filters, 0, newFilters, 0, count);
        newFilters[count] = new BlockingFilter(mSetShouldChangeFunction, getView());

        getView().setFilters(newFilters);
    }

    @CGenerate(alias = "showKeyboard")
    @LuaApiUsed
    public void nShowKeyboard() {
        InputMethodManager im = ((InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE));
        if (!getView().isFocused()) {
            getView().requestFocus();
        }
        if (im != null) {
            im.showSoftInput(getView(),
                    InputMethodManager.SHOW_IMPLICIT);
        }
        getView().setCursorVisible(true);
        callBeforeTextChanged();
    }

    @LuaApiUsed
    public void dismissKeyboard() {
        InputMethodManager im = ((InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE));
        View curFocusView = getView().isFocused() ? getView() : null;
        if (curFocusView != null && im != null) {
            im.hideSoftInputFromWindow(curFocusView.getWindowToken(),
                    InputMethodManager.HIDE_NOT_ALWAYS);
            getView().setCursorVisible(false);//收起键盘时，移除光标。再次触摸时，显示光标
        }
    }

    @Override
    protected void setLines(int i) {
        super.setLines(i);
        if (i == 1) {
            getView().setSingleLine();
        } else {
            getView().setSingleLine(false);
        }
    }

    @Override
    public LuaValue[] requestFocus(LuaValue[] p) {
        LuaValue[] result = super.requestFocus(p);
        nShowKeyboard();
        return result;
    }

    @Override
    public LuaValue[] cancelFocus(LuaValue[] p) {
        LuaValue[] result = super.cancelFocus(p);
        dismissKeyboard();
        return result;
    }

    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="TextWatcher">
    public void callBeforeTextChanged() {
        if (beginChangingCallback != null)
            beginChangingCallback.fastInvoke();
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
//        callBeforeTextChanged();
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        if (changingCallback != null)
            changingCallback.invoke(varargsOf(LuaString.valueOf(s.toString()), LuaNumber.valueOf(start + 1), LuaNumber.valueOf(count)));
    }

    @Override
    public void afterTextChanged(Editable s) {
        if (endChangedCallback != null) {
            endChangedCallback.fastInvoke(s.toString());
        }
    }
    //</editor-fold>

    private void addTextWatcher() {
        if (!textWatcherAdded) {
            textWatcherAdded = true;
            getView().addTextChangedListener(this);
        }
    }

    //<editor-fold desc="OnEditorActionListener">
    @Override
    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
        //和IOS同步，1.多行模式下，回调+换行。 2.单行模式下，回调
        //为了保证以上效果，以下是注意点：
        //分发ACTION_DOWN时，return false, 不消费事件。ACTION_UP不会分发。不用担心调用两次。
        //此事件ACTION_DOWN，也会在松手时调用
        //有returnMode时，需要return true,消费事件。防止继续分发ACTION_DOWN
        if (event != null && event.getAction() == KeyEvent.ACTION_DOWN) {
            if (returnCallback != null) {
                returnCallback.fastInvoke();
            }
        } else if (actionId != IME_ACTION_UNSPECIFIED || event == null) {//有returnMode时，actionId为：非IME_ACTION_UNSPECIFIED
            if (returnCallback != null) {
                returnCallback.fastInvoke();
            }
            return true;
        }
        return false;
    }
    //</editor-fold>

    private class LuaLimitTextWatcher implements TextWatcher {
        private CharSequence temp;
        private int editStart;
        private int editEnd;

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            temp = s;
        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
        }

        @Override
        public void afterTextChanged(Editable s) {
            if (maxBytes > 0) {
                EditText text = getView();
                editStart = text.getSelectionStart();
                editEnd = text.getSelectionEnd();
                if (countBytes(temp.toString()) > maxBytes) {

                    try {
                        s.delete(editStart - 1, editEnd);
                        text.setText(s);
                        text.setSelection(text.getText().length());
                    } catch (Exception e) {
                        if (MLSEngine.DEBUG)
                            e.printStackTrace();
                    }

                }
            }
        }
    }

    /**
     * 计算字符串所占Byte，emoji占4，中文占2，其他为1
     */
    private static int countBytes(String src) {
        if (TextUtils.isEmpty(src)) {
            return 0;
        }
        int chCount = 0;
        int emojiCount = 0;
        int otherCount = 0;
        int cpCount = src.codePointCount(0, src.length());
        int firCodeIndex = src.offsetByCodePoints(0, 0);
        int lstCodeIndex = src.offsetByCodePoints(0, cpCount - 1);
        for (int i = firCodeIndex; i <= lstCodeIndex; ) {
            int codepoint = src.codePointAt(i);
            i += ((Character.isSupplementaryCodePoint(codepoint)) ? 2 : 1);

            if (isChineseCharacter(codepoint)) {
                chCount++;
            } else if (isEmojiCharacter(codepoint)) {
                emojiCount++;
            } else {
                otherCount++;
            }
        }
        return emojiCount * 4 + chCount * 2 + otherCount;
    }

    @Override
    public boolean showKeyboard() {
        return true;
    }

    //切换单行/多行，重置密码模式。密码模式仅单行生效
    private void resetPassWordMode(boolean isPassWord) {
        if (isPassWord) {
            if (singleLineMode) {
                getView().setTransformationMethod(PasswordTransformationMethod.getInstance());
            } else {
                getView().setTransformationMethod(HideReturnsTransformationMethod.getInstance());
                ErrorUtils.debugAlert("Multi-line mode does not support password mode and should be set to single-line mode", getGlobals());
            }
        } else {
            getView().setTransformationMethod(HideReturnsTransformationMethod.getInstance());
        }
    }

    /**
     * 是否为中文字符，包括标点
     */
    private static boolean isChineseCharacter(int ch) {
        Character.UnicodeBlock ub = Character.UnicodeBlock.of(ch);
        return ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS
                || ub == Character.UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS
                || ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A
                || ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B
                || ub == Character.UnicodeBlock.CJK_SYMBOLS_AND_PUNCTUATION
                || ub == Character.UnicodeBlock.HALFWIDTH_AND_FULLWIDTH_FORMS
                || ub == Character.UnicodeBlock.GENERAL_PUNCTUATION;
    }

    private static boolean isEmojiCharacter(int codePoint) {
        return (codePoint >= 0x2600 && codePoint <= 0x27BF) // 杂项符号与符号字体
                || codePoint == 0x303D
                || codePoint == 0x2049
                || codePoint == 0x203C
                || (codePoint >= 0x2000 && codePoint <= 0x200F)//
                || (codePoint >= 0x2028 && codePoint <= 0x202F)//
                || codePoint == 0x205F //
                || (codePoint >= 0x2065 && codePoint <= 0x206F)//
                /* 标点符号占用区域 */
                || (codePoint >= 0x2100 && codePoint <= 0x214F)// 字母符号
                || (codePoint >= 0x2300 && codePoint <= 0x23FF)// 各种技术符号
                || (codePoint >= 0x2B00 && codePoint <= 0x2BFF)// 箭头A
                || (codePoint >= 0x2900 && codePoint <= 0x297F)// 箭头B
                || (codePoint >= 0x3200 && codePoint <= 0x32FF)// 中文符号
                || (codePoint >= 0xD800 && codePoint <= 0xDFFF)// 高低位替代符保留区域
                || (codePoint >= 0xE000 && codePoint <= 0xF8FF)// 私有保留区域
                || (codePoint >= 0xFE00 && codePoint <= 0xFE0F)// 变异选择器;
                || codePoint >= 0x10000; // Plane在第二平面以上的，char都不可以存，全部都转
    }

    private void setSelectionPosition(int sectionPosition) {
        Editable editable = getView().getText();
        if (editable != null) {
            if (sectionPosition < 0 || sectionPosition > editable.length())
                return;
            getView().setSelection(sectionPosition);
        }
    }

    public static class BlockingFilter implements InputFilter {

        LuaFunction function;
        EditText view;

        public BlockingFilter(LuaFunction function, EditText editText) {
            this.function = function;
            this.view = editText;
        }

        /**
         * @param source 输入的文字
         * @param start  输入-0，删除-0
         * @param end    输入-文字的长度，删除-0
         * @param dest   原先显示的内容
         * @param dstart 输入-原光标位置，删除-光标删除结束位置
         * @param dend   输入-原光标位置，删除-光标删除开始位置
         */
        @Override
        public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int dstart, int dend) {
            if (MLSEngine.DEBUG)
                LogUtil.d(TAG, "filter: " + "source  ==" + source + "  start=====" + start + "   end======" + end
                        + "   dest====" + dest + "  dstart===" + dstart + "  dend==" + dend);

            Editable editable = view.getText();
            String beforeValue = "";
            if (editable != null)
                beforeValue = editable.toString();

            // 和ios保持同步，当删除时，返回空串
            if (start == 0 && end == 0)
                source = "";

            if (function != null) {
                LuaValue[] resultValue = function.invoke(varargsOf(LuaString.valueOf(beforeValue), LuaString.valueOf(source.toString()),
                        LuaNumber.valueOf(dstart + 1), LuaNumber.valueOf(source.length())));

                if (resultValue.length >= 1) {
                    boolean result = resultValue[0].toBoolean();
                    if (!result)
                        return ""; //标识不让输入此内容
                }
            }

            return null;
        }
    }
}