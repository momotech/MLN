/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui;


import android.graphics.Canvas;

import com.immomo.mls.fun.IUserdataHolder;
import com.immomo.mmui.ud.UDView;


/**
 * Created by XiongFangyu on 2018/7/31.
 */
public interface ILView<V extends UDView> extends IUserdataHolder {
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