/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

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
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ui.LuaEditText;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.ErrorUtils;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import static android.view.inputmethod.EditorInfo.IME_ACTION_UNSPECIFIED;


/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed
public class UDEditText<L extends EditText> extends UDLabel<L> implements TextWatcher, TextView.OnEditorActionListener, IShowKeyboard {
    public static final String LUA_CLASS_NAME = "EditTextView";

    public static final String[] methods = {
            "placeholder",
            "placeholderColor",
            "inputMode",
            "singleLine",
            "passwordMode",
            "maxLength",
            "maxBytes",
            "returnMode",
            "setBeginChangingCallback",
            "setDidChangingCallback",
            "setEndChangedCallback",
            "setReturnCallback",
            "setCursorColor",
            "setCanEdit",
            "showKeyboard",
            "dismissKeyboard",
            "setShouldChangeCallback"
    };
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

    @LuaApiUsed
    protected UDEditText(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected L newView(LuaValue[] init) {
        return (L) new LuaEditText(getContext(), this);
    }

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
    public LuaValue[] placeholder(LuaValue[] placeholder) {
        if (placeholder != null && placeholder.length >= 1) {

            String value = placeholder[0].toJavaString();
            if (singleLineMode) {
                value = value.replace("\n", "");
            }

            if (placeholder[0].isNil())
                value = "";

            getView().setHint(value);
            return null;
        }
        return varargsOf(LuaString.valueOf(getView().getHint().toString()));
    }

    @LuaApiUsed
    public LuaValue[] placeholderColor(LuaValue[] color) {
        if (color != null && color.length >= 1) {
            getView().setHintTextColor(((UDColor) color[0]).getColor());
            return null;
        }
        UDColor udColor = new UDColor(getGlobals(), getView().getHintTextColors().getDefaultColor());
        return varargsOf(udColor);
    }

    @LuaApiUsed
    public LuaValue[] inputMode(LuaValue[] i) {
        if (i != null && i.length >= 1) {
            int value = i[0].toInt();
            inputType = value;
            if (passwordMode) {
                value = value | InputType.TYPE_TEXT_VARIATION_PASSWORD;
            }

            if (value == EditTextViewInputMode.Number) {//Number系统自动为单行，这里同步为lua的singleLine模式
                getView().setInputType(value);
                singleLineMode = false;
                singleLine(LuaBoolean.rBoolean(true));
            } else {
                if (!singleLineMode) {//Normal模式，根据lua的singleLine，设置flag
                    getView().setInputType(value | EditorInfo.TYPE_TEXT_FLAG_MULTI_LINE);
                } else {
                    getView().setInputType(value & ~EditorInfo.TYPE_TEXT_FLAG_MULTI_LINE);
                }
            }
            return null;
        }
        return varargsOf(LuaNumber.valueOf(inputType));
    }

    /**
     * 设置单行横向滑动模式，对齐方式切换为居中
     */
    @LuaApiUsed
    public LuaValue[] singleLine(LuaValue[] singleLine) {
        if (singleLine != null && singleLine.length >= 1) {
            boolean isSingleLine = singleLine[0].toBoolean();
            if (singleLineMode != isSingleLine) {
                singleLineMode = isSingleLine;
                getView().setSingleLine(isSingleLine);
                if (isSingleLine) {
                    getView().setGravity(
                            Gravity.CENTER_VERTICAL | mTextAlign);
                    if (getView().getHint() != null)
                        placeholder(varargsOf(LuaString.valueOf(getView().getHint().toString())));

                } else {
                    getView().setGravity(
                            Gravity.TOP | mTextAlign);
                }
                resetPassWordMode(passwordMode);
            }

            Editable editor = getView().getText();
            if (editor != null && !TextUtils.isEmpty(editor.toString()) && singleLineMode) {
                String text = editor.toString();
                text = text.replace("\n", " ");
                setText(text);
            }
            return null;
        }
        return varargsOf(LuaBoolean.valueOf(singleLineMode));
    }

    @LuaApiUsed
    public LuaValue[] textAlign(LuaValue[] var) {
        if (var.length == 1) {
            mTextAlign = var[0].toInt();
            getView().setGravity((singleLineMode ? Gravity.CENTER_VERTICAL : Gravity.TOP) | mTextAlign);
            return null;
        }
        return varargsOf(LuaNumber.valueOf(getView().getGravity()));
    }

    @LuaApiUsed
    public LuaValue[] passwordMode(LuaValue[] enable) {
        if (enable != null && enable.length >= 1) {
            int sectionStart = getView().getSelectionStart();
            passwordMode = enable[0].toBoolean();
            resetPassWordMode(passwordMode);
            setSelectionPosition(sectionStart);
            return null;
        }
        return varargsOf(LuaBoolean.valueOf(passwordMode));
    }

    @LuaApiUsed
    public LuaValue[] maxLength(LuaValue[] lengths) {
        if (lengths != null && lengths.length >= 1) {
            int length = lengths[0].toInt();
            this.maxlength = length;

            if (setLengthFilter(length))
                return null;

            return null;
        }

        return varargsOf(LuaNumber.valueOf(maxlength));
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
    public LuaValue[] maxBytes(LuaValue[] lengths) {
        if (lengths != null && lengths.length >= 1) {
            this.maxBytes = lengths[0].toInt();

            setLengthFilter((this.maxBytes / 2));
            if (!hasMaxBytesLisenter) {
                hasMaxBytesLisenter = true;
                getView().addTextChangedListener(new LuaLimitTextWatcher());
            }
            return null;
        }

        return varargsOf(LuaNumber.valueOf(maxBytes));
    }

    @LuaApiUsed
    public LuaValue[] returnMode(LuaValue[] mode) {
        if (mode != null && mode.length >= 1) {
            getView().setImeOptions(mode[0].toInt());
            if (singleLineMode) {//为了和IOS同步，实时更新效果
                getView().setSingleLine(false);
                getView().setSingleLine(singleLineMode);
            }
            return null;
        }
        return varargsOf(LuaNumber.valueOf(getView().getImeOptions()));
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public LuaValue[] setBeginChangingCallback(LuaValue[] fun) {
        if (beginChangingCallback != null)
            beginChangingCallback.destroy();
        beginChangingCallback = fun[0].toLuaFunction();
        addTextWatcher();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setDidChangingCallback(LuaValue[] callback) {
        if (changingCallback != null)
            changingCallback.destroy();
        changingCallback = callback[0].toLuaFunction();
        addTextWatcher();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setEndChangedCallback(LuaValue[] callback) {
        if (endChangedCallback != null)
            endChangedCallback.destroy();
        endChangedCallback = callback[0].toLuaFunction();
        addTextWatcher();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setReturnCallback(LuaValue[] callback) {
        if (returnCallback != null)
            returnCallback.destroy();
        returnCallback = callback[0].toLuaFunction();
        if (returnCallback != null && !editorActionSetted) {
            editorActionSetted = true;
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setCursorColor(LuaValue[] color) {
        if (color != null && color.length >= 1) {
            if (getView() instanceof LuaEditText) {
                ((LuaEditText) getView()).setCursorColor(((UDColor) color[0]).getColor());
            }
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setCanEdit(LuaValue[] enable) {
        if (enable != null && enable.length >= 1) {
            getView().setEnabled(enable[0].toBoolean());
        }
        return null;
    }

    @Override
    public LuaValue[] requestFocus(LuaValue[] p) {
        LuaValue[] result = super.requestFocus(p);
        showKeyboard(null);
        return result;
    }

    @Override
    public LuaValue[] cancelFocus(LuaValue[] p) {
        LuaValue[] result = super.cancelFocus(p);
        dismissKeyboard(null);
        return result;
    }

    @LuaApiUsed
    public LuaValue[] setShouldChangeCallback(LuaValue[] p) {
        if (mSetShouldChangeFunction != null)
            mSetShouldChangeFunction.destroy();
        mSetShouldChangeFunction = p[0].toLuaFunction();

        InputFilter[] filters = getView().getFilters();
        final int count = filters.length;
        for (int i = 0; i < count; i++) {
            if (filters[i] instanceof BlockingFilter) {
                filters[i] = new BlockingFilter(mSetShouldChangeFunction, getView());
                getView().setFilters(filters);
                return null;
            }
        }
        final InputFilter[] newFilters = new InputFilter[filters.length + 1];
        System.arraycopy(filters, 0, newFilters, 0, count);
        newFilters[count] = new BlockingFilter(mSetShouldChangeFunction, getView());

        getView().setFilters(newFilters);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] showKeyboard(LuaValue[] v) {
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
        return null;
    }

    @LuaApiUsed
    public LuaValue[] dismissKeyboard(LuaValue[] v) {
        InputMethodManager im = ((InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE));
        View curFocusView = getView().isFocused() ? getView() : null;
        if (curFocusView != null && im != null) {
            im.hideSoftInputFromWindow(curFocusView.getWindowToken(),
                    InputMethodManager.HIDE_NOT_ALWAYS);
            getView().setCursorVisible(false);//收起键盘时，移除光标。再次触摸时，显示光标
        }

        return null;
    }

    protected void setLines(int i) {
        if (i == 1) {
            getView().setSingleLine();
        } else {
            getView().setSingleLine(false);
        }
    }

    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="TextWatcher">
    public void callBeforeTextChanged() {
        if (beginChangingCallback != null)
            beginChangingCallback.invoke(null);
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
            endChangedCallback.invoke(varargsOf(LuaString.valueOf(s.toString())));
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
                returnCallback.invoke(null);
            }
        } else if (actionId != IME_ACTION_UNSPECIFIED || event == null) {//有returnMode时，actionId为：非IME_ACTION_UNSPECIFIED
            if (returnCallback != null) {
                returnCallback.invoke(null);
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