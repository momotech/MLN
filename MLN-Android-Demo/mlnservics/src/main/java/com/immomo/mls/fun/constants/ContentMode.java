package com.immomo.mls.fun.constants;

import android.widget.ImageView;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@ConstantClass
public interface ContentMode {
    @Constant
    int SCALE_TO_FILL = ImageView.ScaleType.FIT_XY.ordinal();
    @Constant
    int SCALE_ASPECT_FIT = ImageView.ScaleType.FIT_CENTER.ordinal();
    @Constant
    int SCALE_ASPECT_FILL = ImageView.ScaleType.CENTER_CROP.ordinal();
    @Constant
    int CENTER = ImageView.ScaleType.CENTER.ordinal();
}
