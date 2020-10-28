/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

import android.widget.ImageView;

import com.immomo.mls.fun.constants.ContentMode;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ui.ILuaImageView;
import com.immomo.mls.fun.ui.LuaImageView;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.utils.convert.ConvertUtils;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.DisposableIterator;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed
public class UDImageView<I extends ImageView & ILuaImageView> extends UDView<I> {

    public static final String LUA_CLASS_NAME = "ImageView";

    public static final String[] methods = {
            "image",
            "contentMode",
            "lazyLoad",
            "setImageUrl",
            "setImageWithCallback",
            "borderWidth",
            "padding",
            "setCornerImage",
            "startAnimationImages",
            "stopAnimationImages",
            "isAnimating",
            "blurImage",
            "addShadow"
    };

    private static final String TAG = UDImageView.class.getSimpleName();

    private LuaFunction imageLoadCallback;

    @LuaApiUsed
    public UDImageView(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected I newView(LuaValue[] init) {
        return (I) new LuaImageView(getContext(), this, init);
    }

    //<editor-fold desc="API">
    //<editor-fold desc="Property">
    @LuaApiUsed
    public LuaValue[] image(LuaValue[] var) {
        if (var.length == 1) {
            cleanNineImage();
            final String url = var[0].toJavaString();
            setImage(url);
            return null;
        }
        String i = getImage();
        if (i != null)
            return varargsOf(LuaString.valueOf(i));
        return rNil();
    }

    @Override
    public LuaValue[] setNineImage(LuaValue[] var) {
        LuaValue[] luaValues = super.setNineImage(var);
        ((LuaImageView) getView()).setImageUrlEmpty();
        return luaValues;
    }

    @LuaApiUsed
    public LuaValue[] contentMode(LuaValue[] var) {
        if (var.length == 1) {
            if (var[0].isNil()) {
                ErrorUtils.debugUnsupportError("contentMode is nil. You must use 'ContentMode.XXXX'");
                return null;
            }
            int type = var[0].toInt();
            if (type == ContentMode.CENTER) {
                ErrorUtils.debugDeprecatedMethod("ContentMode.CENTER is deprecated", globals);
            }
            getView().setScaleType(ImageView.ScaleType.values()[type]);
            return null;
        }
        return varargsOf(LuaNumber.valueOf(getView().getScaleType().ordinal()));
    }

    @LuaApiUsed
    public LuaValue[] lazyLoad(LuaValue[] var) {
        if (var.length == 1) {
            getView().setLazyLoad(var[0].toBoolean());
            return null;
        }
        return getView().isLazyLoad() ? varargsOf(LuaBoolean.True()) : varargsOf(LuaBoolean.False());
    }

    @LuaApiUsed
    public LuaValue[] setImageUrl(LuaValue[] var) {
        cleanNineImage();
        String url = var.length > 0 && !var[0].isNil() ? var[0].toJavaString() : null;
        String placeHolder = var.length > 1 && !var[1].isNil() ? var[1].toJavaString() : null;

        setImageUrl(url,
                placeHolder);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setImageWithCallback(LuaValue[] var) {
        String url = var.length > 0 && !var[0].isNil() ? var[0].toJavaString() : null;
        String placeHolder = var.length > 1 && !var[1].isNil() ? var[1].toJavaString() : null;
        imageLoadCallback = var.length > 2 && !var[2].isNil() ? var[2].toLuaFunction() : null;

        setImageUrl(url, placeHolder);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] blurImage(LuaValue[] var) {
        //ios新增参数2，Android不处理
        if (var.length > 0 && !var[0].isNil()) {

            float blurValue = (float) var[0].toDouble();
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
                    return null;
                }

                getView().setBlurImage(blurValue);
            }

            return null;
        }

        return null;
    }

    @Override
    public LuaValue[] addShadow(LuaValue[] var) {
        ErrorUtils.debugUnsupportError("ImageView 不支持 addShadow()。");
        return null;
    }

    protected void setImageUrl(String url, String placeHolder) {
        getView().setImageUrlWithPlaceHolder(url, placeHolder);
    }

    @LuaApiUsed
    public LuaValue[] borderWidth(LuaValue[] width) {
        return super.borderWidth(varargsOf(LuaNumber.valueOf((float) width[0].toDouble())));
    }

    @LuaApiUsed
    public LuaValue[] padding(LuaValue[] width) {
        ErrorUtils.debugUnsupportError("ImageView not support padding");
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setCornerImage(LuaValue[] var) {
        cleanNineImage();

        String url = var[0].toJavaString();
        String placeHolder = var[1].toJavaString();
        float radius = (float) var[2].toDouble();

        if (var.length == 5) {
            setCornerRadiusWithDirection(radius, var[4].toInt());
        } else {
            setCornerRadius(DimenUtil.dpiToPx(radius));
        }

        ((LuaImageView) getView()).setImageUrlEmpty();
        setImageUrl(url, placeHolder);
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public LuaValue[] startAnimationImages(LuaValue[] values) {
        // LuaValue value, float d, boolean repeat
        cleanNineImage();
        LuaValue value = values[0];
        float d = (float) values[1].toDouble();
        boolean repeat = values[2].toBoolean();

        List list = null;
        if (value instanceof LuaTable) {
            list = toList((LuaTable) value);
        } else if (value instanceof UDArray) {
            list = ((UDArray) value).getArray();
        }

        if (list == null || list.isEmpty())
            return null;
        long duration = (long) (d * 1000);
        getView().startAnimImages(list, duration, repeat);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] stopAnimationImages(LuaValue[] v) {
        getView().stop();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] isAnimating(LuaValue[] v) {
        return varargsOf(LuaBoolean.valueOf(getView().isRunning()));
    }
    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="public">
    public void setImage(String url) {
        getView().setImage(url);
    }

    public String getImage() {
        return getView().getImage();
    }
    //</editor-fold>


    @Override
    public void setBgDrawable(String src) {
        super.setBgDrawable(src);
        getView().setImageDrawable(null);//.9图和image只有一个生效。与IOS同步
        stopAnimationImages(null);//停止图片轮播动画
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