/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.constants.MeasurementType;
import com.immomo.mls.fun.other.Rect;
import com.immomo.mls.fun.ud.view.UDBaseHVStack;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.ud.view.recycler.UDCollectionLayout;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.GravityUtils;
import com.immomo.mls.util.LuaViewUtil;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function2;
import org.luaj.vm2.Globals;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019/3/1
 * Time         :   下午2:31
 * Description  :
 */

@LuaApiUsed(ignore = true)
public class UDWindowManager extends JavaUserdata {
    public static final String LUA_CLASS_NAME = "ContentWindow";
    public static final String[] methods = new String[]{
            "cancelable",
            "width",
            "height",
            "x",
            "y",
            "alpha",
            "addView",
            "setContent",
            "removeAllSubviews",
            "canEndEditing",
            "show",
            "windowLevel",
            "onTouch",
            "bgColor",
            "dismiss",
            "contentWindowDisAppear",
            "marginTop",
            "marginLeft",
            "setGravity"
    };

    private WindowManager mWindowManager;

    private FrameLayout mContentFrameLayout;
    private Integer mBackGroundUDColor;

    private LuaFunction mDismissFunction;
    private LuaFunction mOnTouchFunction;

    private boolean cancelable = false;

    private boolean isFirstAddView = true;

    private float width, height;
    private int mXPoint = 0 , mYPoint= 0;
    private float mAlpha = -1;

    private int mGravity = Gravity.TOP | Gravity.LEFT;

    WindowManager.LayoutParams lp;

    @LuaApiUsed(@LuaApiUsed.Func(params = {
            @LuaApiUsed.Type(value = Rect.class)
    }, returns = @LuaApiUsed.Type(value = UDWindowManager.class)))
    protected UDWindowManager(long L, LuaValue[] initParams) {
        super(L, initParams);
        if (initParams != null) {
            if (initParams.length >= 1) {
                UDRect udRect = (UDRect) initParams[0];
                Rect initRect = udRect.getRect();

                this.width = initRect.getSize().getWidthPx();
                this.height = initRect.getSize().getHeightPx();

                this.mXPoint = (int) initRect.getPoint().getXPx();
                this.mYPoint = (int) initRect.getPoint().getYPx();
                udRect.destroy();
            }
        }

        mWindowManager = (WindowManager) MLSEngine.getContext().getSystemService(Context.WINDOW_SERVICE);
        initWindowParams(MLSEngine.getContext());
    }

    public UDWindowManager(Globals g, Object jud) {
        super(g, jud);
    }

