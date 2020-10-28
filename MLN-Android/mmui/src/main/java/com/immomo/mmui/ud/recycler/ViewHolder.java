/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import org.luaj.vm2.LuaValue;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener, View.OnLongClickListener {
    private final UDCell cell;
    private final UDBaseRecyclerAdapter udAdapter;
    private final Adapter adapter;
    private final int type;
    private boolean clickSet;
    private boolean longClickSet;

    public ViewHolder(View itemView, UDCell cell, UDBaseRecyclerAdapter adapter, int type) {
        super(itemView);
        this.cell = cell;
        this.udAdapter = adapter;
        this.adapter = adapter.getAdapter();
        this.type = type;
        checkClick();
    }

    public ViewHolder(View itemView, UDBaseRecyclerAdapter adapter) {
        super(itemView);
        cell = null;
        this.udAdapter = adapter;
        this.adapter = adapter.getAdapter();
        this.type = Adapter.TYPE_FOOT;
    }

    public boolean isFoot() {
        return type == Adapter.TYPE_FOOT;
    }

    public boolean isHeader() {
        return type < 0;
    }

    public LuaValue getCell() {
        return cell != null ? cell.getCell() : null;
    }

    public UDCell getUD() {
        return cell;
    }

    public View getCellView() {
        return cell != null ? cell.getView() : null;
    }

    public void checkClick() {
        if (isFoot() || isHeader())
            return;
        if (!clickSet && udAdapter.hasClickFor(type))
            setClick();
        if (!longClickSet && udAdapter.hasLongClickFor(type))
            setLongClick();
    }

    private void setClick() {
        clickSet = true;
        itemView.setOnClickListener(this);
    }

    private void setLongClick() {
        longClickSet = true;
        itemView.setOnLongClickListener(this);
    }

    @Override
    public String toString() {
        return super.toString() + " isfoot: " + isFoot();
    }

    @Override
    public void onClick(View v) {
        udAdapter.doCellClick(getCell(), getAdapterPosition() - adapter.getHeaderCount());
    }

    @Override
    public boolean onLongClick(View v) {
        return udAdapter.doCellLongClick(getCell(), getAdapterPosition() - adapter.getHeaderCount());
    }
}