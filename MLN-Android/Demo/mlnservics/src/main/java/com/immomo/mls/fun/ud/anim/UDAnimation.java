package com.immomo.mls.fun.ud.anim;

import android.animation.Animator;
import android.animation.ValueAnimator;
import android.os.Build;
import android.view.View;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.LVCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import static android.animation.ValueAnimator.INFINITE;


/**
 * Created by XiongFangyu on 2018/8/10.
 */
@LuaClass
public class UDAnimation implements ValueAnimator.AnimatorUpdateListener, Animator.AnimatorListener {
    public static final String LUA_CLASS_NAME = "Animation";

    private static final int MASK_TX = 0;
    private static final int MASK_TY = 1;
    private static final int MASK_R = 2;
    private static final int MASK_RX = 3;
    private static final int MASK_RY = 4;
    private static final int MASK_SX = 5;
    private static final int MASK_SY = 6;
    private static final int MASK_A = 7;

    private boolean isCancel = false;
    private Globals globals;

    public UDAnimation(Globals globals, LuaValue[] varargs) {
        this.globals = globals;
        mAnimator = new ValueAnimator();
        mAnimator.addUpdateListener(this);
        mAnimator.setInterpolator(Utils.linear);
        mAnimator.addListener(this);
        mAnimator.setFloatValues(0, 1);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            mAnimator.addPauseListener(new Animator.AnimatorPauseListener() {
                @Override
                public void onAnimationPause(Animator animation) {
                    if (pauseCallback != null) {
                        pauseCallback.call();
                    }
                }

                @Override
                public void onAnimationResume(Animator animation) {
                    if (resumeCallback != null) {
                        resumeCallback.call();
                    }
                }
            });
        }
    }

    public void __onLuaGc() {
        if (!globals.isDestroyed()) {
            return;
        }
        target = null;
        if (startCallback != null)
            startCallback.destroy();
        if (endCallback != null)
            endCallback.destroy();
        if (cancelCallback != null)
            cancelCallback.destroy();
        if (repeatCallback != null)
            repeatCallback.destroy();
        if (pauseCallback != null)
            pauseCallback.destroy();
        if (resumeCallback != null)
            resumeCallback.destroy();
        startCallback = null;
        endCallback = null;
        cancelCallback = null;
        repeatCallback = null;
        pauseCallback = null;
        resumeCallback = null;
        udTarget = null;
        mAnimator.cancel();
    }

    private byte animType;
    private final float[] floatValues = new float[(MASK_A + 1) * 2];
    private final ValueAnimator mAnimator;
    private boolean autoBack = false;
    private UDView udTarget;
    private View target;

    private LVCallback
            startCallback,
            endCallback,
            cancelCallback,
            repeatCallback,
            pauseCallback,
            resumeCallback;

    //<editor-fold desc="API">
    @LuaBridge
    public void setTranslateX(float from, float to) {
        addType(MASK_TX);
        addFloatValue(DimenUtil.dpiToPx(from), DimenUtil.dpiToPx(to), MASK_TX);
    }

    @LuaBridge
    public void setTranslateY(float from,
                              float to) {
        addType(MASK_TY);
        addFloatValue(DimenUtil.dpiToPx(from), DimenUtil.dpiToPx(to), MASK_TY);
    }

    @LuaBridge
    public void setRotate(float from, float to) {
        addType(MASK_R);
        addFloatValue(from, to, MASK_R);
    }

    @LuaBridge
    public void setRotateX(float from, float to) {
        addType(MASK_RX);
        addFloatValue(from, to, MASK_RX);
    }

    @LuaBridge
    public void setRotateY(float from, float to) {
        addType(MASK_RY);
        addFloatValue(from, to, MASK_RY);
    }

    @LuaBridge
    public void setScaleX(float from, float to) {
        addType(MASK_SX);
        addFloatValue(from, to, MASK_SX);
    }

    @LuaBridge
    public void setScaleY(float from, float to) {
        addType(MASK_SY);
        addFloatValue(from, to, MASK_SY);
    }

    @LuaBridge
    public void setAlpha(float from, float to) {
        addType(MASK_A);
        addFloatValue(from, to, MASK_A);
    }

    @LuaBridge
    public void setRepeat(@RepeatType.RepeatMode int type, int count) {

        switch (type) {
            case RepeatType.NONE:
                count = 0;
                break;

            case RepeatType.REVERSE:
                if (count == -1) {
                    count = INFINITE;
                } else if (count > 0) {
                    count = 2 * count - 1;
                } else
                    count = 1;
                break;

            case RepeatType.FROM_START:   // 0 的时候会执行一次   -1 则会无限循环
                if (count >= 1)
                    count = count - 1;
                else if (count < -1)
                    count = 0;
                break;
        }

        mAnimator.setRepeatCount(count);
        mAnimator.setRepeatMode(type);
    }

    @LuaBridge
    public void repeatCount(int count) {

        if (count == -1) {
            mAnimator.setRepeatCount(INFINITE);
            return;
        }

        switch (mAnimator.getRepeatMode()) {

            case RepeatType.REVERSE:
                count = 2 * count - 1;
                break;

            case RepeatType.FROM_START:
                if (count >= 1)
                    count = count - 1;
                break;
        }

        mAnimator.setRepeatCount(count);
    }

    @LuaBridge
    public void setAutoBack(boolean autoBack) {
        this.autoBack = autoBack;
    }

    @LuaBridge
    public void setDuration(float duration) {
        mAnimator.setDuration((long) (duration * 1000));
    }

    @LuaBridge
    public void setInterpolator(int type) {
        mAnimator.setInterpolator(Utils.parse(type));
    }

    @LuaBridge
    public void setDelay(float delay) {
        mAnimator.setStartDelay((long) (delay * 1000));
    }

    @LuaBridge
    public void start(UDView view) {
        view.addFrameAnimation(mAnimator);
        target = view.getView();
        udTarget = view;

        getOriginalProperties();
        if (mAnimator.isRunning())
            mAnimator.cancel();
        mAnimator.start();
    }

    @LuaBridge
    public void pause() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            mAnimator.pause();
        }
    }

    @LuaBridge
    public void resume() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            mAnimator.resume();
        }
    }

    @LuaBridge
    public void stop() {
        mAnimator.end();
    }

    @LuaBridge
    public void cancel() {
        mAnimator.cancel();
    }

    @LuaBridge
    public void setStartCallback(LVCallback startCallback) {
        if (this.startCallback != null)
            this.startCallback.destroy();
        this.startCallback = startCallback;
    }

    @LuaBridge
    public void setEndCallback(LVCallback endCallback) {
        if (this.endCallback != null)
            this.endCallback.destroy();
        this.endCallback = endCallback;
    }

    @LuaBridge
    public void setCancelCallback(LVCallback cancelCallback) {
        if (this.cancelCallback != null)
            this.cancelCallback.destroy();
        this.cancelCallback = cancelCallback;
    }

    @LuaBridge
    public void setRepeatCallback(LVCallback repeatCallback) {
        if (this.repeatCallback != null)
            this.repeatCallback.destroy();
        this.repeatCallback = repeatCallback;
    }

    @LuaBridge
    public void setPauseCallback(LVCallback pauseCallback) {
        if (this.pauseCallback != null)
            this.pauseCallback.destroy();
        this.pauseCallback = pauseCallback;
    }

    @LuaBridge
    public void setResumeCallback(LVCallback resumeCallback) {
        if (this.resumeCallback != null)
            this.resumeCallback.destroy();
        this.resumeCallback = resumeCallback;
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

    private void doAnim(float animValue, int mask) {
        if (!checkHasType(mask))
            return;

        int index = mask * 2;

        float from = floatValues[index];
        float to = floatValues[index + 1];

        float a = (to - from) * animValue + from;

        switch (mask) {
            case MASK_TX:
                target.setTranslationX(a);
                break;
            case MASK_TY:
                target.setTranslationY(a);
                break;
            case MASK_R:
                target.setRotation(a);
                break;
            case MASK_RX:
                target.setRotationX(a);
                break;
            case MASK_RY:
                target.setRotationY(a);
                break;
            case MASK_SX:
                target.setScaleX(a);
                break;
            case MASK_SY:
                target.setScaleY(a);
                break;
            case MASK_A:
                target.setAlpha(a);
                break;
        }
    }

    private final float[] originalFloatValues = new float[MASK_A + 1];

    private void getOriginalProperties() {
        originalFloatValues[MASK_TX] = target.getTranslationX();
        originalFloatValues[MASK_TY] = target.getTranslationY();
        originalFloatValues[MASK_R] = target.getRotation();
        originalFloatValues[MASK_RX] = target.getRotationX();
        originalFloatValues[MASK_RY] = target.getRotationY();
        originalFloatValues[MASK_SX] = target.getScaleX();
        originalFloatValues[MASK_SY] = target.getScaleY();
        originalFloatValues[MASK_A] = target.getAlpha();
    }

    private void doResetBackAnim(int mask) {
        if (!checkHasType(mask))
            return;

        float a = originalFloatValues[mask];

        switch (mask) {
            case MASK_TX:
                target.setTranslationX(a);
                break;
            case MASK_TY:
                target.setTranslationY(a);
                break;
            case MASK_R:
                target.setRotation(a);
                break;
            case MASK_RX:
                target.setRotationX(a);
                break;
            case MASK_RY:
                target.setRotationY(a);
                break;
            case MASK_SX:
                target.setScaleX(a);
                break;
            case MASK_SY:
                target.setScaleY(a);
                break;
            case MASK_A:
                target.setAlpha(a);
                break;
        }
    }

    private void autoBackToFrom() {
        if (!autoBack || target == null)
            return;

        for (int i = MASK_TX; i <= MASK_A; i++) {
            doResetBackAnim(i);
            // doAnim(0, i);
        }
    }

    //<editor-fold desc="AnimatorUpdateListener">
    @Override
    public void onAnimationUpdate(ValueAnimator animation) {
        if (target == null)
            return;
        float value = (float) animation.getAnimatedValue();
        for (int i = MASK_TX; i <= MASK_A; i++) {
            doAnim(value, i);
        }
    }
    //</editor-fold>

    //<editor-fold desc="AnimatorListener">
    @Override
    public void onAnimationStart(Animator animation) {
        isCancel = false;
        if (startCallback != null)
            startCallback.call();
    }

    /**
     * 动画结束，isCancel标记动画是否完整执行,回调true
     *
     * @param animation
     */
    @Override
    public void onAnimationEnd(Animator animation) {
        autoBackToFrom();
        if (endCallback != null)
            endCallback.call(!isCancel);
        if (udTarget != null)
            udTarget.removeFrameAnimation(animation);
    }

    @Override
    public void onAnimationCancel(Animator animation) {
        isCancel = true;
    }

    @Override
    public void onAnimationRepeat(Animator animation) {
        if (repeatCallback != null)
            repeatCallback.call();
    }
    //</editor-fold>
}
