package com.immomo.mls.base.ud.lv;


import android.graphics.Canvas;

import com.immomo.mls.fun.ud.view.UDView;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
public interface ILView<V extends UDView> {
    V getUserdata();

    void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback);

    interface ViewLifeCycleCallback extends ICanvasView {
        void onDetached();

        void onAttached();
    }

    interface ICanvasView {
        void onDrawCallback(Canvas canvas);
    }

}
