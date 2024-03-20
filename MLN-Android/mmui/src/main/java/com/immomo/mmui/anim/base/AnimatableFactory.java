/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.anim.base;


import android.util.SparseArray;

import com.immomo.mmui.anim.animatable.*;
import com.immomo.mmui.ud.constants.AnimProperty;

public class AnimatableFactory {
    private AnimatableFactory() {
        throw new IllegalStateException("Utility class :PropertyName");
    }

    // 计算精度
    public static final float THRESHOLD_COLOR = 0.01f;
    public static final float THRESHOLD_POINT = 1.0f;
    public static final float THRESHOLD_ALPHA = 0.01f;
    public static final float THRESHOLD_SCALE = 0.005f;
    public static final float THRESHOLD_ROTATION = 0.01f;

    private static SparseArray<Animatable> animatableArray = new SparseArray<>();

    static {
        animatableArray.put(AnimProperty.Alpha, new AlphaAnimatable());
        animatableArray.put(AnimProperty.Color, new BgColorAnimatable());

        animatableArray.put(AnimProperty.Rotation, new RotationAnimatable());
        animatableArray.put(AnimProperty.RotationX, new RotationXAnimatable());
        animatableArray.put(AnimProperty.RotationY, new RotationYAnimatable());

        animatableArray.put(AnimProperty.Scale, new ScaleAnimatable());
        animatableArray.put(AnimProperty.ScaleX, new ScaleXAnimatable());
        animatableArray.put(AnimProperty.ScaleY, new ScaleYAnimatable());

        animatableArray.put(AnimProperty.Position, new ViewPositionAnimatable());
        animatableArray.put(AnimProperty.PositionX, new ViewPositionXAnimatable());
        animatableArray.put(AnimProperty.PositionY, new ViewPositionYAnimatable());

        animatableArray.put(AnimProperty.ContentOffset, new ContentOffsetAnimatable());
        animatableArray.put(AnimProperty.TextColor, new TextColorAnimatable());


    }

    public static Animatable getAnimatable(int animProperty) {
        return animatableArray.get(animProperty);
    }

}
