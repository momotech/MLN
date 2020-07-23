/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.base;


import com.immomo.mmui.anim.animatable.*;

import java.util.HashMap;

public class PropertyName {
    private PropertyName() {
        throw new IllegalStateException("Utility class :PropertyName");
    }

    public static final String K_MLAVIEW_ALPHA = "kMLAViewAlpha";  // 透明度
    public static final String K_MLAVIEW_COLOR = "kMLAViewColor";  // 背景色

    public static final String K_MLAVIEW_POSITION = "kMLAViewPOSITION";     // 中心点
    public static final String K_MLAVIEW_POSITION_X = "kMLAViewPOSITIONX";    // 中心点X
    public static final String K_MLAVIEW_POSITION_Y = "kMLAViewPOSITIONY";    // 中心点Y

    public static final String K_MLAVIEW_SIZE = "kMLAViewSize";       // 尺寸
    public static final String K_MLAVIEW_FRAME = "kMLAViewFrame";      // 原点 + 尺寸

    public static final String K_MLAVIEW_SCALE = "kMLAViewScale";      // XY缩放
    public static final String K_MLAVIEW_SCALE_X = "kMLAViewScaleX";     // X缩放
    public static final String K_MLAVIEW_SCALE_Y = "kMLAViewScaleY";     // Y缩放

    public static final String K_MLAVIEW_ROTATION = "kMLAViewRotation";       // Z旋转
    public static final String K_MLAVIEW_ROTATION_X = "kMLAViewRotationX";      // X旋转
    public static final String K_MLAVIEW_ROTATION_Y = "kMLAViewRotationY";      // Y旋转

    // 计算精度
    public static final float THRESHOLD_COLOR = 0.01f;
    public static final float THRESHOLD_POINT = 1.0f;
    public static final float THRESHOLD_ALPHA = 0.01f;
    public static final float THRESHOLD_SCALE = 0.005f;
    public static final float THRESHOLD_ROTATION = 0.01f;


    private static HashMap<String, Animatable> propertyNameMap = new HashMap<>();

    static {
        propertyNameMap.put(K_MLAVIEW_ALPHA, new AlphaAnimatable(K_MLAVIEW_ALPHA));
        propertyNameMap.put(K_MLAVIEW_COLOR, new BgColorAnimatable(K_MLAVIEW_COLOR));
        propertyNameMap.put(K_MLAVIEW_SIZE, new ViewSizeAnimatable(K_MLAVIEW_SIZE));
        propertyNameMap.put(K_MLAVIEW_FRAME, new ViewFrameAnimatable(K_MLAVIEW_FRAME));

        propertyNameMap.put(K_MLAVIEW_ROTATION, new RotationAnimatable(K_MLAVIEW_ROTATION));
        propertyNameMap.put(K_MLAVIEW_ROTATION_X, new RotationXAnimatable(K_MLAVIEW_ROTATION_X));
        propertyNameMap.put(K_MLAVIEW_ROTATION_Y, new RotationYAnimatable(K_MLAVIEW_ROTATION_Y));

        propertyNameMap.put(K_MLAVIEW_SCALE, new ScaleAnimatable(K_MLAVIEW_SCALE));
        propertyNameMap.put(K_MLAVIEW_SCALE_X, new ScaleXAnimatable(K_MLAVIEW_SCALE_X));
        propertyNameMap.put(K_MLAVIEW_SCALE_Y, new ScaleYAnimatable(K_MLAVIEW_SCALE_Y));

        propertyNameMap.put(K_MLAVIEW_POSITION, new ViewPositionAnimatable(K_MLAVIEW_POSITION));
        propertyNameMap.put(K_MLAVIEW_POSITION_X, new ViewPositionXAnimatable(K_MLAVIEW_POSITION_X));
        propertyNameMap.put(K_MLAVIEW_POSITION_Y, new ViewPositionYAnimatable(K_MLAVIEW_POSITION_Y));


    }


    public static Animatable getAnimatable(String propertyName) {
        Animatable animatable = null;
        if (propertyNameMap.containsKey(propertyName)) {
            animatable = propertyNameMap.get(propertyName);
        }
        return animatable;
    }


}