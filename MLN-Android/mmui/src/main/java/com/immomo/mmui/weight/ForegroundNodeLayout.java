/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.weight;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.os.Build;

import com.immomo.mls.weight.ForegroundDelegate;
import com.immomo.mls.weight.IForeground;
import com.immomo.mmui.weight.layout.VirtualLayout;

import androidx.annotation.NonNull;

public class ForegroundNodeLayout extends VirtualLayout implements IForeground {
    private ForegroundDelegate mForegroundDelegate;
    private boolean enableForeground;

    public ForegroundNodeLayout(Context context) {
        this(context,false);
    }

    public ForegroundNodeLayout(@NonNull Context context, boolean isVirtual) {
        super(context, isVirtual);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mForegroundDelegate = new ForegroundDelegate();
        }
    }

    @Override
    public int getForegroundGravity() {
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return mForegroundDelegate.getForegroundGravity();
        } else {
            return super.getForegroundGravity();
        }
    }

    @Override
    public void setForegroundGravity(int foregroundGravity) {
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mForegroundDelegate.setForegroundGravity(this, foregroundGravity);
        } else {
            super.setForegroundGravity(foregroundGravity);
        }
    }

    @Override
    protected boolean verifyDrawable(Drawable who) {
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return super.verifyDrawable(who) || (who == mForegroundDelegate.getForeground());
        } else {
            return super.verifyDrawable(who);
        }
    }

    @Override
    public void jumpDrawablesToCurrentState() {
        super.jumpDrawablesToCurrentState();
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mForegroundDelegate.jumpDrawablesToCurrentState();
        }
    }

    @Override
    protected void drawableStateChanged() {
        super.drawableStateChanged();
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mForegroundDelegate.drawableStateChanged(this);
        }
    }


    @Override
    public void setForeground(Drawable foreground) {
        enableForeground = foreground != null;
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mForegroundDelegate.setForeground(this, foreground);
        } else {
            super.setForeground(foreground);
        }
    }

    @Override
    public void clearForeground() {
        enableForeground = false;
    }

    @Override
    public Drawable getForeground() {
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return mForegroundDelegate.getForeground();
        } else {
            return super.getForeground();
        }
    }

    @Override
    public boolean hasForeground() {
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return mForegroundDelegate.getForeground() != null;
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M){
            return super.getForeground() != null;
        }
        return false;
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mForegroundDelegate.onLayout(changed, left, top, right, bottom);
        }
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mForegroundDelegate.onSizeChanged(w, h, oldw, oldh);
        }
    }

    @Override
    public void draw(Canvas canvas) {
        super.draw(canvas);
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mForegroundDelegate.draw(this, canvas);
        }
    }

    @Override
    public void drawableHotspotChanged(float x, float y) {
        super.drawableHotspotChanged(x, y);
        if (enableForeground && Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mForegroundDelegate.drawableHotspotChanged(x, y);
        }
    }
}