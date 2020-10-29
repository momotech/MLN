/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.widget.ImageView;

import com.immomo.mls.fun.constants.ContentMode;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.view.IBorderRadiusView;
import com.immomo.mls.fun.ui.ILuaImageView;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mmui.ILView;
import com.immomo.mmui.ui.LuaImageView;

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
        cleanNineImage();
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
        if (type == ContentMode.CENTER) {
            ErrorUtils.debugDeprecatedMethod("ContentMode.CENTER is deprecated", globals);
        }
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
        cleanNineImage();

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
        cleanNineImage();
        setCornerRadiusWithDirection(radius, d);
        ((LuaImageView) getView()).setImageUrlEmpty();
        setImageUrlInner(url, placeHolder);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public void setCornerImage(String url, String placeHolder, float radius) {
        cleanNineImage();
        setCornerRadius(DimenUtil.dpiToPx(radius));
        ((LuaImageView) getView()).setImageUrlEmpty();
        setImageUrlInner(url, placeHolder);
        getFlexNode().dirty();
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public void startAnimationImages(LuaValue value, float d, boolean repeat) {
        // LuaValue value, float d, boolean repeat
        cleanNineImage();

        List list = null;
        if (value instanceof LuaTable) {
            list = toList((LuaTable) value);
        } else if (value instanceof UDArray) {
            list = ((UDArray) value).getArray();
        }

        if (list == null || list.isEmpty())
            return;
        long duration = (long) (d * 1000);
        getView().startAnimImages(list, duration, repeat);
    }

    @LuaApiUsed
    public void stopAnimationImages() {
        getView().stop();
    }

    @LuaApiUsed
    public boolean isAnimating() {
        return getView().isRunning();
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

    @Override
    public void setNineImage(String s) {
        super.setNineImage(s);
        ((LuaImageView) getView()).setImageUrlEmpty();
    }

    @Override
    public void setBgDrawable(String src) {
        super.setBgDrawable(src);
        getView().setImageDrawable(null);//.9图和image只有一个生效。与IOS同步
        stopAnimationImages();//停止图片轮播动画
    }

    //设置image后，清空.9图
    private void cleanNineImage() {
        hasNineImage = false;
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            view.setBgDrawable(null);
        }
    }

    private static List<String> toList(LuaTable t) {
        List<String> ret = new ArrayList<>();

        DisposableIterator<LuaTable.KV> iterator = t.iterator();
        if (iterator == null)
            return ret;
        while (iterator.hasNext()) {
            LuaTable.KV kv = iterator.next();
            ret.add(kv.value.toJavaString());
        }
        iterator.dispose();
        t.destroy();

        return ret;
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