/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.utils;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.graphics.Point;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;

import com.immomo.mls.MLSConfigs;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;

/**
 * Created by zhang.ke
 * on 2018/12/11
 */
public class KeyboardUtil {

    private static int MIN_KEYBOARD_HEIGHT = 0;

    /**
     * Recommend invoked by {@link Activity#onCreate(Bundle)}
     * For align the height of the keyboard to {@code target} as much as possible.
     * For save the refresh the keyboard height to shared-preferences.
     *
     * @param container contain the view
     * @param listener  the listener to listen in: keyboard is showing or not.
     */
    public static ViewTreeObserver.OnGlobalLayoutListener attach(final ViewGroup container,
                                                                 /** Nullable **/OnKeyboardShowingListener listener) {
        Context context = container.getContext();
        final boolean isFullScreen = KeyboardViewUtil.isFullScreen(context);
        final boolean isTranslucentStatus = KeyboardViewUtil.isTranslucentStatus(context);
        final boolean isFitSystemWindows = KeyboardViewUtil.isFitsSystemWindows(context);
        final boolean isSystemUiVisibilityFullScreen = KeyboardViewUtil.isSystemUiVisibilityFullScreen(context);

        final int screenHeight;
        ViewGroup contentView;
        if (context instanceof Activity) {
            Activity activity = ((Activity) context);
            contentView = activity.findViewById(android.R.id.content);
            Display display = activity.getWindowManager().getDefaultDisplay();
            final Point screenSize = new Point();
            display.getSize(screenSize);
            screenHeight = screenSize.y;
        } else {
            contentView = container.getParent() == null ? container : (ViewGroup) container.getParent();
            screenHeight = container.getParent() == null ? container.getHeight() : ((ViewGroup) container.getParent()).getHeight();
        }

        ViewTreeObserver.OnGlobalLayoutListener globalLayoutListener = null;
        if (contentView != null) {
            globalLayoutListener = new KeyboardStatusListener(
                    isFullScreen,
                    isTranslucentStatus,
                    isFitSystemWindows,
                    isSystemUiVisibilityFullScreen,
                    contentView,
                    listener,
                    screenHeight);

            contentView.getViewTreeObserver().addOnGlobalLayoutListener(globalLayoutListener);
        }
        return globalLayoutListener;
    }


    /**
     * @see #attach(ViewGroup, OnKeyboardShowingListener)
     */
    public static ViewTreeObserver.OnGlobalLayoutListener attach(final ViewGroup contentView) {
        return attach(contentView, null);
    }

    /**
     * Remove the OnGlobalLayoutListener from the activity root view
     *
     * @param l ViewTreeObserver.OnGlobalLayoutListener returned by {@link #attach} method
     */
    public static void detach(ViewGroup contentView, ViewTreeObserver.OnGlobalLayoutListener l) {
        contentView.getViewTreeObserver().removeOnGlobalLayoutListener(l);
    }

    private static class KeyboardStatusListener implements ViewTreeObserver.OnGlobalLayoutListener {
        private final static String TAG = "KeyboardStatusListener";

        private int previousDisplayHeight = 0;
        private final ViewGroup contentView;
        private final boolean isFullScreen;
        private final boolean isTranslucentStatus;
        private final boolean isFitSystemWindows;
        private final boolean isSystemUiVisibilityFullScreen;
        private int statusBarHeight;
        private boolean lastKeyboardShowing;
        private final OnKeyboardShowingListener keyboardShowingListener;
        private int screenHeight;
        private boolean isDisplayHeightContainsStatusBar = false;
        private boolean isInit = false;

        KeyboardStatusListener(boolean isFullScreen, boolean isTranslucentStatus,
                               boolean isFitSystemWindows, boolean isSystemUiVisibilityFullScreen,
                               ViewGroup contentView,
                               OnKeyboardShowingListener listener, int screenHeight) {
            this.contentView = contentView;
            this.isFullScreen = isFullScreen;
            this.isTranslucentStatus = isTranslucentStatus;
            this.isFitSystemWindows = isFitSystemWindows;
            this.isSystemUiVisibilityFullScreen = isSystemUiVisibilityFullScreen;
            this.statusBarHeight = stateBarHeight(contentView.getContext());
            this.keyboardShowingListener = listener;
            this.screenHeight = screenHeight;
        }

