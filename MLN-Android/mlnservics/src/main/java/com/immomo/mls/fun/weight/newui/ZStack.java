/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.weight.newui;

import android.content.Context;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

/**
 * Created by zhang.ke
 * on 2020-03-11
 */
public class ZStack extends FrameLayout {
    private int mGravity = Gravity.START | Gravity.TOP;

    public ZStack(Context context) {
        super(context);
        init();
    }

    public ZStack(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ZStack(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
    }

    public void setGravity(int gravity) {
        if (mGravity != gravity) {
            if ((gravity & Gravity.RELATIVE_HORIZONTAL_GRAVITY_MASK) == 0) {
                gravity |= Gravity.START;
            }

            if ((gravity & Gravity.VERTICAL_GRAVITY_MASK) == 0) {
                gravity |= Gravity.TOP;
            }

            mGravity = gravity;
            requestLayout();
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        layoutChildren(left, top, right, bottom, false /* no force left gravity */);
    }

    void layoutChildren(int left, int top, int right, int bottom, boolean forceLeftGravity) {
        final int count = getChildCount();

        final int parentLeft = getPaddingLeft();
        final int parentRight = right - left - getPaddingRight();

        final int parentTop = getPaddingTop();
        final int parentBottom = bottom - top - getPaddingBottom();

        for (int i = 0; i < count; i++) {
            final View child = getChildAt(i);
            if (child.getVisibility() != GONE) {
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                final int width = child.getMeasuredWidth();
                final int height = child.getMeasuredHeight();

                int childLeft = 0;
                int childTop;

                int gravity = lp.gravity;

                //子View的Gravity
                final int layoutDirection = getLayoutDirection();
                final int absoluteGravity = Gravity.getAbsoluteGravity(gravity, layoutDirection);
                final int verticalGravity = gravity & Gravity.VERTICAL_GRAVITY_MASK;

                //容器控制子View对齐方向
                final int stackAbsoluteGravity = Gravity.getAbsoluteGravity(mGravity, layoutDirection);
                final int stackVerticalGravity = mGravity & Gravity.VERTICAL_GRAVITY_MASK;

                switch (absoluteGravity & Gravity.HORIZONTAL_GRAVITY_MASK) {
                    case Gravity.CENTER_HORIZONTAL:
                        childLeft = parentLeft + (parentRight - parentLeft - width) / 2 +
                            lp.leftMargin - lp.rightMargin;
                        break;
                    case Gravity.RIGHT:
                        if (!forceLeftGravity) {
                            childLeft = parentRight - width - lp.rightMargin;
                            break;
                        }
                    case Gravity.LEFT:
                        childLeft = parentLeft + lp.leftMargin;
                        break;
                    default:
                        //没有设置gravity，默认走ZStack
                        switch (stackAbsoluteGravity & Gravity.HORIZONTAL_GRAVITY_MASK) {
                            case Gravity.CENTER_HORIZONTAL:
                                childLeft = parentLeft + (parentRight - parentLeft - width) / 2 +
                                    lp.leftMargin - lp.rightMargin;
                                break;
                            case Gravity.RIGHT:
                                if (!forceLeftGravity) {
                                    childLeft = parentRight - width - lp.rightMargin;
                                    break;
                                }
                            case Gravity.LEFT:
                                childLeft = parentLeft + lp.leftMargin;
                        }
                }

                switch (verticalGravity) {
                    case Gravity.TOP:
                        childTop = parentTop + lp.topMargin;
                        break;
                    case Gravity.CENTER_VERTICAL:
                        childTop = parentTop + (parentBottom - parentTop - height) / 2 +
                            lp.topMargin - lp.bottomMargin;
                        break;
                    case Gravity.BOTTOM:
                        childTop = parentBottom - height - lp.bottomMargin;
                        break;
                    default:
                        //没有设置gravity，默认走ZStack
                        switch (stackVerticalGravity) {
                            case Gravity.TOP:
                                childTop = parentTop + lp.topMargin;
                                break;
                            case Gravity.CENTER_VERTICAL:
                                childTop = parentTop + (parentBottom - parentTop - height) / 2 +
                                    lp.topMargin - lp.bottomMargin;
                                break;
                            case Gravity.BOTTOM:
                                childTop = parentBottom - height - lp.bottomMargin;
                                break;
                            default:
                                childTop = parentTop + lp.topMargin;
                        }
                }

                child.layout(childLeft, childTop, childLeft + width, childTop + height);
            }
        }
    }
}
