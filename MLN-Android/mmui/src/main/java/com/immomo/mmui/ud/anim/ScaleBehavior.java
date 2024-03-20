package com.immomo.mmui.ud.anim;

import android.view.MotionEvent;
import android.view.View;

import com.immomo.mls.util.DimenUtil;

/**
 * Created by Xiong.Fangyu on 2020/10/27
 */
public class ScaleBehavior extends BaseGestureBehavior {
    public static final int TYPE_X = 1;
    public static final int TYPE_Y = 2;
    public static final int TYPE_XY = TYPE_X | TYPE_Y;
    /**
     * 滑动过程中的距离
     * 数组长度为3，分别保存X、Y和XY的距离
     * 0: X
     * 1: Y
     * 2: XY
     */
    private float[] distance = new float[3];

    /**
     * 多指中心点
     */
    private float startFocusX, startFocusY;
    private float targetTranslationX, targetTranslationY;

    private float lastDistance;

    private int type = TYPE_XY;

    private boolean inProgress;

    public ScaleBehavior() {
        setType(TYPE_XY);
    }

    public ScaleBehavior(int type) {
        setType(type);
    }

    public void setType(int type) {
        switch (type) {
            case TYPE_X:
            case TYPE_Y:
            case TYPE_XY:
                this.type = type;
                break;
            default:
                throw new IllegalArgumentException();
        }
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        if (!enable)
            return false;
        if (endDistance == 0)
            return false;
        int actionMask = event.getActionMasked();
        switch (actionMask) {
            case MotionEvent.ACTION_DOWN:
                initDistance(distance);
                inProgress = false;
                break;
            case MotionEvent.ACTION_POINTER_DOWN:
                if (inProgress)
                    break;
                inProgress = currDistance(distance, event);
                if (inProgress) {
                    targetView.getParent().requestDisallowInterceptTouchEvent(true);
                    twoPointerBegin();
                    if (followEnable) {
                        startFocusX = getFocusX(event);
                        startFocusY = getFocusY(event);
                        targetTranslationX = targetView.getTranslationX();
                        targetTranslationY = targetView.getTranslationY();
                    }
                }
                break;
            case MotionEvent.ACTION_POINTER_UP:
                if (inProgress)
                    twoPointerEnd(false);
                inProgress = false;
                initDistance(distance);
                break;
            case MotionEvent.ACTION_MOVE:
                if (!inProgress)
                    break;
                inProgress = currDistance(distance, event);
                if (inProgress) {
                    twoPointerMove();
                    if (followEnable) {
                        float fx = getFocusX(event);
                        float fy = getFocusY(event);
                        targetView.setTranslationX(fx - startFocusX + targetTranslationX);
                        targetView.setTranslationY(fy - startFocusY + targetTranslationY);
                    }
                }
                break;
            case MotionEvent.ACTION_UP:
                if (!inProgress)
                    break;
                twoPointerEnd(false);
                break;
            case MotionEvent.ACTION_CANCEL:
                if (!inProgress)
                    break;
                twoPointerEnd(true);
                break;
        }
        return true;
    }

    private float getFocusX(MotionEvent e) {
        int count = e.getPointerCount();
        float fx = e.getRawX();
        if (count > 1) {
            return fx + (e.getX(1) - e.getX(0)) / 2;
        }
        return fx;
    }

    private float getFocusY(MotionEvent e) {
        int count = e.getPointerCount();
        float fy = e.getRawY();
        if (count > 1) {
            return fy + (e.getY(1) - e.getY(0)) / 2;
        }
        return fy;
    }

    private void initDistance(float[] dis) {
        dis[0] = dis[1] = dis[2] = 0;
    }

    private boolean currDistance(float[] dis, MotionEvent e) {
        int count = e.getPointerCount();
        if (count < 2)
            return false;
        dis[0] = Math.abs(e.getX(1) - e.getX(0));
        dis[1] = Math.abs(e.getY(1) - e.getY(0));
        dis[2] = (float) Math.sqrt(dis[0] * dis[0] + dis[1] * dis[1]);
        return true;
    }

    private float getDistance() {
        return distance[type - 1];
    }

    private void twoPointerBegin() {
        if (callback != null)
            callback.callback(TouchType.BEGIN, 0, 0);
        lastDistance = getDistance();
    }

    private void twoPointerMove() {
        float deltaDis = getDistance() - lastDistance;
        if (!Float.isNaN(minDistance)) {
            deltaDis = deltaDis < minDistance ? minDistance : deltaDis;
        }
        if (!Float.isNaN(maxDistance)) {
            deltaDis = deltaDis > maxDistance ? maxDistance : deltaDis;
        }
        if (!overBoundary) {
            deltaDis = deltaDis < 0 ? 0 : deltaDis;
            deltaDis = deltaDis > endDistance ? (float) endDistance : deltaDis;
        }
        final float scale = deltaDis / endDistance + lastPercent;
        lastDistance += deltaDis;
        if (callback != null)
            callback.callback(TouchType.MOVE, DimenUtil.pxToDpi(lastDistance), scale);
        if (!innerPercentBehaviors.isEmpty()) {
            update(scale);
        }
    }

    private void twoPointerEnd(boolean cancel) {
        if (callback != null)
            callback.callback(TouchType.END, 0, 0);
    }
}
