/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import android.util.SparseArray;
import android.view.ViewGroup;


import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/7/20.
 */
@LuaApiUsed
public abstract class UDBaseNeedHeightAdapter<L extends UDBaseRecyclerLayout> extends UDBaseRecyclerAdapter<L> {
    public static final String LUA_CLASS_NAME = "__BaseNeedHeightAdapter";
    public static final String[] methods = new String[]{
            "heightForCell",
            "heightForHeader",
            "heightForCellByReuseId"
    };
    protected LuaFunction heightForCell, heightForHeader;
    protected Map<String, LuaFunction> heightDelegates;
    private SparseArray<Size> sizeCache;

    private Size initSize;

    @LuaApiUsed
    public UDBaseNeedHeightAdapter(long L, LuaValue[] v) {
        super(L, v);
        initValue();
    }
    //<editor-fold desc="API">

    private void initValue() {
        initSize = new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
    }

    /**
     * function(section,row) 返回item的高
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] heightForCell(LuaValue[] values) {
        heightForCell = values[0].toLuaFunction();
        return null;
    }

    /**
     * function(section,row) 返回Header的高
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] heightForHeader(LuaValue[] values) {
        heightForHeader = values[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] heightForCellByReuseId(LuaValue[] values) {
        if (heightDelegates == null) {
            heightDelegates = new HashMap<>();
        }
        heightDelegates.put(values[0].toJavaString(), values[1].toLuaFunction());
        return null;
    }
    //</editor-fold>

    @Override
    public boolean hasCellSize() {
        return heightForCell != null || heightDelegates != null;
    }

    @Override
    public int getCellViewHeight() {
        return ViewGroup.LayoutParams.WRAP_CONTENT;
    }

    /**
     * called when {@link #hasCellSize} return true
     *
     * @param position
     * @return
     */
    @NonNull
    @Override
    public Size getCellSize(int position) {
        if (sizeCache == null) {
            sizeCache = new SparseArray<>();
        }
        Size cellSize = sizeCache.get(position);
        if (cellSize != null)
            return cellSize;

        int[] sr = getSectionAndRowIn(position);

        LuaValue s = toLuaInt(sr[0]);
        LuaValue r = toLuaInt(sr[1]);

        LuaFunction caller;
        if (heightDelegates != null) {
            String id = getReuseIdByType(getAdapter().getItemViewType(position));
            caller = heightDelegates.get(id);
            if (!AssertUtils.assertFunction(caller,
                    "heightForCellByReuseId和heightForCell互斥，请统一使用方法",
                    getGlobals())) {
                return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
            }
        } else {
            caller = heightForCell;
        }
        if (!AssertUtils.assertFunction(caller, "必须通过heightForCell将函数设置到adapter中", getGlobals())) {
            return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
        }

        LuaValue[] rets = caller.invoke(varargsOf(s, r));
        if (rets == null || rets.length == 0) {
            return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
        }
        LuaValue ret = rets[0];

        if (!AssertUtils.assertNumber(ret, caller, getGlobals())) {
            return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
        }

        int h = ret.toInt();
        h = h < 0 ? 0 : h; //两端统一返回高度<0,默认为0。

        cellSize = new Size(Size.MATCH_PARENT, h);

        sizeCache.put(position, cellSize);

        return cellSize;
    }

    @NonNull
    @Override
    public Size getHeaderSize(int position) {

        LuaFunction caller = heightForHeader;
        if (caller == null) {
            ErrorUtils.debugLuaError("The 'heightForHeader' callback must not be nil!", globals);
            return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
        }
        LuaValue[] rets = caller.invoke(null);

        final LuaValue ret;
        if (rets == null || rets.length == 0) {
            ret = Nil();
        } else {
            ret = rets[0];
        }

        if (!AssertUtils.assertNumber(ret, caller, getGlobals())) {
            return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
        }

        int h = ret.toInt();
        h = h < 0 ? 0 : h; //两端统一返回高度<0,默认为0。

        return new Size(Size.MATCH_PARENT, h);
    }

    @NonNull
    @Override
    public Size getInitCellSize(int type) {
        return initSize;
    }

    @Override
    protected void onReload() {
        super.onReload();
        if (sizeCache != null)
            sizeCache.clear();
    }

    @Override
    protected void onClearFromIndex(int index) {
        super.onClearFromIndex(index);
        removeSparseArrayFromStart(sizeCache, index);
    }
}