        @Override
        public void onGlobalLayout() {
            final View userRootView = contentView.getChildAt(0);
            final View contentParentView = (View) contentView.getParent();
            if (!isInit) {
                this.statusBarHeight = stateBarHeight(contentView.getContext());
                isInit = true;
            }
            // Step 1. calculate the current display frame's height.
            Rect r = new Rect();

            final int displayHeight;

            /**
             * 发现，在 translucentStatus情况下，不 fitsSystemWindows，键盘高度会偏小，正好小于状态栏高度
             */
            if (isTranslucentStatus) {
                contentParentView.getWindowVisibleDisplayFrame(r);
                int overlayDisplayHeight = r.bottom - r.top;
                if (!isDisplayHeightContainsStatusBar) {
                    isDisplayHeightContainsStatusBar = overlayDisplayHeight == screenHeight;
                }
                if (!isDisplayHeightContainsStatusBar) {
                    displayHeight = overlayDisplayHeight + statusBarHeight;
                } else {
                    displayHeight = overlayDisplayHeight;
                }

            } else if (userRootView != null) {
                userRootView.getWindowVisibleDisplayFrame(r);
                displayHeight = (r.bottom - r.top);
            } else {
                contentView.getWindowVisibleDisplayFrame(r);
                displayHeight = (r.bottom - r.top);
            }

            int keyboardHeight = calculateKeyboardHeight(displayHeight);
            calculateKeyboardShowing(displayHeight, keyboardHeight);

            previousDisplayHeight = displayHeight;
        }

        private int calculateKeyboardHeight(final int displayHeight) {
            // first result.
            if (previousDisplayHeight == 0) {
                previousDisplayHeight = displayHeight;

                return displayHeight;
            }

            int keyboardHeight = 0;
            if (isHandleByPlaceholder(isFullScreen, isTranslucentStatus, isFitSystemWindows, false)) {

                // the height of content parent = contentView.height + actionBar.height
                final View actionBarOverlayLayout = (View) contentView.getParent();

                keyboardHeight = actionBarOverlayLayout.getHeight() - displayHeight;
            } else if (isSystemUiVisibilityFullScreen) {
                // 处理设置SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN flag情况  修复键盘高度bug
                // the height of content parent = contentView.height + actionBar.height
                final View actionBarOverlayLayout = (View) contentView.getParent();

                keyboardHeight = actionBarOverlayLayout.getHeight() - displayHeight;
                keyboardHeight -= statusBarHeight;
            } else {
                keyboardHeight = Math.abs(displayHeight - previousDisplayHeight);
            }
            return keyboardHeight;
        }
//
//        private void resetStatusBarHeight(int keyboardHeight) {
//            if (isReset)
//                return;
//            statusBarHeight += keyboardHeight;
//            isReset = true;
//        }

        private int maxOverlayLayoutHeight;

