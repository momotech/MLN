/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.util.SparseArray;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.immomo.mls.fun.other.Size;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ud.AdapterLuaFunction;

import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/7/20.
 */
@LuaApiUsed
public abstract class UDBaseNeedHeightAdapter<L extends UDBaseRecyclerLayout> extends UDBaseRecyclerAdapter<L> {
    public static final String LUA_CLASS_NAME = "__BaseNeedHeightAdapter";
    protected AdapterLuaFunction heightForCell, heightForHeader;
    protected Map<String, AdapterLuaFunction> heightDelegates;
    private SparseArray<Size> sizeCache;

    private Size initSize;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDBaseNeedHeightAdapter(long L) {
        super(L);
        initValue();
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    //<editor-fold desc="API">

    private void initValue() {
        initSize = new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
    }

    /**
     * function(section,row) 返回item的高
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void heightForCell(long f) {
        if (f == 0)
            heightForCell = null;
        else
            heightForCell = new AdapterLuaFunction(globals, f);
    }

    /**
     * function(section,row) 返回Header的高
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void heightForHeader(long f) {
        if (f == 0)
            heightForHeader = null;
        else
            heightForHeader = new AdapterLuaFunction(globals, f);
    }

    @CGenerate(params = "0F")
    @LuaApiUsed
    public void heightForCellByReuseId(String t, long f) {
        if (heightDelegates == null) {
            heightDelegates = new HashMap<>();
        }
        if (f == 0)
            heightDelegates.put(t, null);
        else
            heightDelegates.put(t, new AdapterLuaFunction(globals, f));
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

        AdapterLuaFunction caller;
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

        int[] sr = getSectionAndRowIn(position);
        int h = caller.fastInvokeII_I(sr[0] + 1, sr[1] + 1);
        h = h < 0 ? 0 : h; //两端统一返回高度<0,默认为0。
        cellSize = new Size(Size.MATCH_PARENT, h);
        sizeCache.put(position, cellSize);
        return cellSize;
    }

    @NonNull
    @Override
    public Size getHeaderSize(int position) {

        if (heightForHeader == null) {
            ErrorUtils.debugLuaError("The 'heightForHeader' callback must not be nil!", globals);
            return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
        }

        int h = heightForHeader.fastInvoke_I();
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