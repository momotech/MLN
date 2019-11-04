package com.immomo.mls.fun.constants;

import android.graphics.Paint;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by zhang.ke
 * on 2019/7/25
 */
@ConstantClass
public interface DrawStyle {
    @Constant
    int Fill = Paint.Style.FILL.ordinal();
    @Constant
    int Stroke = Paint.Style.STROKE.ordinal();
    @Constant
    int FillStroke = Paint.Style.FILL_AND_STROKE.ordinal();
}
