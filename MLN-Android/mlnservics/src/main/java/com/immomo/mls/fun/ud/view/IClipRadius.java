/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.view;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import androidx.annotation.IntDef;

/**
 * Created by zhang.ke
 * 新版圆角方案，WIKI：{@link com.immomo.mls.fun.lt.SICornerRadiusManager}
 * on 2019/11/1
 */
public interface IClipRadius {

    //圆角类型
    int TYPE_CORNER_NONE = 0x0;//默认没设置圆角
    int TYPE_CORNER_RADIUS = 0x1;//cornerRadius()
    int TYPE_CORNER_DIRECTION = 0x2;//setCornerRadiusWithDirection()
    int TYPE_CORNER_MASK = 0x3;//addCornerMask()
    @IntDef({TYPE_CORNER_NONE, TYPE_CORNER_RADIUS, TYPE_CORNER_DIRECTION,TYPE_CORNER_MASK})
    @Retention(RetentionPolicy.SOURCE)
    @interface CornerType {}

    //切割等级
    int LEVEL_NORMAL_CLIP=0x0;//默认状态，未调用clipToBounds()，使用CornerManager
    int LEVEL_FORCE_CLIP=0x1;//强制切割圆角，主动调用clipToBounds(true)时
    int LEVEL_FORCE_NOTCLIP=0x2;//强制不切圆角，主动调用clipToBounds(false)时
    @IntDef({LEVEL_NORMAL_CLIP, LEVEL_FORCE_CLIP, LEVEL_FORCE_NOTCLIP})
    @Retention(RetentionPolicy.SOURCE)
    @interface ClipLevel {}


    void initCornerManager(boolean open);//初始化：CornerManager 圆角配置
    void forceClipLevel(@ClipLevel int clipLevel);//不同场景，需要不同等级

}
