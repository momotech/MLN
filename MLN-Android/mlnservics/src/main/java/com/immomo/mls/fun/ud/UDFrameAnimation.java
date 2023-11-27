package com.immomo.mls.fun.ud;

import android.animation.Animator;
import android.animation.ValueAnimator;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.annotation.MLN;
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ud.anim.RepeatType;
import com.immomo.mls.fun.ud.anim.Utils;
import com.immomo.mls.fun.ud.anim.ValueType;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.util.ColorUtils;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.LVCallback;

import org.luaj.vm2.Globals;

/**
 * Created by XiongFangyu on 2018/8/10.
 */
@MLN(type = MLN.Type.Normal)
@LuaClass(gcByLua = false)
public class UDFrameAnimation extends ValueAnimator implements ValueAnimator.AnimatorUpdateListener, Animator.AnimatorListener {
    public static final String LUA_CLASS_NAME = "FrameAnimation";

    private static final int MASK_TX = 0;
    private static final int MASK_TY = 1;
    private static final int MASK_R = 2;
    private static final int MASK_SX = 3;
    private static final int MASK_SY = 4;
    private static final int MASK_A = 5;
    private static final int MASK_Color = 6;

    private int current_type_value = -1;
    private boolean isCancel = false;
    private Globals globals;

    private byte animType;
    private final float[] floatValues = new float[(MASK_Color + 1) * 2];
    private float[] tempFloatValues = null;
    private UDView targetUDView;
    private View target;

    private LVCallback endCallback;

    public UDFrameAnimation(Globals globals) {
        this.globals = globals;
        addUpdateListener(this);
        setInterpolator(Utils.linear);
        addListener(this);
        setFloatValues(0, 1);
    }

    public void __onLuaGc() {
        if (!globals.isDestroyed()) {
            return;
        }
        if (targetUDView != null)
            targetUDView.removeFrameAnimation(this);
        targetUDView = null;
        target = null;
        if (endCallback != null)
            endCallback.destroy();
        endCallback = null;

        cancel();
    }

    //<editor-fold desc="API">
    @LuaBridge
    public void setTranslateXTo(float fto) {
        addType(MASK_TX);
        int to = DimenUtil.dpiToPx(fto);
        if (isCurrentType(to)) {
            to = ValueType.CURRENT;
        }
        addFloatValue(ValueType.CURRENT, to, MASK_TX);
    }

    @LuaBridge
    public void setTranslateYTo(float fto) {
        addType(MASK_TY);
        int to = DimenUtil.dpiToPx(fto);
        if (isCurrentType(to)) {
            to = ValueType.CURRENT;
        }
        addFloatValue(ValueType.CURRENT, to, MASK_TY);
    }

    //<editor-fold desc="API">
    @LuaBridge
    public void setTranslateX(float ffrom, float fto) {
        addType(MASK_TX);
        int from = DimenUtil.dpiToPx(ffrom);
        int to = DimenUtil.dpiToPx(fto);
        if (isCurrentType(from)) {
            from = ValueType.CURRENT;
        }
        if (isCurrentType(to)) {
            to = ValueType.CURRENT;
        }
        addFloatValue(from, to, MASK_TX);
    }

    @LuaBridge
    public void setTranslateY(float ffrom, float fto) {
        addType(MASK_TY);
        int from = DimenUtil.dpiToPx(ffrom);
        int to = DimenUtil.dpiToPx(fto);
        if (isCurrentType(from)) {
            from = ValueType.CURRENT;
        }
        if (isCurrentType(to)) {
            to = ValueType.CURRENT;
        }
        addFloatValue(from, to, MASK_TY);
    }

    @LuaBridge
    public void setScaleWidthTo(float fto) {
        addType(MASK_SX);
        int to = DimenUtil.dpiToPx(fto);
        if (isCurrentType(to)) {
            to = ValueType.CURRENT;
        }
        addFloatValue(ValueType.CURRENT, to, MASK_SX);
    }

