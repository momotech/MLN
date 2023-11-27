/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import java.util.List;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public interface ILuaImageView {

    void setImage(String url);

    String getImage();

    void setLocalUrl(String url);

    String getLocalUrl();

    void startAnimImages(List<String> list, long duration, boolean repeat);

    void stop();

    boolean isRunning();

    boolean isLazyLoad();

    void setLazyLoad(boolean lazyLoad);

    void setImageUrlWithPlaceHolder(String urlString, String placeholder);

    void setBlurImage(float blurValue);

    void setCompatScaleType(int type);
}