        private void calculateKeyboardShowing(final int displayHeight, final int keyboardHeight) {

            boolean isKeyboardShowing;

            // the height of content parent = contentView.height + actionBar.height
            final View actionBarOverlayLayout = (View) contentView.getParent();
            // in the case of FragmentLayout, this is not real ActionBarOverlayLayout, it is
            // LinearLayout, and is a child of DecorView, and in this case, its top-padding would be
            // equal to the height of status bar, and its height would equal to DecorViewHeight -
            // NavigationBarHeight.
            final int actionBarOverlayLayoutHeight = actionBarOverlayLayout.getHeight() -
                    actionBarOverlayLayout.getPaddingTop();
            /**
             * 由于增加了 {@link KeyboardViewUtil.isUiVisibilityFullscreen()} 为true时的处理
             * 此处需要对此情况进行处理
             */
            if (isHandleByPlaceholder(isFullScreen, isTranslucentStatus, isFitSystemWindows, isSystemUiVisibilityFullScreen)) {
                if (!isSystemUiVisibilityFullScreen && !isTranslucentStatus &&
                        actionBarOverlayLayoutHeight - displayHeight == this.statusBarHeight) {
                    // handle the case of status bar layout, not keyboard active.
                    isKeyboardShowing = lastKeyboardShowing;
                } else {
                    if (isSystemUiVisibilityFullScreen) {
                        isKeyboardShowing = actionBarOverlayLayoutHeight > (displayHeight + statusBarHeight);
                    } else {
                        isKeyboardShowing = actionBarOverlayLayoutHeight > displayHeight;
                    }
                }
            } else {

                /*
                final int phoneDisplayHeight = contentView.getResources().getDisplayMetrics().heightPixels;

                if (!isTranslucentStatus &&
                        phoneDisplayHeight == actionBarOverlayLayoutHeight) {
                    // no space to settle down the status bar, switch to fullscreen,
                    // only in the case of paused and opened the fullscreen page.
                    Log.w(TAG, String.format("skip the keyboard status calculate, the current" +
                                    " activity is paused. and phone-display-height %d," +
                                    " root-height+actionbar-height %d", phoneDisplayHeight,
                            actionBarOverlayLayoutHeight));
                    return;

                }*/

                if (maxOverlayLayoutHeight == 0) {
                    // non-used.
                    isKeyboardShowing = lastKeyboardShowing;
                } else if (displayHeight >= maxOverlayLayoutHeight) {
                    isKeyboardShowing = false;
                } else {
                    isKeyboardShowing = (displayHeight < maxOverlayLayoutHeight - getMinKeyboardHeight());
                }

                maxOverlayLayoutHeight = Math.max(maxOverlayLayoutHeight, actionBarOverlayLayoutHeight);
            }

            if (lastKeyboardShowing != isKeyboardShowing) {
                Log.d(TAG, String.format("displayHeight %d actionBarOverlayLayoutHeight %d " +
                                "keyboard status change: %B",
                        displayHeight, actionBarOverlayLayoutHeight, isKeyboardShowing));
                //先注释掉调整输入框高度的逻辑，减少onGlobalLayout中的耗时操作，禅道id@64605
//                if (isKeyboardShowing && editorLayout != null) {
//                    changeEditorLayoutBottomMargin();
//                }
                if (keyboardShowingListener != null) {
                    keyboardShowingListener.onKeyboardShowing(isKeyboardShowing, keyboardHeight);
                }
            }

            lastKeyboardShowing = isKeyboardShowing;

        }

        private Context getContext() {
            return contentView.getContext();
        }
    }

    public static int stateBarHeight(Context context) {
        if (MLSConfigs.noStateBarHeight)
            return 0;
        if (context != null) {
            if (context instanceof Activity) {
                int statusBarHeight = AndroidUtil.getStatusBarHeight(context);
                int refHeight = 0;
                if (((Activity) context).getWindow() != null && ((Activity) context).getWindow().getDecorView() != null) {
                    Rect outRect1 = new Rect();
                    ((Activity) context).getWindow().getDecorView().getWindowVisibleDisplayFrame(outRect1);
                    refHeight = outRect1.top;
                }
                if (refHeight > 0 && refHeight > statusBarHeight) {
                    return refHeight;
                }
                return statusBarHeight;
            }
        }
        return 0;
    }

    public static int getMinKeyboardHeight() {
        if (MIN_KEYBOARD_HEIGHT == 0) {
            MIN_KEYBOARD_HEIGHT = DimenUtil.dpiToPx(80);
        }
        return MIN_KEYBOARD_HEIGHT;
    }


    /**
     * @param isFullScreen        Whether in fullscreen theme.
     * @param isTranslucentStatus Whether in translucent status theme.
     * @param isFitsSystem        Whether the root view(the child of the content view) is in
     *                            {@code getFitSystemWindow()} equal true.
     * @return Whether handle the conflict by show panel placeholder, otherwise, handle by delay the
     * visible or gone of panel.
     */
    public static boolean isHandleByPlaceholder(boolean isFullScreen,
                                                boolean isTranslucentStatus,
                                                boolean isFitsSystem, boolean isSystemUiVisibilityFullScreen) {
        return isFullScreen || (isTranslucentStatus && !isFitsSystem) || isSystemUiVisibilityFullScreen;
    }

    /**
     * The interface is used to listen the keyboard showing state.
     *
     * @see #attach(ViewGroup, OnKeyboardShowingListener)
     * @see KeyboardStatusListener#calculateKeyboardHeight(int)
     */
    public interface OnKeyboardShowingListener {

        /**
         * Keyboard showing state callback method.
         * <p>
         * This method is invoked in {@link ViewTreeObserver.OnGlobalLayoutListener#onGlobalLayout()} which is one of the
         * ViewTree lifecycle callback methods. So deprecating those time-consuming operation(I/O, complex calculation,
         * alloc objects, etc.) here from blocking main ui thread is recommended.
         * </p>
         *
         * @param isShowing Indicate whether keyboard is showing or not.
         */
        void onKeyboardShowing(boolean isShowing, int keyboardHeight);

    }


}
