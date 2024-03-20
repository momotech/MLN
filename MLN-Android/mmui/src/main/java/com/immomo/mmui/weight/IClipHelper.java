package com.immomo.mmui.weight;

import android.graphics.Canvas;
import android.view.View;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 *
 * 帮助view切割圆角
 */
public interface IClipHelper extends Clippable {
    /**
     * 当{@link #needClipCanvas()}返回false时，使用此方法切割View
     * 并使用{@link #revert(View)}方法还原
     */
    void applyClip(View v);

    /**
     * 还原由{@link #applyClip(View)}切割方式
     */
    void revert(View v);

    /**
     * 是否需要切割canvas
     * 返回true，则需要在draw方法中，调用{@link #clip(Canvas)}方法
     * 否则，使用{@link #applyClip(View)}方法即可
     */
    boolean needClipCanvas();

    /**
     * 在{@link View#draw(Canvas)}或{@link View#dispatchDraw(Canvas)}前调用
     */
    void clip(Canvas c);

    /**
     * view宽高变化时调用
     */
    void onSizeChanged(int w, int h);
}
