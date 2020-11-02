/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.ud.anim;

import com.immomo.mmui.anim.animations.MultiAnimation;
import com.immomo.mmui.anim.animations.ObjectAnimation;
import com.immomo.mmui.anim.base.Animation;

import java.util.ArrayList;
import java.util.List;

/**
 * 用于通过百分比驱动的动画
 * Created by wang.yang on 2020-07-20
 */
public class SetPercentBehavior extends PercentBehavior {

    private List<PercentBehavior> percentBehaviors = new ArrayList<>();
    private boolean isRunTogether;

    @Override
    public void setAnimation(UDBaseAnimation ud) {
        UDAnimatorSet set = (UDAnimatorSet) ud;
        MultiAnimation multiAnimation = (MultiAnimation) ud.getJavaUserdata();
        isRunTogether = multiAnimation.isRunTogether();
        List<UDAnimation> list = set.getAnimationList();
        if (list != null) {
            for (UDAnimation ua : list) {
                percentBehaviors.add(ua.getPercentBehavior());
            }
        }
    }

    @Override
    public void update(float percent) {
        if (percentBehaviors.isEmpty()) {
            return;
        }
        if (isRunTogether) {
            for (PercentBehavior percentBehavior : percentBehaviors) {
                percentBehavior.update(percent);
            }
        } else {
            // 分段
            float section = (float) (1.0 / percentBehaviors.size());
            int index = (int) Math.floor(percent / section);
            if (index >= percentBehaviors.size()) {
                return;
            }
            float left = percent % section;
            float eachPercent = left / section;
            percentBehaviors.get(index).update(eachPercent);
        }
    }

}
