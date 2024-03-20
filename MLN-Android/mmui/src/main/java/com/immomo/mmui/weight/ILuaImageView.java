package com.immomo.mmui.weight;

import java.util.List;

/**
 * Created by Xiong.Fangyu on 2020/11/11
 */
public interface ILuaImageView {

    void setImage(String url);

    void setImageUrlEmpty();

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
