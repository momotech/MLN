/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.other;

import androidx.recyclerview.widget.RecyclerView;
import android.view.View;

import com.immomo.mls.fun.ud.UDCell;

import org.luaj.vm2.LuaValue;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
public class ViewHolder extends RecyclerView.ViewHolder {
    private final UDCell cell;
    private boolean clickListenerSetted;
    //for test
    int count = 0;

    public ViewHolder(View itemView, UDCell cell) {
        super(itemView);
        this.cell = cell;
    }

    public ViewHolder(View itemView) {
        super(itemView);
        cell = null;
    }

    public boolean isFoot() {
        return getItemViewType() == Adapter.TYPE_FOOT;
    }

    public boolean isHeader() {
        return getItemViewType() < 0;
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

    public void setOnClickListener(View.OnClickListener listener) {
        clickListenerSetted = listener != null;
        itemView.setOnClickListener(listener);
    }

    public void setOnLongClickListener(View.OnLongClickListener listener) {
        itemView.setOnLongClickListener(listener);
    }

    public boolean isClickListenerSetted() {
        return clickListenerSetted;
    }

    @Override
    public String toString() {
        return super.toString() + " isfoot: " + isFoot() + " count: " + count;
    }
}