    @LuaBridge
    public void setScaleHeightTo(float fto) {
        addType(MASK_SY);
        int to = DimenUtil.dpiToPx(fto);
        if (isCurrentType(to)) {
            to = ValueType.CURRENT;
        }
        addFloatValue(ValueType.CURRENT, to, MASK_SY);
    }

    @LuaBridge
    public void setScaleWidth(float ffrom, float fto) {
        addType(MASK_SX);
        int from = DimenUtil.dpiToPx(ffrom);
        int to = DimenUtil.dpiToPx(fto);
        if (isCurrentType(from)) {
            from = ValueType.CURRENT;
        }
        if (isCurrentType(to)) {
            to = ValueType.CURRENT;
        }
        addFloatValue(from, to, MASK_SX);
    }

    @LuaBridge
    public void setScaleHeight(float ffrom, float fto) {
        addType(MASK_SY);
        int from = DimenUtil.dpiToPx(ffrom);
        int to = DimenUtil.dpiToPx(fto);
        if (isCurrentType(from)) {
            from = ValueType.CURRENT;
        }
        if (isCurrentType(to)) {
            to = ValueType.CURRENT;
        }
        addFloatValue(from, to, MASK_SY);
    }

    @LuaBridge
    public void setAlpha(float from, float to) {
        addType(MASK_A);
        addFloatValue(from, to, MASK_A);
    }

    @LuaBridge
    public void setAlphaTo(float to) {
        addType(MASK_A);
        addFloatValue(ValueType.CURRENT, to, MASK_A);
    }

    @LuaBridge
    public void setBgColor(UDColor from, UDColor to) {
        addType(MASK_Color);
        addFloatValue(from.getColor(), to.getColor(), MASK_Color);
    }

    @LuaBridge
    public void setBgColorTo(UDColor to) {
        addType(MASK_Color);
        addFloatValue(ValueType.CURRENT, to.getColor(), MASK_Color);
    }

    @LuaBridge
    public void needRepeat() {
        this.setRepeatMode(ValueAnimator.RESTART);
        this.setRepeatCount(INFINITE);
    }

    @LuaBridge
    public void needAutoreverseRepeat() {
        this.setRepeatMode(ValueAnimator.REVERSE);
        this.setRepeatCount(INFINITE);
    }

    @LuaBridge
    public void repeatCount(int count) {

        if (count == -1) {
            this.setRepeatCount(INFINITE);
            return;
        }

        switch (this.getRepeatMode()) {

            case RepeatType.REVERSE:
                count = 2 * count - 1;
                break;

            case RepeatType.FROM_START:
                if (count >= 1)
                    count = count - 1;
                break;
        }

        this.setRepeatCount(count);
    }

    @LuaBridge
    public void setDelay(float delay) {
        this.setStartDelay((long) (delay * 1000));
    }

    @LuaBridge
    public void setDuration(float duration) {
        this.setDuration((long) (duration * 1000));
    }

    @LuaBridge
    public void setInterpolator(int type) {
        this.setInterpolator(Utils.parse(type));
    }

    @LuaBridge
    public void start(UDView view) {
        targetUDView = view;
        view.addFrameAnimation(this);
        target = view.getView();
        checkHasDefault();
        formDelayValueIfNeed();//与IOS同步，delay动画，直接设置初始值
        this.start();
    }

    @LuaBridge
    public void setEndCallback(LVCallback endCallback) {
        if (this.endCallback != null)
            this.endCallback.destroy();
        this.endCallback = endCallback;
    }

    //</editor-fold>

    private void addType(int mask) {
        animType |= (1 << mask);
    }

    private boolean checkHasType(int mask) {
        return (animType & (1 << mask)) != 0;
    }

    private void addFloatValue(float from, float to, int mask) {
        int index = mask * 2;
        floatValues[index] = from;
        floatValues[index + 1] = to;
    }

