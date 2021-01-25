/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Point;
import android.os.Build;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Display;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * 获取系统一些属性
 *
 * @author song
 * @date 15/9/8
 */
public class AndroidUtil {

    /**
     * 获取可用的内存大小(in k)
     *
     * @param context
     * @return
     */
    public static Long getAvailMemorySize(Context context) {
        ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        activityManager.getMemoryInfo(mi);
        return mi != null ? mi.availMem : null;
    }

    /**
     * 获取所有的内存大小(in k)
     *
     * @param context
     * @return
     */
    @TargetApi(16)
    public static Long getTotalMemorySize(Context context) {
        ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        activityManager.getMemoryInfo(mi);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            return mi != null ? mi.totalMem : null;
        } else {
            return null;
        }
    }

    /**
     * 系统版本号
     *
     * @return
     */
    public static String getOsVersion() {
        return Build.VERSION.RELEASE;
    }

    /**
     * 系统版本号
     *
     * @return
     */
    public static String getSdkVersion() {
        return Build.VERSION.SDK;
    }

    /**
     * 系统版本号(int)
     *
     * @return
     */
    public static int getSdkVersionInt() {
        return Build.VERSION.SDK_INT;
    }

    /**
     * 手机型号
     *
     * @return
     */
    public static String getOsModel() {
        return Build.MODEL;
    }

    /**
     * 系统品牌
     *
     * @return
     */
    public static String getBrand() {
        return Build.BRAND;
    }

    public static String getProduct() {
        return Build.PRODUCT;
    }

    public static String getDevice() {
        return Build.DEVICE;
    }

    public static String getManufacturer() {
        return Build.MANUFACTURER;
    }

    /**
     * get density of screen
     *
     * @param context Context
     * @return
     */
    public static float getDensity(Context context) {
        return context.getApplicationContext().getResources().getDisplayMetrics().density;
    }

    public static float getScaleDensity(Context context) {
        return context.getApplicationContext().getResources().getDisplayMetrics().scaledDensity;
    }

    /**
     * get screen width
     *
     * @param context Context
     * @return
     */
    public static int getScreenWidth(Context context) {
        return context.getApplicationContext().getResources().getDisplayMetrics().widthPixels;
    }


    /**
     * get screen width
     *
     * @param context Context
     * @return
     */
    public static int getScreenWidthInDp(Context context) {
        return (int) DimenUtil.pxToDpi(context.getApplicationContext().getResources().getDisplayMetrics().widthPixels);
    }

    /**
     * get screen height
     *
     * @param context Context
     * @return
     */
    public static int getScreenHeight(Context context) {
        return context.getApplicationContext().getResources().getDisplayMetrics().heightPixels;
    }

    /**
     * get screen height
     *
     * @param context Context
     * @return
     */
    public static int getScreenHeightInDp(Context context) {
        return (int) DimenUtil.pxToDpi(context.getApplicationContext().getResources().getDisplayMetrics().heightPixels);
    }

    /**
     * 获取屏幕尺寸
     *
     * @param context
     * @return
     */
    public static int[] getScreenSize(Context context) {
        final DisplayMetrics displayMetrics = context.getApplicationContext().getResources().getDisplayMetrics();
        return new int[]{displayMetrics.widthPixels, displayMetrics.heightPixels};
    }

    public static int[] getScreenSizeInDp(Context context) {
        final int[] size = getScreenSize(context);
        return new int[]{(int) DimenUtil.pxToDpi(size[0]), (int) DimenUtil.pxToDpi(size[1])};
    }

    /**
     * 获取window的size
     *
     * @param context
     * @return
     */
    public static int[] getWindowSize(Context context) {
        final WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        final Display display = wm.getDefaultDisplay();
        if (android.os.Build.VERSION.SDK_INT >= 13) {
            Point point = new Point();
            display.getSize(point);
            return new int[]{point.x, point.y};
        } else {
            return new int[]{display.getWidth(), display.getHeight()};
        }
    }

    /**
     * 获取window的size
     *
     * @param context
     * @return
     */
    public static int[] getWindowSizeInDp(Context context) {
        final int[] size = getWindowSize(context);
        return new int[]{(int) DimenUtil.pxToDpi(size[0]), (int) DimenUtil.pxToDpi(size[1])};
    }


    /**
     * get action bar height
     *
     * @param context
     * @return
     */
    public static int getActionBarHeight(Context context) {
        int actionBarHeight = 0;
        if (context instanceof Activity && ((Activity) context).getActionBar() != null) {
            actionBarHeight = ((Activity) context).getActionBar().getHeight();
        }

        if (actionBarHeight == 0) {
            final TypedValue tv = new TypedValue();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB && (context.getTheme() != null && context.getTheme().resolveAttribute(android.R.attr.actionBarSize, tv, true))) {
                actionBarHeight = TypedValue.complexToDimensionPixelSize(tv.data, context.getResources().getDisplayMetrics());
            }
        }
        return actionBarHeight;
    }

    /**
     * get actionbar height
     *
     * @param context
     * @return
     */
    public static int getActionBarHeightInDp(Context context) {
        return (int) DimenUtil.pxToDpi(getActionBarHeight(context));
    }


    /**
     * 获取系统的Navigation bar height
     * 虚拟按键
     *
     * @param context
     * @return
     */
    public static int getNavigationBarHeightInDp(Context context) {
        int size = getNavigationBarHeight(context);
        return (int) DimenUtil.pxToDpi(size);
    }

    private static int navigationBarHeight;
    private static boolean navigationBarInit = false;

    public static int getNavigationBarHeight(Context context) {
        if (navigationBarInit) {
            return navigationBarHeight;
        }
        navigationBarInit = true;
        Point appUsableSize = getAppUsableScreenSize(context);
        Point realScreenSize = getRealScreenSize(context);

        // navigation bar on the right
        if (appUsableSize.x < realScreenSize.x) {
            navigationBarHeight = realScreenSize.x - appUsableSize.x;
            return navigationBarHeight;
        }

        // navigation bar at the bottom
        if (appUsableSize.y < realScreenSize.y) {
            navigationBarHeight = realScreenSize.y - appUsableSize.y;
            return navigationBarHeight;
        }

        // navigation bar is not present
        return 0;
    }

    private static Point getAppUsableScreenSize(Context context) {
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = windowManager.getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        return size;
    }

    private static Point getRealScreenSize(Context context) {
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = windowManager.getDefaultDisplay();
        Point size = new Point();

        if (Build.VERSION.SDK_INT >= 17) {
            display.getRealSize(size);
        } else if (Build.VERSION.SDK_INT >= 14) {
            try {
                size.x = (Integer) Display.class.getMethod("getRawWidth").invoke(display);
                size.y = (Integer) Display.class.getMethod("getRawHeight").invoke(display);
            } catch (IllegalAccessException e) {
            } catch (InvocationTargetException e) {
            } catch (NoSuchMethodException e) {
            }
        }
        return size;
    }

    /**
     * get status bar height in dp
     * 电池栏高度
     *
     * @param context
     * @return
     */
    public static int getStatusBarHeightInDp(Context context) {
        return (int) DimenUtil.pxToDpi(getStatusBarHeight(context));
    }

    private static int statusBarHeight = 0;
    private static boolean statusBarInit = false;

    public static int getStatusBarHeight(Context context) {
        if (statusBarInit)
            return statusBarHeight;
        statusBarInit = true;
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            statusBarHeight = context.getResources().getDimensionPixelSize(resourceId);
        }
        return statusBarHeight;
    }

    public static int getLocalVersion(Context ctx) {
        try {
            PackageInfo packageInfo = ctx.getApplicationContext()
                    .getPackageManager()
                    .getPackageInfo(ctx.getPackageName(), 0);
            return packageInfo.versionCode;
        } catch (PackageManager.NameNotFoundException e) {
        }
        return -1;
    }

    public static boolean isFullScreen(Activity activity) {
        int flag = activity.getWindow().getAttributes().flags;
        return (flag & WindowManager.LayoutParams.FLAG_FULLSCREEN)
                == WindowManager.LayoutParams.FLAG_FULLSCREEN;
    }

    public static boolean isFullScreen(View rootView) {
        int[] out = new int[2];
        rootView.getLocationOnScreen(out);
        return out[1] == 0;
    }

    public static void switchFullscreen(Activity activity, boolean isFullscreen) {
        Window window = activity.getWindow();
        if (isFullscreen) {
            WindowManager.LayoutParams attrs = window.getAttributes();
            attrs.flags |= WindowManager.LayoutParams.FLAG_FULLSCREEN;

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                attrs.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            }
            window.setAttributes(attrs);

            int sysUiVisibility = window.getDecorView().getSystemUiVisibility();
            sysUiVisibility |= (View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
            window.getDecorView().setSystemUiVisibility(sysUiVisibility);
        } else {
            // go non-full screen
            WindowManager.LayoutParams attrs = window.getAttributes();
            attrs.flags &= (~WindowManager.LayoutParams.FLAG_FULLSCREEN);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                attrs.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT;
            }
            window.setAttributes(attrs);

            int sysUiVisibility = window.getDecorView().getSystemUiVisibility();
            sysUiVisibility &= ~(View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
            window.getDecorView().setSystemUiVisibility(sysUiVisibility);
        }
    }

    @Deprecated
    public static void setStatusBarColor(Activity activity, int color) {
        Window window = activity.getWindow();
        if (window == null)
            return;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.setStatusBarColor(color);
            if (Color.alpha(color) < 255) {//沉浸式
                View decor = window.getDecorView();
                if (decor != null) {
                    decor.setSystemUiVisibility(
                            View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
                }
            }
        }
    }

    public static int getStatusColor(Activity activity) {
        Window window = activity.getWindow();
        if (window == null)
            return -1;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            return window.getStatusBarColor();
        }
        return -1;
    }

    public static void setStatusColor(Activity activity, int color) {
        Window window = activity.getWindow();
        if (window == null)
            return;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.setStatusBarColor(color);
        }
    }

    public static void setTranslucent(Activity activity) {
        Window window = activity.getWindow();
        if (window == null)
            return;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
        }
    }

    public static boolean isLayoutStable(Activity activity) {//判断沉浸式，依据
        Window window = activity.getWindow();
        if (window == null) {
            return false;
        }
        View decor = window.getDecorView();
        if (decor != null) {
            int flag = decor.getSystemUiVisibility();
            return (flag & (View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN))
                    == (View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
        }
        return false;
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public static void showLightStatusBar(boolean light, Activity activity) {
        if (activity == null || Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT) {
            return;
        }

        if (isMIUI() && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            boolean processed;
            if (light) {
                processed = setMiuiStatusBarDarkMode(activity, false);
            } else {
                processed = setMiuiStatusBarDarkMode(activity, true);
            }
            if (processed) {
                return;
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            View decorView = activity.getWindow().getDecorView();
            if (decorView != null) {
                int vis = decorView.getSystemUiVisibility();
                if (light) {
                    vis &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
                } else {
                    vis |= View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
                }
                decorView.setSystemUiVisibility(vis);
            }
        }
    }

    /**
     * 根据MIUI官方提供的方法设置状态栏的颜色，支持 light和dark两种模式
     *
     * @param activity
     * @param darkmode
     * @return
     */
    public static boolean setMiuiStatusBarDarkMode(Activity activity, boolean darkmode) {
        if (!isMIUI() || Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return false;
        }
        Class<? extends Window> clazz = activity.getWindow().getClass();
        try {
            int darkModeFlag = 0;
            Class<?> layoutParams = Class.forName("android.view.MiuiWindowManager$LayoutParams");
            Field field = layoutParams.getField("EXTRA_FLAG_STATUS_BAR_DARK_MODE");
            darkModeFlag = field.getInt(layoutParams);
            Method extraFlagField = clazz.getMethod("setExtraFlags", int.class, int.class);
            extraFlagField.invoke(activity.getWindow(), darkmode ? darkModeFlag : 0, darkModeFlag);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 检测发现，使用 properties 去读取MIUI信息的方法已经失效了，直接读取 manufacgturer对比
     *
     * @return
     */
    public static boolean isMIUI() {
        return Build.MANUFACTURER.equalsIgnoreCase("xiaomi");
    }
}