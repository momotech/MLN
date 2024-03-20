/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.weight.load.ILoadViewDelegete;
import com.immomo.mmui.ILView;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
public class Adapter extends RecyclerView.Adapter<ViewHolder> {

    public static final int TYPE_FOOT = Integer.MIN_VALUE;

    private final UDBaseRecyclerAdapter userData;
    private final ILoadViewDelegete loadViewDelegete;
    private boolean footerAdded = false;
    private View headerView;
    private boolean useAllSpanForLoading = false;
    private View footerView;

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

    public void setHeaderView(View v) {
        headerView = v;
        notifyItemInserted(0);
    }

    public void removeHeaderView() {
        if (headerView != null) {
            headerView = null;
            notifyItemRangeRemoved(0, 1);
        }
    }

    public int getHeaderCount() {
        return headerView != null ? 1 : 0;
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

    @Override
    public int getItemViewType(int position) {
        if (footerAdded && position == getItemCount() - 1)
            return TYPE_FOOT;
        //header type < 0
        int t = getHeaderCount();
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
            return createHeaderViewHolder(viewType);
        }
        return createItemViewHolder(viewType);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        if (holder.isFoot()) {
            return;
        }
        if (holder.isHeader()) {
            userData.callFillDataHeader(holder.getCell(), position);
            checkMargin(holder.getCellView());
            return;
        }
        int hs = getHeaderCount();
        userData.callFillDataCell(holder.getCell(), position - hs);
        holder.checkClick();
        checkMargin(holder.getCellView());
        setSelector(holder.itemView);
    }

    @Override
    public int getItemCount() {
        int c = userData.getTotalCount();
        c = Math.max(c, 0);
        return c + (footerAdded ? 1 : 0) + getHeaderCount();
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
        layout.widthAuto();
        layout.heightAuto();
        userData.callInitCell(layout.getCell(), viewType);
        itemView.setLayoutParams(userData.newLayoutParams(itemView.getLayoutParams(), false));
        return new ViewHolder(itemView, layout, userData, viewType);
    }

    /**
     * 创建Header的cell
     *
     * @return
     */
    private ViewHolder createHeaderViewHolder(int viewType) {
        final UDCell layout = new UDCell(userData.getGlobals(), userData);
        ViewGroup itemView = (ViewGroup) layout.getView();

        if (userData.isNewHeaderValid()) {
            userData.callInitHeader(layout.getCell());
        }
        itemView.addView(headerView);
        itemView.setLayoutParams(userData.newLayoutParams(null, true));
        return new ViewHolder(itemView, layout, userData, viewType);
    }

    private void setSelector(View view) {
        if (view instanceof ILView) {
            ((ILView) view).getUserdata().openRipple(userData.isShowPressed());
        }
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