/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.MLSConfigs;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.weight.BorderBackgroundDrawable;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.weight.load.ILoadViewDelegete;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
public class Adapter extends RecyclerView.Adapter<ViewHolder> {

    private static final String TAG = Adapter.class.getSimpleName();

    public static final int TYPE_FOOT = Integer.MIN_VALUE;

    private final UDBaseRecyclerAdapter userData;
    private final ILoadViewDelegete loadViewDelegete;
    private boolean footerAdded = false;
    private List<View> headerViews;
    private boolean useAllSpanForLoading = false;
    private View footerView;

    private boolean canCallFillCell = true;
    private HashMap<ViewHolder, Integer> lazyTasks;

    public Adapter(@NonNull UDBaseRecyclerAdapter ud, @NonNull ILoadViewDelegete delegete) {
        userData = ud;
        if (delegete == null) {
            throw new NullPointerException("ILoadViewDelegete is null!");
        }
        loadViewDelegete = delegete;
    }

    public void setFooterAdded(boolean added) {
        if (footerAdded != added) {
            footerAdded = added;
            if (!added) {
                notifyItemRemoved(getItemCount());
            } else {
                notifyItemInserted(getItemCount() - 1);
            }
            if (userData != null) {
                userData.onFooterAdded(added);
            }
        }
    }

    public void addHeaderViews(Collection<View> views) {
        if (headerViews == null) {
            headerViews = new ArrayList<>();
        }
        int index = headerViews.size();
        headerViews.addAll(views);
        notifyItemRangeInserted(index, views.size());
    }

    public void addHeaderView(View v) {
        if (headerViews == null) {
            headerViews = new ArrayList<>();
        }
        headerViews.add(v);
        notifyItemInserted(headerViews.size() - 1);
    }

    public void removeHeaderView(View v) {
        if (headerViews != null) {
            int index = headerViews.indexOf(v);
            headerViews.remove(index);
            notifyItemRemoved(index);
        }
    }

    public void removeAllHeaderView() {
        if (headerViews != null) {
            int c = headerViews.size();
            headerViews.clear();
            if (c > 0) {
                notifyItemRangeRemoved(0, c);
            }
        }
    }

    public int getHeaderCount() {
        return headerViews != null ? headerViews.size() : 0;
    }

    public void useAllSpanForLoading(boolean use) {
        useAllSpanForLoading = use;
        if (footerView != null) {
            footerView.setLayoutParams(userData.newLayoutParams(footerView.getLayoutParams(), use));
        }
    }

    public boolean isUseAllSpanForLoading() {
        return useAllSpanForLoading;
    }

    public void setRecyclerState(int state) {
        canCallFillCell = state != RecyclerView.SCROLL_STATE_SETTLING;
        if (canCallFillCell && lazyTasks != null) {
            MainThreadExecutor.post(lazyCallFillCellTask);
        }
    }

    private Runnable lazyCallFillCellTask = new Runnable() {
        @Override
        public void run() {
            if (lazyTasks == null || lazyTasks.isEmpty())
                return;
            if (userData.getGlobals().isDestroyed()) {
                lazyTasks.clear();
                return;
            }
            for (Map.Entry<ViewHolder, Integer> entry : lazyTasks.entrySet()) {
                userData.callFillDataCell(entry.getKey().getCell(), entry.getValue());
            }
            lazyTasks.clear();
        }
    };

    @Override
    public int getItemViewType(int position) {
        if (footerAdded && position == getItemCount() - 1)
            return TYPE_FOOT;
        //header type < 0
        int t = headerViews != null ? headerViews.size() : 0;
        if (position < t) {
            return -(position + 1);
        }
        return userData.getViewType(position - t);
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (viewType == TYPE_FOOT) {
            View v = loadViewDelegete.getLoadView().getView();
            v.setOnClickListener(new LoadViewClickListener());
            v.setLayoutParams(userData.newLayoutParams(v.getLayoutParams(), useAllSpanForLoading));
            ViewHolder ret = new ViewHolder(v, userData);
            footerView = v;
            return ret;
        } else if (viewType < 0) {//header
            View v = headerViews.get(getPositionByType(viewType));
            return createHeaderViewHolder(v, viewType);
        }
        return createItemViewHolder(viewType);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        if (holder.isFoot()) {
            return;
        }
        if (holder.isHeader()) {
            if (userData.isNewHeaderValid()) {
                Size size = userData.getHeaderSize(position);

                View cellView = holder.getCellView();

                if (cellView != null) {
                    setLayoutParams(cellView, size);
                }

                userData.callFillDataHeader(holder.getCell(), position);

                checkMargin(holder.getCellView());
            }
            return;
        }
        if (userData.checkCanDoBind())
            return;
        int hs = getHeaderCount();

        if (userData.hasCellSize()) {

            Size size = userData.getCellSize(position - hs);

            if (userData.layout instanceof UDWaterFallLayout) {
                UDWaterFallLayout layout = (UDWaterFallLayout) userData.layout;
                int spanCount = layout.getSpanCount();

                //第一行时，多减去outRect.top = 0,无需处理
                if (position >= ((hs > 0) ? hs : spanCount)) {
                    //其他行时，多减去outRect.top = LineSpacing; height加回来
                    size.setHeight(size.getHeight() + layout.getLineSpacing());
                }

            }

            View cellView = holder.getCellView();

            if (cellView != null) {
                setLayoutParams(cellView, size);
            }
        }
        if (canCallFillCell || !MLSConfigs.lazyFillCellData) {
            userData.callFillDataCell(holder.getCell(), position - hs);
            holder.checkClick();
        } else {
            if (lazyTasks == null) {
                lazyTasks = new HashMap<>();
            }
            lazyTasks.put(holder, position - hs);
        }

        checkMargin(holder.getCellView());
        setSelector(holder.itemView);
    }

