/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.widget.ImageView;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.fun.constants.ContentMode;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.provider.ImageProvider;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mmui.ILView;
import com.immomo.mmui.ui.LuaImageView;
import com.immomo.mmui.weight.IBackground;
import com.immomo.mmui.weight.IClippableView;
import com.immomo.mmui.weight.ILuaImageView;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.DisposableIterator;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed
public class UDImageView<I extends ImageView & ILuaImageView & ILView> extends UDView<I> {

    public static final String LUA_CLASS_NAME = "ImageView";

    private static final String TAG = UDImageView.class.getSimpleName();

    private LuaFunction imageLoadCallback;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDImageView(long L) {
        super(L, null);
    }

    @Override
    protected I newView(LuaValue[] init) {
        return (I) new LuaImageView(getContext(), this);
    }

    @Override
    protected void initClipConfig() {
        forceClip = true;
        IClippableView view = checkClippableVieW();
        if (view != null)
            view.openClip(forceClip);
    }

    //<editor-fold desc="native method">
    /**
     * 初始化方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>
    //<editor-fold desc="API">
    //<editor-fold desc="Property">

    @LuaApiUsed
    public void setImage(String url) {
        getView().setImage(url);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public String getImage() {
        return getView().getImage();
    }

    @LuaApiUsed
    public int getContentMode() {
        return getView().getScaleType().ordinal();
    }

    @LuaApiUsed
    public void setContentMode(int type) {
        getView().setScaleType(ImageView.ScaleType.values()[type]);
    }

    @LuaApiUsed
    public boolean isLazyLoad() {
        return getView().isLazyLoad();
    }

    @LuaApiUsed
    public void setLazyLoad(boolean lazyLoad) {
        getView().setLazyLoad(lazyLoad);
    }

    @LuaApiUsed
    public void setImageUrl(String url, String placeHolder) {
        setImageUrlInner(url, placeHolder);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public void setImageWithCallback(String url, String placeHolder, LuaFunction imageLoadCallback) {
        this.imageLoadCallback = imageLoadCallback;
        setImageUrlInner(url, placeHolder);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public void blurImage(float blurValue) {
        //ios新增参数2，Android不处理
        if (blurValue < 0)
            blurValue = 0;
        if (blurValue > 25)
            blurValue = 25;
        final float finalValue = blurValue;
        if (finalValue >= 0 && finalValue <= 25) {  // 0 则去掉高斯模糊

            if (getImage() != null && getImage().length() > 0 && getView().getDrawable() == null) {  // 先设置图片路径，后设置 blurImage() 时

                MainThreadExecutor.cancelAllRunnable(getTaskTag());
                MainThreadExecutor.postDelayed(getTaskTag(), new Runnable() {
                    @Override
                    public void run() {
                        getView().setBlurImage(finalValue);
                    }
                }, 300);
                return;
            }

            getView().setBlurImage(blurValue);
            getFlexNode().dirty();
        }
    }

    @LuaApiUsed
    public void setCornerImage(String url, String placeHolder, float radius, int d) {
        setCornerRadiusWithDirection(radius, d);
        ((LuaImageView) getView()).setImageUrlEmpty();
        setImageUrlInner(url, placeHolder);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public void setCornerImage(String url, String placeHolder, float radius) {
        setCornerRadius(DimenUtil.dpiToPx(radius));
        ((LuaImageView) getView()).setImageUrlEmpty();
        setImageUrlInner(url, placeHolder);
        getFlexNode().dirty();
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public void startAnimationImages(LuaTable value, float d, boolean repeat) {
        List list = ConvertUtils.toArrayList(value);
        if (list == null || list.isEmpty())
            return;
        long duration = (long) (d * 1000);
        view.startAnimImages(list, duration, repeat);
    }

    @LuaApiUsed
    public void stopAnimationImages() {
        view.stop();
    }

    @LuaApiUsed
    public boolean isAnimating() {
        return view.isRunning();
    }
    //</editor-fold>
    //</editor-fold>

    protected void setImageUrlInner(String url, String placeHolder) {
        getView().setImageUrlWithPlaceHolder(url, placeHolder);
    }

    @Override
    public void padding(double l, double t, double r, double b) {
        ErrorUtils.debugUnsupportError("ImageView not support padding");
    }

    @LuaApiUsed
    public void setNineImage(String url) {
        ((LuaImageView) getView()).setImageUrlEmpty();
        view.setImageDrawable(null);//.9图和image只有一个生效。与IOS同步
        stopAnimationImages();//停止图片轮播动画
        final ImageProvider provider = MLSAdapterContainer.getImageProvider();
        Drawable d = provider.loadProjectImage(getContext(), url);
        if (d != null) {
            view.setImageDrawable(d);
        }
    }

    public void callback(boolean success, String url, String msg) {
        if (imageLoadCallback == null)
            return;
        imageLoadCallback.invoke(LuaValue.varargsOf(LuaBoolean.valueOf(success),
                LuaString.valueOf(msg), LuaString.valueOf(url)));
    }

    public boolean hasCallback() {
        return imageLoadCallback != null;
    }

    private String getTaskTag() {
        return hashCode() + TAG;
    }

}