/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.keyboard;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.graphics.Point;
import android.graphics.Rect;
import android.os.Build;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

import com.immomo.mls.MLSConfigs;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.KeyboardViewUtil;

import androidx.annotation.NonNull;

/**
 * Created by zhang.ke
 * on 2018/12/11
 */
public class MMUIKeyboardUtil {

    private static int MIN_KEYBOARD_HEIGHT = 0;


    private static int LAST_SAVE_KEYBOARD_HEIGHT = 0;

    private static boolean saveKeyboardHeight(final Context context, int keyboardHeight) {
        if (LAST_SAVE_KEYBOARD_HEIGHT == keyboardHeight) {
            return false;
        }

        if (keyboardHeight < 0) {
            return false;
        }

        LAST_SAVE_KEYBOARD_HEIGHT = keyboardHeight;

        return KeyBoardSharedPreferences.save(context, keyboardHeight);
    }

    private static int getKeyboardHeight(final Context context) {
        if (LAST_SAVE_KEYBOARD_HEIGHT == 0) {
            LAST_SAVE_KEYBOARD_HEIGHT = KeyBoardSharedPreferences.get(context, getMinKeyboardHeight());
        }

        return LAST_SAVE_KEYBOARD_HEIGHT;
    }

    /**
     * Recommend invoked by { Activity#onCreate(Bundle)}
     * For align the height of the keyboard to {@code target} as much as possible.
     * For save the refresh the keyboard height to shared-preferences.
     *
     * @param container contain the view
     * @param listener  the listener to listen in: keyboard is showing or not.
     */
    public static ViewTreeObserver.OnGlobalLayoutListener attach(final ViewGroup container,
                                                                 @NonNull OnKeyboardShowingListener listener) {
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
     * Remove the OnGlobalLayoutListener from the activity root view
     *
     * @param l ViewTreeObserver.OnGlobalLayoutListener returned by {@link #attach} method
     */
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    public static void detach(ViewGroup contentView, ViewTreeObserver.OnGlobalLayoutListener l) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            contentView.getViewTreeObserver().removeOnGlobalLayoutListener(l);
        } else {
            //noinspection deprecation
            contentView.getViewTreeObserver().removeGlobalOnLayoutListener(l);
        }
    }

    private static class KeyboardStatusListener implements ViewTreeObserver.OnGlobalLayoutListener {

        private int previousDisplayHeight = 0;
        private final ViewGroup contentView;
        private final boolean isFullScreen;
        private final boolean isTranslucentStatus;
        private final boolean isFitSystemWindows;
        private final boolean isSystemUiVisibilityFullScreen;
        private final int statusBarHeight;
        private boolean lastKeyboardShowing;
        private final OnKeyboardShowingListener keyboardShowingListener;
        private int screenHeight;
        private boolean isDisplayHeightContainsStatusBar = false;

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

            // Step 1. calculate the current display frame's height.
            Rect r = new Rect();

            final int displayHeight;

            /*
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

            calculateKeyboardHeight(displayHeight);
            calculateKeyboardShowing(displayHeight);

            previousDisplayHeight = displayHeight;
        }

        private void calculateKeyboardHeight(final int displayHeight) {
            // first result.
            if (previousDisplayHeight == 0) {
                previousDisplayHeight = displayHeight;

                this.keyboardShowingListener.onKeyboardChange(0, getKeyboardHeight(getContext()));
                return;
            }

            int keyboardHeight;
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
                //这里是显示高度的变化值，相当于键盘的变化值
                keyboardHeight = Math.abs(displayHeight - previousDisplayHeight);
            }


            if (keyboardHeight <= getMinKeyboardHeight() //变化超过了最小高度，认为不是高度变化：no change.
                || lastKeyboardShowing && keyboardHeight != LAST_SAVE_KEYBOARD_HEIGHT) {// 键盘已show，高度变化 != last高度，认为键盘变化
                //键盘高度变化时，更新缓存。
                if (keyboardHeight > this.statusBarHeight) {
                    int newHeight = LAST_SAVE_KEYBOARD_HEIGHT - (displayHeight - previousDisplayHeight);
                    int lastHeight = LAST_SAVE_KEYBOARD_HEIGHT;
                    saveKeyboardHeight(getContext(), newHeight);
                    this.keyboardShowingListener.onKeyboardChange(lastHeight, newHeight);
                }
                return;
            }

            // influence from the layout of the Status-bar.
            if (keyboardHeight == this.statusBarHeight) {
                return;
            }

            // save the keyboardHeight
            int lastHeight = LAST_SAVE_KEYBOARD_HEIGHT;
            boolean changed = saveKeyboardHeight(getContext(), keyboardHeight);
            this.keyboardShowingListener.onKeyboardChange(lastHeight, keyboardHeight);
            if (changed) {
            }
        }

        private int maxOverlayLayoutHeight;

        private void calculateKeyboardShowing(final int displayHeight) {

            boolean isKeyboardShowing;

            // the height of content parent = contentView.height + actionBar.height
            final View actionBarOverlayLayout = (View) contentView.getParent();
            // in the case of FragmentLayout, this is not real ActionBarOverlayLayout, it is
            // LinearLayout, and is a child of DecorView, and in this case, its top-padding would be
            // equal to the height of status bar, and its height would equal to DecorViewHeight -
            // NavigationBarHeight.
            final int actionBarOverlayLayoutHeight = actionBarOverlayLayout.getHeight() -
                actionBarOverlayLayout.getPaddingTop();
            /*
              由于增加了 {@link KeyboardViewUtil.isUiVisibilityFullscreen()} 为true时的处理
              此处需要对此情况进行处理
             */
            if (isHandleByPlaceholder(isFullScreen, isTranslucentStatus, isFitSystemWindows, isSystemUiVisibilityFullScreen)) {
                if (!isSystemUiVisibilityFullScreen && !isTranslucentStatus &&
                    actionBarOverlayLayoutHeight - displayHeight == this.statusBarHeight) {
                    // handle the case of status bar layout, not keyboard active.
                    isKeyboardShowing = lastKeyboardShowing;
                } else {
                    if (isSystemUiVisibilityFullScreen) {
                        //考虑到状态栏的高度
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

                if (keyboardShowingListener != null) {
                    keyboardShowingListener.onKeyboardChange(
                        isKeyboardShowing ? 0 : getKeyboardHeight(getContext())
                        , isKeyboardShowing ? getKeyboardHeight(getContext()) : 0);
                    keyboardShowingListener.onKeyboardShowing(isKeyboardShowing, isKeyboardShowing ? getKeyboardHeight(getContext()) : 0);
                }
            }

            lastKeyboardShowing = isKeyboardShowing;

        }

        private Context getContext() {
            return contentView.getContext();
        }
    }

    private static int stateBarHeight(Context context) {
        if (MLSConfigs.noStateBarHeight)
            return 0;
        if (context != null) {
            return AndroidUtil.getStatusBarHeight(context);
        }
        return 0;
    }

    private static int getMinKeyboardHeight() {
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
    private static boolean isHandleByPlaceholder(boolean isFullScreen, boolean isTranslucentStatus,
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

        void onKeyboardChange(int oldHeight, int newHeight);
    }


}