/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.viewpager;

import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.MLSConfigs;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.ud.view.UDViewPager;
import com.immomo.mls.fun.ui.IViewPager;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.weight.BaseTabLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;


/**
 * Created by fanqiang on 2018/8/30.
 */
public class ViewPagerAdapter extends PagerAdapter implements IViewPager.Callback {

    UDViewPager mUDViewPager;

    private UDViewPagerAdapter userData;
    private final ViewPagerRecycler recycler;

    private boolean canPreRender = true;
    private SparseArray<ViewPagerContent> needCallFillCells;
    private @NonNull
    final SparseArray<ViewPagerContent> cellInLayout;
    private @NonNull
    final SparseArray<View> viewPosition;
    private int viewPagerConfig = MLSConfigs.viewPagerConfig;
    /**
     * ViewPager和TabLayout联动接口，用于两控件无限轮播时，数据传递
     */
    private BaseTabLayout.SetupViewPageListener setupPageListener;

    public ViewPagerAdapter(UDViewPagerAdapter userData) {
        this.userData = userData;
        recycler = new ViewPagerRecycler();
        cellInLayout = new SparseArray<>();
        viewPosition = new SparseArray<>();
    }

    public void setCanPreRenderCount(boolean can) {
        canPreRender = can;
    }

    public void setViewPagerConfig(int viewPagerConfig) {
        this.viewPagerConfig = viewPagerConfig;
    }

    public @Nullable
    ViewPagerContent getViewPagerContentAt(int position) {
        return cellInLayout.get(position);
    }

    @Override
    public int getCount() {
        if (recurrenceRepeat() && getRealCount() > 0)
            return Integer.MAX_VALUE;

        return getRealCount();
    }

    public int getRealCount() {
        int realCount = userData.callGetCount();

        if (setupPageListener != null)
            setupPageListener.onGetCount(realCount);
        return realCount;
    }

    public boolean recurrenceRepeat() {
        return mUDViewPager != null && mUDViewPager.isRepeat();
    }

    public void setViewPager(UDViewPager udViewPager) {
        mUDViewPager = udViewPager;
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
        return view == object;
    }

    @Override
    public int getItemPosition(@NonNull Object object) {
        if (viewPagerConfig == 0) {
            return super.getItemPosition(object);
        }
        int index = viewPosition.indexOfValue((View) object);
        if (index < 0) {
            return POSITION_NONE;
        }
        return viewPosition.keyAt(index);
    }

    @Override
    public void notifyDataSetChanged() {
        viewPosition.clear();
        super.notifyDataSetChanged();
    }

    @Override
    public View instantiateItem(ViewGroup container, int position) {
        if (recurrenceRepeat() && getRealCount() !=0)
            position = position % getRealCount();

        String reuseId = userData.callGetReuseId(position);
        ViewPagerContent ret = null;
        if (validReuseId(reuseId)) {
            ret = recycler.getViewFromPoolByReuseId(reuseId);
        }
        boolean canRender = canRender(container, position);
        if (ret == null) {
            final UDViewPagerCell layout = new UDViewPagerCell<ViewPagerContent>(userData.getGlobals());
            ret = (ViewPagerContent) layout.getView();
            setLayoutParams(container, ret);
        }

        if (MLSEngine.DEBUG) {
            LogUtil.i("instantiateItem " + position + " " + ret.isInit() + " " + canRender);
        }
        if (canRender) {
            if (!ret.isInit())
                userData.callInitView(ret.getCell(), reuseId, position);
            userData.callFillCellData(ret.getCell(), reuseId, position);
        } else {
            if (needCallFillCells == null) {
                needCallFillCells = new SparseArray<>();
            }
            needCallFillCells.put(position, ret);
        }

        ret.setOnClickListener(userData.getOnClickListener());

        container.addView(ret);
        cellInLayout.put(position, ret);
        viewPosition.put(position, ret);
        (userData.mUDViewPager.getViewPager()).firstAttachAppearZeroPosition();
        return ret;
    }

    private void setLayoutParams(ViewGroup container, View view) {
        ViewGroup.LayoutParams parentParams = container.getLayoutParams();
        int w, h;
        if (parentParams != null) {
            w = parentParams.width == 0 ? ViewGroup.LayoutParams.MATCH_PARENT : parentParams.width;
            h = parentParams.height == 0 ? ViewGroup.LayoutParams.MATCH_PARENT : parentParams.height;
        } else {
            w = ViewGroup.LayoutParams.MATCH_PARENT;
            h = ViewGroup.LayoutParams.MATCH_PARENT;
        }

        ViewGroup.LayoutParams params = view.getLayoutParams();
        if (params == null) {
            params = new ViewGroup.LayoutParams(w, h);
        } else {
            params.width = w;
            params.height = h;
        }
        view.setLayoutParams(params);
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        if (recurrenceRepeat() && getRealCount() != 0)
            position = position % getRealCount();
        //轮播时，只有2或3个页面，会导致页面空白，原因：销毁的上一页，其实是下一页。这里特殊判断。
        int realCount = getRealCount();
        boolean notRemove = recurrenceRepeat() && (realCount == 2 || realCount == 3);

        container.removeView((View) object);
        if (needCallFillCells != null && !notRemove)
            needCallFillCells.remove(position);
        String id = userData.callGetReuseId(position);
        if (!validReuseId(id)) {
            return;
        }
        recycler.saveViewToPoolByReuseId(id, (ViewPagerContent) object);
    }

    private boolean canRender(ViewGroup vg, int position) {
        return canPreRender || getCurrentPos(vg) == position;
    }

    private int getCurrentPos(ViewGroup vg) {

        if (recurrenceRepeat() && getRealCount() !=0)
            return ((ViewPager) vg).getCurrentItem() % getRealCount();

        return ((ViewPager) vg).getCurrentItem();
    }

    private static boolean validReuseId(String id) {
        return id != null && id != UDViewPagerAdapter.NONE_REUSE_ID;
    }

    @Override
    public void callbackEndDrag(int p) {
    }

    @Override
    public void callbackStartDrag(int p) {
        if (needCallFillCells != null) {
            if (recurrenceRepeat() && getRealCount() != 0)
                p = p % getRealCount();
            ViewPagerContent c = needCallFillCells.get(p);
            if (c != null) {
                String reuseId = userData.callGetReuseId(p);
                if (!c.isInit()) {
                    userData.callInitView(c.getCell(), reuseId, p);
                }
                userData.callFillCellData(c.getCell(), reuseId, p);
            }
            needCallFillCells.remove(p);
        }

    }

    public void setSetupPageListener(BaseTabLayout.SetupViewPageListener setupPageListener) {
        this.setupPageListener = setupPageListener;
    }
}