    protected Context getContext() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDWindowManager.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] cancelable(LuaValue[] p) {
        if (p.length == 1) {
            this.cancelable = p[0].toBoolean();
            return null;
        }
        return cancelable ? rTrue() : rFalse();
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Double.class)
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] width(LuaValue[] p) {
        float width = (float) p[0].toDouble();
        if (width == MeasurementType.MATCH_PARENT || width == MeasurementType.WRAP_CONTENT) {
            this.width = width;
            return null;
        }

        int w = DimenUtil.dpiToPx(width);
        this.width = DimenUtil.check(w);
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Double.class)
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] height(LuaValue[] p) {
        float height = (float) p[0].toDouble();
        if (height == MeasurementType.MATCH_PARENT || height == MeasurementType.WRAP_CONTENT) {
            this.height = height;
            return null;
        }

        int h = DimenUtil.dpiToPx(height);
        this.height = DimenUtil.check(h);
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDWindowManager.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class)),
    })
    public LuaValue[] x(LuaValue[] p) {
        if (p.length == 1) {
            mXPoint = DimenUtil.dpiToPx((float) p[0].toDouble());

            if (lp != null)
                lp.x = mXPoint;

            return null;
        }
        return rNumber(DimenUtil.pxToDpi(mXPoint));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDWindowManager.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class)),
    })
    public LuaValue[] marginTop(LuaValue[] var) {
        if (var.length == 1) {
            mYPoint = DimenUtil.dpiToPx((float) var[0].toDouble());
            if (lp != null)
                lp.y = mYPoint;
            return null;
        }
        return rNumber(DimenUtil.pxToDpi(mYPoint));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDWindowManager.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class)),
    })
    public LuaValue[] marginLeft(LuaValue[] var) {
        if (var.length == 1) {
            mXPoint = DimenUtil.dpiToPx((float) var[0].toDouble());

            if (lp != null)
                lp.x = mXPoint;

            return null;
        }
        return rNumber(DimenUtil.pxToDpi(mXPoint));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDWindowManager.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class)),
    })
    public LuaValue[] setGravity(LuaValue[] var) {
        mGravity = var[0].toInt();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDWindowManager.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class)),
    })
    public LuaValue[] y(LuaValue[] p) {
        if (p.length == 1) {
            mYPoint = DimenUtil.dpiToPx((float) p[0].toDouble());
            if (lp != null)
                lp.y = mYPoint;
            return null;
        }
        return rNumber(DimenUtil.pxToDpi(mYPoint));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDWindowManager.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class)),
    })
    public LuaValue[] alpha(LuaValue[] p) {
        if (p.length != 0) {
            mAlpha = (float) p[0].toDouble();
        }
        return rNumber(mAlpha);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDView.class)
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] addView(LuaValue[] p) {

        if (mContentFrameLayout == null)
            mContentFrameLayout = new FrameLayout(getContext());

        mContentFrameLayout.addView(LuaViewUtil.removeFromParent(((UDView) p[0]).getView()));
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDView.class)
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] setContent(LuaValue[] p) {
        UDView subView = (UDView) p[0];

        if (mContentFrameLayout == null)
            mContentFrameLayout = new FrameLayout(getContext());

        mContentFrameLayout.removeAllViews();

        mGravity = subView.udLayoutParams.gravity;

        setContentWidthHeight(subView);

        mContentFrameLayout.addView(LuaViewUtil.removeFromParent(subView.getView()));
        return null;
    }

    private void setContentWidthHeight(UDView subView) {
        ViewGroup.LayoutParams params = subView.getView().getLayoutParams();
        if (params != null) {
            this.width = params.width;
            this.height = params.height;
        }
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] removeAllSubviews(LuaValue[] p) {
        if (mContentFrameLayout == null)
            return null;

        mContentFrameLayout.removeAllViews();
        return null;
    }

    @LuaApiUsed(ignore = true)
    public LuaValue[] canEndEditing(LuaValue[] p) {
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] show(LuaValue[] p) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Settings.canDrawOverlays(getContext())) {
            if (isFirstAddView)
                addDefaultFrameLayout();

        } else
            requestPermission(getContext());
        return null;
    }

    @LuaApiUsed(ignore = true)
    public LuaValue[] windowLevel(LuaValue[] p) {
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function2.class, typeArgs = {
                            Float.class, Float.class, Unit.class
                    })
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] onTouch(LuaValue[] p) {
        if (mOnTouchFunction != null)
            mOnTouchFunction.destroy();
        this.mOnTouchFunction = p[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] bgColor(LuaValue[] p) {
        mBackGroundUDColor = ((UDColor) p[0]).getColor();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] dismiss(LuaValue[] p) {
        dismiss();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function0.class, typeArgs = {
                            Unit.class
                    })
            }, returns = @LuaApiUsed.Type(UDWindowManager.class))
    })
    public LuaValue[] contentWindowDisAppear(LuaValue[] p) {
        if (mDismissFunction != null)
            mDismissFunction.destroy();
        mDismissFunction = p[0].toLuaFunction();
        return null;
    }

    private void dismiss() {
        try {
            mWindowManager.removeView(mContentFrameLayout);
        } catch (Exception e) {

        }

        if (mDismissFunction != null)
            mDismissFunction.invoke(null);

        isFirstAddView = true;
    }

    private void addDefaultFrameLayout() {
        Context context = getContext();

        if (context == null)
            return;

        if (this.width == 0)
            this.width = AndroidUtil.getScreenWidth(context);

        if (this.height == 0)
            this.height = AndroidUtil.getScreenHeight(context);

        lp.width = (int) this.width;
        lp.height = (int) this.height;

        if (mBackGroundUDColor != null) {
            mContentFrameLayout.setBackgroundColor(mBackGroundUDColor);
        }

        if (mAlpha >= 0 && mAlpha <= 1)
            mContentFrameLayout.setAlpha(mAlpha);

        mContentFrameLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (cancelable)
                    dismiss();
            }
        });

        mContentFrameLayout.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                float xdp = DimenUtil.pxToDpi(event.getX());
                float ydp = DimenUtil.pxToDpi(event.getY());

                if (mOnTouchFunction != null)
                    mOnTouchFunction.invoke(varargsOf(LuaNumber.valueOf(xdp), LuaNumber.valueOf(ydp)));
                return false;
            }
        });

        mContentFrameLayout.setLayoutParams(lp);

        try {
            mWindowManager.addView(LuaViewUtil.removeFromParent(mContentFrameLayout), lp);
        } catch (Exception e) {

        }

        isFirstAddView = false;
    }

    private void initWindowParams(Context context) {
        lp = new WindowManager.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, 0, 0,
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                        WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                WindowManager.LayoutParams.FLAG_FULLSCREEN
                        | WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
                        | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
                        | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
                PixelFormat.TRANSLUCENT);


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            lp.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) { /*android7.0不能用TYPE_TOAST*/
            lp.type = WindowManager.LayoutParams.TYPE_PHONE;
        } else { /*以下代码块使得android6.0之后的用户不必再去手动开启悬浮窗权限*/
            String packname = context.getPackageName();
            PackageManager pm = context.getPackageManager();
            boolean permission = (PackageManager.PERMISSION_GRANTED == pm.checkPermission("android.permission.SYSTEM_ALERT_WINDOW", packname));
            if (permission) {
                lp.type = WindowManager.LayoutParams.TYPE_PHONE;
            } else {
                lp.type = WindowManager.LayoutParams.TYPE_TOAST;
            }
        }

        lp.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON | WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED;
        lp.format = PixelFormat.RGBA_8888;

        lp.gravity = mGravity;
    }

    private void requestPermission(Context context) {
        Intent intent = new Intent();
        intent.setAction(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
        intent.setData(Uri.parse("package:" + context.getPackageName()));
        context.startActivity(intent);
    }

    @Override
    public String toString() {
        return "ContentWindow#(" + hashCode() + ") "
                + "w:" + width + " h:" + height + " x:" + mXPoint + " y:" + mYPoint
                + " alpha:" + mAlpha + " cancelable:" + cancelable
                + " gravity:" + GravityUtils.toString(mGravity);
    }
}