    @Override
    public int getItemCount() {
        int c = userData.getTotalCount();
        c = c < 0 ? 0 : c;
        int h = headerViews != null ? headerViews.size() : 0;
        return c + (footerAdded ? 1 : 0) + h;
    }

    private int getPositionByType(int headerPos) {
        return -headerPos - 1;
    }

    /**
     * create item view for view holder
     *
     * @param viewType
     * @return
     */
    private ViewHolder createItemViewHolder(final int viewType) {
        final UDCell layout = new UDCell(userData.getGlobals(), userData);
        View itemView = layout.getView();
        userData.callInitCell(layout.getCell(), viewType);
        initSize(itemView, viewType);
        ViewHolder viewHolder = new ViewHolder(itemView, layout, userData, viewType);
        checkMargin(itemView);
        return viewHolder;
    }

    /**
     * 创建Header的cell
     *
     * @param headerView
     * @return
     */
    private ViewHolder createHeaderViewHolder(View headerView, int viewType) {
        final UDCell layout = new UDCell(userData.getGlobals(), userData);

        ViewGroup itemView = (ViewGroup) layout.getView();

        if (userData.isNewHeaderValid()) {
            userData.callInitHeader(layout.getCell());
        }
        itemView.addView(headerView);
        itemView.setLayoutParams(userData.newLayoutParams(null, true));
        ViewHolder viewHolder = new ViewHolder(itemView, layout, userData, viewType);

        checkMargin(itemView);
        return viewHolder;
    }

    private FrameLayout generateCellView(UDCell layout) {
        FrameLayout frameLayout = new FrameLayout(userData.getContext());
        LuaViewUtil.removeFromParent(layout.getView());
        frameLayout.addView(layout.getView());
        return frameLayout;
    }

    private void setSelector(View view) {
        if (view.getTag() == null)
            view.setTag(view.getBackground());

        if (userData.isShowPressed()) {
            StateListDrawable bg = new StateListDrawable();
            BorderBackgroundDrawable pressed = new BorderBackgroundDrawable();
            if (view.getBackground() instanceof BorderBackgroundDrawable) {
                BorderBackgroundDrawable normalDrawable = (BorderBackgroundDrawable) view.getBackground();
                pressed.setStrokeWidth(normalDrawable.getStrokeWidth());
                float[] radii = normalDrawable.getRadii();
                if (radii != null && radii.length == 8) {
                    pressed.setRadius(radii[0], radii[2], radii[4], radii[6]);
                }
            }
            pressed.setBgColor(userData.getPressedColor().getColor());
            bg.addState(new int[]{android.R.attr.state_pressed}, pressed);
            view.setClickable(true);
            bg.addState(new int[]{}, view.getBackground());
            view.setBackgroundDrawable(bg);
        } else if (view.getTag() instanceof Drawable)
            view.setBackground((Drawable) view.getTag());

    }

    private void initSize(View itemView, int type) {
        Size size = userData.getInitCellSize(type);
        setLayoutParams(itemView, size);
    }

    private void setLayoutParams(View view, Size size) {
//        LogUtil.d(TAG, " width = " + size.getWidthPx() + "    height = " + size.getHeightPx());

        ViewGroup.LayoutParams params = view.getLayoutParams();
        int w = size.getWidthPx();
        int h = size.getHeightPx();
        boolean changed = false;
        if (params == null) {
            params = new ViewGroup.LayoutParams(w, h);
            changed = true;
        } else if (params.width != w || params.height != h) {
            params.width = w;
            params.height = h;
            changed = true;
        }
        if (changed)
            view.setLayoutParams(params);
    }

    protected void callbackLoad(ViewHolder holder) {
        if (loadViewDelegete.onShowLoadView(false)) {
            userData.onLoad();
        }
    }

    private final class LoadViewClickListener implements View.OnClickListener {

        @Override
        public void onClick(View v) {
            if (loadViewDelegete.onShowLoadView(true)) {
                userData.onLoad();
            }
        }
    }

    @Override
    public void onViewDetachedFromWindow(ViewHolder holder) {
        super.onViewDetachedFromWindow(holder);
        if (holder.isFoot()) {
//            LogUtil.d("foot detached");
            return;
        }
        userData.callCellDisappear(holder);
    }

    @Override
    public void onViewAttachedToWindow(ViewHolder holder) {
        super.onViewAttachedToWindow(holder);
        if (holder.isFoot()) {
            callbackLoad(holder);
            return;
        }
        userData.callCellAppear(holder);
    }

    /**
     * 检查：contentView 不支持margin
     *
     * @param view
     */
    public void checkMargin(View view) {
        if (!MLSEngine.DEBUG) {
            return;
        }
        ViewGroup.LayoutParams lp = view != null ? view.getLayoutParams() : null;
        if (!(lp instanceof ViewGroup.MarginLayoutParams)) {
            return;
        }
        ViewGroup.MarginLayoutParams marginLp = ((ViewGroup.MarginLayoutParams) lp);
        if (marginLp.leftMargin > 0 || marginLp.rightMargin > 0
                || marginLp.topMargin > 0 || marginLp.bottomMargin > 0) {
            ErrorUtils.debugUnsupportError("Attention: TableViewAdapter`s contentView is not support Margins.");
        }
    }
}