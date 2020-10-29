/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.weight.flex;

/**
 * Created by zhang.ke
 * on 2020-04-08
 */
public interface IFlexLayoutHelper {
      void measureHorizontal(int widthMeasureSpec, int heightMeasureSpec);
      void measureVertical(int widthMeasureSpec, int heightMeasureSpec);

      void layoutVertical(int left, int top, int right, int bottom);
      void layoutHorizontal(int left, int top, int right, int bottom);

}