    /**
     * 设置当前target的默认值
     */
    private void checkHasDefault() {
        tempFloatValues = floatValues.clone();

        for (int mask = MASK_TX; mask <= MASK_Color; mask++) {
            int index = mask * 2;
            float from = tempFloatValues[index];
            if (from == ValueType.CURRENT) {
                switch (mask) {
                    case MASK_TX:
                        from = target.getX();
                        break;
                    case MASK_TY:
                        from = target.getY();
                        break;
                    case MASK_R:
                        from = target.getRotation();
                        break;
                    case MASK_SX:
                        from = target.getWidth();
                        break;
                    case MASK_SY:
                        from = target.getHeight();
                        break;
                    case MASK_A:
                        from = target.getAlpha();
                        break;
                    case MASK_Color:
                        from = targetUDView.getBgColor();
                        break;
                }
                tempFloatValues[index] = from;
            }
        }
    }

    private void formDelayValueIfNeed() {
        if (this.getStartDelay() <= 0) {
            return;
        }
        doAllAnimNoCheck(0);
    }

    /**
     * 判断当前类型
     *
     * @param value
     * @return
     */
    private boolean isCurrentType(int value) {
        if (current_type_value == -1) {
            current_type_value = DimenUtil.dpiToPx(ValueType.CURRENT);
        }
        return current_type_value == value;
    }

    private void doAnim(float animValue, int mask) {
        if (!checkHasType(mask) || tempFloatValues == null)
            return;
        int index = mask * 2;
        float from = tempFloatValues[index];
        float to = tempFloatValues[index + 1];
        float a = (to - from) * animValue + from;
        switch (mask) {
            case MASK_TX:
                target.setX(a);
                break;
            case MASK_TY:
                target.setY(a);
                break;
            case MASK_R:
                target.setRotation(a);
                break;
            case MASK_SX:
                ViewGroup.LayoutParams lpX = target.getLayoutParams();
                if (lpX != null) {
                    lpX.width = (int) a;
                    target.setLayoutParams(lpX);
                }
                break;
            case MASK_SY:
                ViewGroup.LayoutParams lpY = target.getLayoutParams();
                if (lpY != null) {
                    lpY.height = (int) a;
                    target.setLayoutParams(lpY);
                }
                break;
            case MASK_A:
                target.setAlpha(a);
                break;
        }
    }

    private void doColorAnim(float av) {
        if (checkHasType(MASK_Color)) {
            int index = MASK_Color * 2;
            int from = (int) tempFloatValues[index];
            int to = (int) tempFloatValues[index + 1];
            int a = ColorUtils.evaluate(av, from, to);
            targetUDView.setBgColor(a);
        }
    }

    private void autoBackToFrom() {
        boolean autoBack = false;
        if (!autoBack || target == null)
            return;

        doAllAnimNoCheck(0);
    }

    private void doAllAnimNoCheck(float v) {
        for (int i = MASK_TX; i < MASK_Color; i++) {
            doAnim(v, i);
        }
        doColorAnim(v);
    }

    //<editor-fold desc="AnimatorUpdateListener">
    @Override
    public void onAnimationUpdate(ValueAnimator animation) {
        if (target == null)
            return;
        float value = (float) animation.getAnimatedValue();
        doAllAnimNoCheck(value);
    }
    //</editor-fold>

    //<editor-fold desc="AnimatorListener">
    public void onAnimationStart(Animator animation) {
        isCancel = false;
    }

    @Override
    public void onAnimationEnd(Animator animation) {
        autoBackToFrom();
        if (targetUDView != null)
            targetUDView.removeFrameAnimation(animation);
        if (endCallback != null)
            endCallback.call(!isCancel);
    }

    @Override
    public void onAnimationCancel(Animator animation) {
        isCancel = true;
    }

    @Override
    public void onAnimationRepeat(Animator animation) {

    }

    //</editor-fold>
}
