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
}
