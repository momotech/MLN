/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.weight.load;

import androidx.annotation.NonNull;
import android.view.View;

/**
 * Created by XiongFangyu on 2018/6/21.
 */
public interface ILoadWithTextView extends ILoadView {
    /**
     * 设置加载时的文字
     * @param text
     */
    void setLoadText(CharSequence text);

    /**
     * 获取view
     * @return
     */
    @NonNull View getView();
}