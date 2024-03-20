/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.base;

public interface AnimationListener {


    /**
     * 动画底层被执行
     *
     * @param animation:self
     */
    void start(Animation animation);

    void pause(Animation animation);

    void resume(Animation animation);

    void repeat(Animation animation, int count);

    void finish(Animation animation, boolean finished);


}