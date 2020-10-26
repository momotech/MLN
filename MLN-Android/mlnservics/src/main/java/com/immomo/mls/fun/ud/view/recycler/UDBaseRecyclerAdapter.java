/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import android.content.Context;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.immomo.mls.Environment;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.MLSInstance;
import com.immomo.mls.fun.other.Adapter;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.other.ViewHolder;
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ui.IRefreshRecyclerView;
import com.immomo.mls.fun.ui.OnLoadListener;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.weight.load.ILoadViewDelegete;

import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed
public abstract class UDBaseRecyclerAdapter<L extends UDBaseRecyclerLayout> extends JavaUserdata implements OnLoadListener {
    public static final String LUA_CLASS_NAME = "__BaseRecyclerAdapter";
    public static final String[] methods = new String[]{
            "showPressed",
            "pressedColor",
            "reuseId",
            "initCell",
            "initCellByReuseId",
            "fillCellData",
            "fillCellDataByReuseId",
            "headerValid",
            "initHeader",
            "fillHeaderData",
            "sectionCount",
            "rowCount",
            "editParam",
            "editAction",
            "selectedRow",
            "longPressRow",
            "selectedRowByReuseId",
            "longPressRowByReuseId",
            "cellDidDisappear",
            "cellDidDisappearByReuseId",
            "cellWillAppear",
            "cellWillAppearByReuseId",
            "headerDidDisappear",
            "headerWillAppear",
    };
    //(section,row) 返回不同类型的id 字符串
    private LuaFunction reuseIdDelegate;
    // 普通类型初始化view的函数
    private LuaFunction initCellDelegate;
    //type类型初始化view的函数，若设置，则没有找到的type直接报错
    private Map<String, LuaFunction> typeCellDelegate;
    //(cell,section,row) 设置普通类型
    private LuaFunction bindDataDelegate;
    //(cell,section,row) 设置普通类型，若设置，则没有找到的type直接报错
    private Map<String, LuaFunction> bindTypeDataDelegate;
    // Header是否开启
    private LuaFunction headerValidDelegate;
    // Header类型初始化view的函数
    private LuaFunction initHeaderDelegate;
    //(cell,section,row) 设置Header类型
    private LuaFunction bindHeaderDelegate;
    //返回由多少组多数
    private LuaFunction sectionCountDelegate;
    //(section) 返回某组有多少数据
    private LuaFunction rowCountDelegate;

    //(cell,section,row) 普通item的点击事件
    private LuaFunction clickDelegate;

    //(cell,section,row) 普通item的 长按事件
    private LuaFunction clickLongDelegate;

    //(cell,section,row) 特殊item的点击事件，设置后，没找到的type报错
    private Map<String, LuaFunction> typeClickDelegate;

    //(cell,section,row) 特殊item的长按事件，设置后，没找到的type报错
    private Map<String, LuaFunction> typeLongClickDelegate;


    //(cell, section, row) item即将消失时回调
    private LuaFunction cellDisappearDelegate;
    private Map<String, LuaFunction> cellDisappearTypeDelegate;
    //Callback(cell, section, row)
    private LuaFunction cellAppearDelegate;
    private Map<String, LuaFunction> cellAppearTypeDelegate;
    //header消失时回调
    private LuaFunction headerDisappearDelegate;
    //header显示时回调
    private LuaFunction headerAppearDelegate;
    //点击cell后高亮
    public boolean showPressed = false;
    //点击后的高亮颜色
    public int pressedColor;

    private static final int DEFAULT_PRESSED_COLOR = 0xFFD3D3D3;
    DefaultItemAnimator mDefaultItemAnimator;
    /**
     * 长度除以2为section个数
     * 偶数下标为开始位置（包含）
     * 奇数下标为结束位置（不包含）
     * 相减为改组长度
     */
    protected int[] sections;
    protected AtomicInteger allCount;
    /**
     * 所有id缓存，reload的时候清除
     */
    protected SparseArray<String> reuseIdCache;
    /**
     * 每个position的点击事件
     */
    protected SparseArray<View.OnClickListener> viewClickCache;

    /**
     * 每个position的 长按事件
     */
    protected SparseArray<View.OnLongClickListener> viewLongClickCache;

    protected final IDGenerator idGenerator;
    protected IDGenerator recycledViewPoolIdGenerator;

    protected final ItemIDGenerator itemIDGenerator;

    protected ILoadViewDelegete loadViewDelegete;
    protected OnLoadListener onLoadListener;

    protected Adapter mAdapter;

    protected L layout;

    protected int viewWidth;
    protected int viewHeight;

    protected boolean reloadWhenViewSizeInit = false;
    protected boolean notifyWhenViewSizeInit = false;
    protected int orientation = RecyclerView.VERTICAL;

    @LuaApiUsed
    public UDBaseRecyclerAdapter(long L, LuaValue[] v) {
        super(L, v);
        idGenerator = new IDGenerator();
        pressedColor = DEFAULT_PRESSED_COLOR;
        itemIDGenerator = new ItemIDGenerator();
    }

    public Context getContext() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }

    //<editor-fold desc="Public Methods">
    //<editor-fold desc="ud view 调用">
    public void setOnLoadListener(OnLoadListener onLoadListener) {
        this.onLoadListener = onLoadListener;
    }

    @CallSuper
    public void setViewSize(int width, int height) {
        if (viewWidth == width && viewHeight == height)
            return;
        viewWidth = width;
        viewHeight = height;
        if (reloadWhenViewSizeInit && width > 0 && height > 0) {
            reload();
            return;
        }
        if (notifyWhenViewSizeInit && width > 0 && height > 0) {
            getAdapter().notifyDataSetChanged();
            return;
        }
    }

    public void reload() {
        if (viewWidth == 0 || viewHeight == 0) {
            reloadWhenViewSizeInit = true;
            return;
        }
        setItemAnimated(false);
        initSection();
        getAdapter().notifyDataSetChanged();
        onReload();
    }

    public void reloadAtRow(int section, int row, boolean animate) {
        notifyItemChanged(getPositionBySectionAndRow(section, row));
    }

    public void reloadAtSection(int section, boolean animate) {
        initSection();
        if (!checkSectionInitStatus())
            return;
        int count = sections.length;
        int index = section << 1;
        if (index >= count) {
            if (MLSEngine.DEBUG) {
                IndexOutOfBoundsException e = new IndexOutOfBoundsException("section over the source data");
                if (!Environment.hook(e, getGlobals())) {
                    throw e;
                }
            }
            return;
        }
        int start = sections[index];
        notifyItemRangeChanged(start, sections[index + 1] - start);
    }

    public void insertCellAtRow(int section, int row) {
        initSection();
        int position = getPositionBySectionAndRow(section, row);
        notifyItemInserted(position);
    }

    public void insertCellAtRowAnimated(int section, int row, boolean animated) {
        setItemAnimated(animated);

        initSection();
        int position = getPositionBySectionAndRow(section, row);
        notifyItemInserted(position);
    }

    View mRecyclerView;

    public void setRecyclerView(View recyclerView) {
        mRecyclerView = recyclerView;
    }

    public void setItemAnimated(boolean animated) {
        if (mRecyclerView instanceof IRefreshRecyclerView) {
            RecyclerView recyclerView = ((IRefreshRecyclerView) mRecyclerView).getRecyclerView();
            if (animated) {
                initItemAnimator();
                if (recyclerView.getItemAnimator() == null) {
                    recyclerView.setItemAnimator(mDefaultItemAnimator);
                }
            } else {
                recyclerView.setItemAnimator(null);
            }
        }
    }

    private void initItemAnimator() {
        if (mDefaultItemAnimator == null) {
            mDefaultItemAnimator = new DefaultItemAnimator();
        }
    }

    public void deleteCellAtRow(int section, int row) {
        int position = getPositionBySectionAndRow(section, row);
        initSection();
        notifyItemRemoved(position);
    }

    public void deleteCellAtRowAnimated(int section, int row, boolean animated) {
        setItemAnimated(animated);

        int position = getPositionBySectionAndRow(section, row);
        initSection();
        notifyItemRemoved(position);
    }

    public void insertCellsAtSection(int section, int startRow, int count) {
        initSection();
        int position = getPositionBySectionAndRow(section, startRow);
        notifyItemRangeInserted(position, count);
    }

    public void deleteCellsAtSection(int section, int startRow, int count) {
        int position = getPositionBySectionAndRow(section, startRow);
        initSection();
        notifyItemRangeRemoved(position, count);
    }

    public void setLoadViewDelegete(ILoadViewDelegete delegete) {
        loadViewDelegete = delegete;
    }

    public @NonNull
    Adapter getAdapter() {
        if (mAdapter == null) {
            mAdapter = new Adapter(this, loadViewDelegete);
        }
        return mAdapter;
    }

    public void setLayout(L layout, View view) {
        this.layout = layout;
        setRecyclerView(view);
        onLayoutSet(layout);
    }

    public abstract RecyclerView.LayoutManager getLayoutManager();

    public void setOrientation(int o) {
        if (orientation != o) {
            orientation = o;
            onOrientationChanged();
        }
    }
    //</editor-fold>

    //<editor-fold desc="for UDCell">

    /**
     * 初始化时获取cell的最大宽度
     *
     * @return
     */
    public abstract int getCellViewWidth();

    /**
     * 初始化时获取cell的最大高度
     *
     * @return
     */
    public abstract int getCellViewHeight();
    //</editor-fold>

    //<editor-fold desc="API">

    @LuaApiUsed
    public LuaValue[] showPressed(LuaValue[] values) {
        if (values.length >= 1 && values[0] != null) {
            this.showPressed = values[0].toBoolean();
            if (mAdapter != null) {
                mAdapter.notifyDataSetChanged();
            }
            return null;
        }
        return LuaValue.rBoolean(getShowPressed());
    }

    public boolean getShowPressed() {
        return showPressed;
    }

    @LuaApiUsed
    public LuaValue[] pressedColor(LuaValue[] values) {
        if (values.length == 1) {
            if (values[0] == LuaValue.Nil())
                this.pressedColor = DEFAULT_PRESSED_COLOR;
            else
                this.pressedColor = ((UDColor) values[0]).getColor();
            if (mAdapter != null) {
                mAdapter.notifyDataSetChanged();
            }
            return null;
        }

        return varargsOf(getPressedColor());
    }

    private UDColor returnColor;

    public UDColor getPressedColor() {
        if (returnColor == null) {
            returnColor = new UDColor(globals, pressedColor);
            returnColor.onJavaRef();
        }
        returnColor.setColor(pressedColor);
        return returnColor;
    }

    /**
     * (function(section,row)) 返回不同类型的id 字符串
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] reuseId(LuaValue[] values) {
        reuseIdDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * (function(cell)) 普通类型初始化view的函数
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] initCell(LuaValue[] values) {
        initCellDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * ('type', fuction(cell)) type类型初始化view的函数，优先级比setViewInit高
     * <p>
     * id
     * fun
     */
    @LuaApiUsed
    public LuaValue[] initCellByReuseId(LuaValue[] values) {
        if (typeCellDelegate == null) {
            typeCellDelegate = new HashMap<>();
        }
        typeCellDelegate.put(values[0].toJavaString(), values[1].toLuaFunction());
        return null;
    }

    /**
     * (function(cell)) Header是否开启
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] headerValid(LuaValue[] values) {
        headerValidDelegate = values[0].toLuaFunction();

        return null;
    }

    /**
     * (function(cell)) Header类型初始化view的函数
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] initHeader(LuaValue[] values) {
        initHeaderDelegate = values[0].toLuaFunction();

        return null;
    }

    /**
     * (fuction(cell,section,row)) 设置Header类型
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] fillHeaderData(LuaValue[] values) {
        bindHeaderDelegate = values[0].toLuaFunction();

        return null;
    }

    protected void initWaterFallHeader() {
        if (headerValidDelegate != null) {
            LuaValue[] values = headerValidDelegate.invoke(null);
            boolean valid = (values != null && values.length > 0 && values[0].isBoolean()) && values[0].toBoolean();

            if (valid) {
                if (mAdapter != null && mAdapter.getHeaderCount() == 0) {
                    mAdapter.addHeaderView(new FrameLayout(getContext()));
                }
                return;
            }
            if (mAdapter.getHeaderCount() > 0) {//两端协定，waterFall只能有一个header，所以可以removeAllHeader
                mAdapter.removeAllHeaderView();
            }
        }
    }

    /**
     * (fuction(cell,section,row)) 设置普通类型
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] fillCellData(LuaValue[] values) {
        bindDataDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * ('type',fuction(cell,section,row)) 设置普通类型
     * <p>
     * id
     * fun
     */
    @LuaApiUsed
    public LuaValue[] fillCellDataByReuseId(LuaValue[] values) {
        if (bindTypeDataDelegate == null) {
            bindTypeDataDelegate = new HashMap<>();
        }
        bindTypeDataDelegate.put(values[0].toJavaString(), values[1].toLuaFunction());
        return null;
    }

    /**
     * (function()) 返回由多少组多数
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] sectionCount(LuaValue[] values) {
        sectionCountDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * (function(section)) 返回某组有多少数据
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] rowCount(LuaValue[] values) {
        rowCountDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * (function(cell,section,row)) 普通item的点击事件
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] selectedRow(LuaValue[] values) {
        clickDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * (function(cell,section,row)) 普通item的 长按 事件
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] longPressRow(LuaValue[] values) {
        clickLongDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * ('type',function(cell,section,row)) 特殊item的点击事件，设置后，没找到的type报错
     * <p>
     * id
     * fun
     */
    @LuaApiUsed
    public LuaValue[] selectedRowByReuseId(LuaValue[] values) {
        if (typeClickDelegate == null) {
            typeClickDelegate = new HashMap<>();
        }
        typeClickDelegate.put(values[0].toJavaString(), values[1].toLuaFunction());
        return null;
    }

    /**
     * ('type',function(cell,section,row)) 特殊item的长按事件，设置后，没找到的type报错
     * <p>
     * id
     * fun
     */
    @LuaApiUsed
    public LuaValue[] longPressRowByReuseId(LuaValue[] values) {
        if (typeLongClickDelegate == null) {
            typeLongClickDelegate = new HashMap<>();
        }
        typeLongClickDelegate.put(values[0].toJavaString(), values[1].toLuaFunction());
        return null;
    }

    /**
     * 点击了编辑栏
     * IOS only
     */
    @LuaApiUsed
    public LuaValue[] editAction(LuaValue[] values) {
        return null;
    }

    /**
     * 返回针对某cell的事件配置
     * IOS only
     */
    @LuaApiUsed
    public LuaValue[] editParam(LuaValue[] values) {
        return null;
    }

    /**
     * Callback(cell, section, row) item即将消失时回调
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] cellDidDisappear(LuaValue[] values) {
        this.cellDisappearDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * ('type',Callback(cell, section, row))item显示时回调，设置后，没找到的type报错
     */
    @LuaApiUsed
    public LuaValue[] cellDidDisappearByReuseId(LuaValue[] values) {
        if (cellDisappearTypeDelegate == null) {
            cellDisappearTypeDelegate = new HashMap<>();
        }
        cellDisappearTypeDelegate.put(values[0].toJavaString(), values[1].toLuaFunction());
        return null;
    }

    /**
     * Callback(cell, section, row) item显示时回调
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] cellWillAppear(LuaValue[] values) {
        cellAppearDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * ('type',Callback(cell, section, row))item显示时回调，设置后，没找到的type报错
     */
    @LuaApiUsed
    public LuaValue[] cellWillAppearByReuseId(LuaValue[] values) {
        if (cellAppearTypeDelegate == null) {
            cellAppearTypeDelegate = new HashMap<>();
        }
        cellAppearTypeDelegate.put(values[0].toJavaString(), values[1].toLuaFunction());
        return null;
    }

    /**
     * header消失时回调
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] headerDidDisappear(LuaValue[] values) {
        headerDisappearDelegate = values[0].toLuaFunction();
        return null;
    }

    /**
     * header显示时回调
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] headerWillAppear(LuaValue[] values) {
        headerAppearDelegate = values[0].toLuaFunction();
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="adapter 调用">
    public long getItemId(int pos) {
        return itemIDGenerator.getIdBy(pos, getViewType(pos));
    }

    /**
     * 获取某个位置的type
     * <p>
     * position
     *
     * @return
     */
    public int getViewType(int position) {
        String id = getReuseId(position);
        if (recycledViewPoolIdGenerator != null) {
            return recycledViewPoolIdGenerator.getViewTypeForReuseId(id);
        }
        return idGenerator.getViewTypeForReuseId(id);
    }

    public @Nullable
    View.OnClickListener getClickListener(final LuaValue cell, final int position) {
        if (clickDelegate == null && typeClickDelegate == null)
            return null;
        if (viewClickCache == null) {
            viewClickCache = new SparseArray<>();
        }
        View.OnClickListener ret = viewClickCache.get(position);
        if (ret != null) {
            if (ret instanceof ClickHelper) {
                ((ClickHelper) ret).updataListener(cell, position);
            }
            return ret;
        }
        ret = new ClickListener(cell, position);
        viewClickCache.put(position, ret);
        return ret;
    }

    public @Nullable
    View.OnLongClickListener getLongClickListener(final LuaValue cell, final int position) {
        if (clickLongDelegate == null && typeLongClickDelegate == null)
            return null;

        if (viewLongClickCache == null) {
            viewLongClickCache = new SparseArray<>();
        }

        View.OnLongClickListener ret = viewLongClickCache.get(position);
        if (ret != null) {
            if (ret instanceof ClickHelper) {
                ((ClickHelper) ret).updataListener(cell, position);
            }
            return ret;
        }

        ret = new LongClickListener(cell, position);
        viewLongClickCache.put(position, ret);
        return ret;
    }


    /**
     * 检查view是否初始化成功
     *
     * @return
     */
    public boolean checkCanDoBind() {
        if (viewWidth == 0 || viewHeight == 0) {
            notifyWhenViewSizeInit = true;
            return true;
        }
        return false;
    }

    /**
     * 是否定义了size相关函数
     *
     * @return
     */
    public abstract boolean hasCellSize();

    /**
     * 若定义了size相关函数，获取size
     * called when {@link #hasCellSize} return true
     * <p>
     * position
     *
     * @return
     */
    public abstract @NonNull
    Size getCellSize(int position);

    /**
     * 若定义了Header相关函数，获取header的高
     * <p>
     * position
     *
     * @return
     */
    public abstract @NonNull
    Size getHeaderSize(int position);

    /**
     * cell初始化的时候给出宽高
     * <p>
     * type
     *
     * @return
     */
    public abstract @NonNull
    Size getInitCellSize(int type);

    /**
     * adapter调用获取所有item个数
     *
     * @return
     */
    public int getTotalCount() {
        if (allCount != null) {
            int r = allCount.get();
            if (r >= 0)
                return r;
        }
        initSection();
        return allCount.get();
    }

    /**
     * adapter onCreateViewHolder时调用
     * <p> 两端统一，initCell和initCellByReuseId,可以混用。
     * 两端统一，initCell必须声明，否则报错
     * cell
     * viewType
     */
    public void callInitCell(LuaValue cell, int viewType) {
        LuaFunction delegate = null;
        if (typeCellDelegate != null) {
            String id = getReuseIdByType(viewType);
            delegate = typeCellDelegate.get(id);
        }
        if (delegate == null) {
            delegate = initCellDelegate;
        }
        if (globals.isDestroyed()) {
            return;
        }
        if (!AssertUtils.assertFunction(delegate, "必须通过initCell将函数设置到adapter中", getGlobals()))
            return;
        delegate.invoke(varargsOf(cell));
    }

    /**
     * adapter onCreateViewHolder时调用
     * 两端统一，init不声明报错
     * cell
     * viewType
     */
    public void callInitHeader(LuaValue cell) {
        LuaFunction delegate;
        delegate = initHeaderDelegate;
        if (delegate != null) {
            delegate.invoke(varargsOf(cell));
        } else {
            ErrorUtils.debugLuaError("initHeader callback must not be nil!", globals);
        }
    }

    public void callFillDataHeader(LuaValue cell, int position) {
        LuaFunction delegate;
        delegate = bindHeaderDelegate;
        if (delegate != null) {//fillHeader，不声明不用报错
            delegate.invoke(varargsOf(cell, toLuaInt(1), toLuaInt(position)));
        }
    }

    //判断新版Header是否可用(新版支持init,fill，heightforHeader)
    public boolean isNewHeaderValid() {
        if (headerValidDelegate != null) {
            LuaValue[] values = headerValidDelegate.invoke(null);
            return values.length > 0 && values[0].toBoolean();
        }
        return false;
    }

    public void callFillDataCell(LuaValue cell, int position) {
        LuaFunction delegate = null;
        if (bindTypeDataDelegate != null) {
            delegate = bindTypeDataDelegate.get(getReuseId(position));
        }
        if (delegate == null) {
            delegate = bindDataDelegate;
        }
        if (delegate != null) {
            int[] sr = getSectionAndRowIn(position);
            delegate.invoke(varargsOf(cell, toLuaInt(sr[0]), toLuaInt(sr[1])));
        }
    }

    public @NonNull
    abstract ViewGroup.LayoutParams newLayoutParams(ViewGroup.LayoutParams p, boolean fullSpan);

    public void callCellDisappear(ViewHolder holder) {
        if (cellDisappearDelegate == null && headerDisappearDelegate == null && cellDisappearTypeDelegate == null)
            return;
        int pos = holder.getAdapterPosition();
        int sc = mAdapter.getHeaderCount();

        if (pos == RecyclerView.NO_POSITION) {
            if (holder.getCell() == null && headerDisappearDelegate != null) {
                headerDisappearDelegate.invoke(null);
                return;
            }

            String reuseId = idGenerator.getReuseIdByType(holder.getItemViewType());
            LuaFunction delegate = null;
            if (cellDisappearTypeDelegate != null) {
                delegate = cellDisappearTypeDelegate.get(reuseId);
            }
            if (delegate == null && cellDisappearDelegate != null) {
                delegate = cellDisappearDelegate;
            }

            //Returns the position of the ViewHolder in terms of the latest layout pass.
            //mPreLayoutPosition == NO_POSITION ? mPosition : mPreLayoutPosition;
            //下拉刷新时，cell的pos会被新的cell获取，变成NO_POSITION状态。这时通过getLayoutPosition()获取上一次的pos
            if (delegate != null) {
                int[] sr = getSectionAndRowIn(holder.getLayoutPosition() - sc);
                if (sr == null)
                    return;
                delegate.invoke(varargsOf(holder.getCell(), toLuaInt(sr[0]), toLuaInt(sr[1])));
            }

            return;
        }

        if (pos < sc) {
            if (headerDisappearDelegate != null) {
                headerDisappearDelegate.invoke(null);
            }
            return;
        }

        LuaFunction delegate = null;
        int position = pos - sc;
        if (cellDisappearTypeDelegate != null) {
            delegate = cellDisappearTypeDelegate.get(getReuseId(position));
        }
        if (delegate == null && cellDisappearDelegate != null) {
            delegate = cellDisappearDelegate;
        }

        if (delegate != null) {
            int[] sr = getSectionAndRowIn(position);
            if (sr == null)
                return;
            delegate.invoke(varargsOf(holder.getCell(), toLuaInt(sr[0]), toLuaInt(sr[1])));
        }
    }

    public void callCellAppear(ViewHolder holder) {
        if (cellAppearDelegate == null && headerAppearDelegate == null && cellAppearTypeDelegate == null)
            return;
        int sc = mAdapter.getHeaderCount();
        int pos = holder.getAdapterPosition();
        if (pos < sc) {
            if (headerAppearDelegate != null) {
                headerAppearDelegate.invoke(null);
            }
            return;
        }

        LuaFunction delegate = null;
        int position = pos - sc;
        if (cellAppearTypeDelegate != null) {
            delegate = cellAppearTypeDelegate.get(getReuseId(position));
        }
        if (delegate == null && cellAppearDelegate != null) {
            delegate = cellAppearDelegate;
        }

        if (delegate != null) {
            int[] sr = getSectionAndRowIn(position);
            if (sr == null)
                return;
            delegate.invoke(varargsOf(holder.getCell(), toLuaInt(sr[0]), toLuaInt(sr[1])));
        }
    }
    //</editor-fold>

    //<editor-fold desc="refresh">
    protected void notifyItemChanged(int index) {
        Adapter a = getAdapter();
        a.notifyItemChanged(index + a.getHeaderCount());
        onClearFromIndex(index);
    }

    protected void notifyItemRangeChanged(int start, int count) {
        Adapter a = getAdapter();
        a.notifyItemRangeChanged(start + a.getHeaderCount(), count);
        onClearFromIndex(start);
    }

    protected void notifyItemRemoved(int start) {
        Adapter a = getAdapter();
        a.notifyItemRemoved(start + a.getHeaderCount());
        onClearFromIndex(start);
    }

    protected void notifyItemRangeRemoved(int start, int count) {
        Adapter a = getAdapter();
        a.notifyItemRangeRemoved(start + a.getHeaderCount(), count);
        onClearFromIndex(start);
    }

    protected void notifyItemInserted(int index) {
        Adapter a = getAdapter();
        a.notifyItemInserted(index + a.getHeaderCount());
        onClearFromIndex(index);
    }

    protected void notifyItemRangeInserted(int index, int count) {
        Adapter a = getAdapter();
        a.notifyItemRangeInserted(index + a.getHeaderCount(), count);
        onClearFromIndex(index);
    }
    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="section and row">
    private int[] getSectionInfo(AtomicInteger allCountOut) {
        if (rowCountDelegate == null || rowCountDelegate.isNil())
            return null;
        int sectionCount = 0;
        if (sectionCountDelegate != null && sectionCountDelegate.isFunction()) {
            LuaValue[] rets = sectionCountDelegate.invoke(null);

            final LuaValue sv;
            if (rets == null || rets.length == 0) {
                sv = Nil();
            } else {
                sv = rets[0];
            }
            if (AssertUtils.assertNumber(sv, sectionCountDelegate, getGlobals())) {
                sectionCount = sv.toInt();
            }
        } else {
            sectionCount = 1;
        }
        if (sectionCount <= 0) {
            if (MLSEngine.DEBUG) {
                IllegalArgumentException e = new IllegalArgumentException("section count must bigger than 0, return " + sectionCount);
                if (!Environment.hook(e, getGlobals())) {
                    throw e;
                }
            }
            sectionCount = 1;
        }
        int resultCount = sectionCount << 1;
        int[] result = new int[resultCount];
        int allCount = 0;
        for (int i = 0; i < resultCount; i += 2) {
            LuaValue[] rets = rowCountDelegate.invoke(varargsOf(toLuaInt(i >> 1)));
            final LuaValue rc;
            if (rets == null || rets.length == 0) {
                rc = Nil();
            } else {
                rc = rets[0];
            }
            result[i] = allCount;
            if (AssertUtils.assertNumber(rc, rowCountDelegate, getGlobals()))
                allCount += rc.toInt();
            result[i + 1] = allCount;
        }
        if (allCountOut != null)
            allCountOut.set(allCount);
        return result;
    }

    protected int[] getSectionAndRowIn(int pos) {

        if (sections == null)
            return null;

        int sc = sections.length;

        for (int i = 0; i < sc; i += 2) {
            int offset = pos - sections[i];

            if (offset >= 0 && pos < sections[i + 1]) {
                return new int[]{i >> 1, offset};
            }

        }

        return null;
    }

    protected String getReuseId(int position) {
        if (reuseIdCache != null) {
            String id = reuseIdCache.get(position);
            if (id != null)
                return id;
        }
        if (reuseIdDelegate != null && !reuseIdDelegate.isNil()) {
            int[] sr = getSectionAndRowIn(position);
            if (sr == null) {
                return null;
            }
            LuaValue[] lr = reuseIdDelegate.invoke(varargsOf(toLuaInt(sr[0]), toLuaInt(sr[1])));
            LuaValue v = lr != null && lr.length > 0 ? lr[0] : Nil();//不return，返回null
            String result;
            if (AssertUtils.assertString(v, reuseIdDelegate, getGlobals())) {
                result = v.toJavaString();
            } else {
                result = v.toString();
            }

            if (MLSEngine.DEBUG && "".equals(result)) {//统一报错，reuseid不能为""
                IllegalArgumentException e = new IllegalArgumentException("reuseId  can`t be ”“");
                if (!Environment.hook(e, getGlobals())) {
                    throw e;
                }
            }

            if (reuseIdCache == null) {
                reuseIdCache = new SparseArray<>();
            }
            reuseIdCache.put(position, result);
            return result;
        }
        return null;
    }

    public String getReuseIdByType(int type) {
        if (recycledViewPoolIdGenerator != null) {
            return recycledViewPoolIdGenerator.getReuseIdByType(type);
        }
        return idGenerator.getReuseIdByType(type);
    }

    public int getPositionBySectionAndRow(int section, int row) {
        if (!checkSectionInitStatus())
            return 0;
        int count = sections.length;
        int index = section << 1;

        if (index >= count) {
            if (MLSEngine.DEBUG) {
                IndexOutOfBoundsException e = new IndexOutOfBoundsException("section over the source data");
                if (!Environment.hook(e, getGlobals()))
                    throw e;
            }
            return 0;
        }

        if (MLSEngine.DEBUG && (row >= (sections[index + 1] - sections[index]) || row < 0)) {
            IndexOutOfBoundsException e = new IndexOutOfBoundsException("row  = " + row + "  IndexOutOfBoundsException ");
            if (!Environment.hook(e, getGlobals()))
                throw e;
        }

        return sections[index] + row;
    }

    protected boolean checkSectionInitStatus() {
        return sections != null && allCount.get() >= 0;
    }
    //</editor-fold>

    private void initSection() {
        if (allCount == null)
            allCount = new AtomicInteger();
        allCount.set(-1);
        sections = getSectionInfo(allCount);
    }

    //<editor-fold desc="Protected">
    protected static void removeSparseArrayFromStart(SparseArray array, int start) {
        if (array == null)
            return;
        for (int i = start, l = array.size(); i < l; i++) {
            array.removeAt(i);
        }
    }

    protected static LuaValue toLuaInt(int i) {
        return LuaNumber.valueOf(i + 1);
    }

    /**
     * 局部刷新插入删除时调用
     * <p>
     * index
     */
    @CallSuper
    protected void onClearFromIndex(int index) {
        removeSparseArrayFromStart(viewClickCache, index);
        removeSparseArrayFromStart(reuseIdCache, index);
        itemIDGenerator.removeIdBy(index);
    }

    /**
     * 刷新整个view时调用
     */
    @CallSuper
    protected void onReload() {
        if (viewClickCache != null) {
            viewClickCache.clear();
        }
        if (reuseIdCache != null) {
            reuseIdCache.clear();
        }
        itemIDGenerator.clear();
        /*if (viewTypeIdCache != null) {
            viewTypeIdCache.clear();
        }
        if (viewTypeCache != null) {
            viewTypeCache.clear();
        }*/
        initWaterFallHeader();
        reLayoutInSet();
    }

    protected void onLayoutSet(L layout) {

    }

    protected void onOrientationChanged() {

    }

    public void onFooterAdded(boolean added) {
        if (layout != null) {
            layout.onFooterAdded(added);
        }
    }

    ;//footer加载栏添加回调


    //</editor-fold>

    //<editor-fold desc="OnLoadListener">
    @Override
    public void onLoad() {
        if (onLoadListener != null)
            onLoadListener.onLoad();
    }

    public void setRecycledViewPoolIDGenerator(IDGenerator idGenerator) {
        this.recycledViewPoolIdGenerator = idGenerator;
    }
    //</editor-fold>

    /**
     * 全局刷新时，重新设置layoutInset
     */
    private void reLayoutInSet() {
        if (layout instanceof ILayoutInSet) {//修复原CollectionViewGridLayout 两端差异
            if (mRecyclerView instanceof IRefreshRecyclerView) {
                RecyclerView recyclerView = ((IRefreshRecyclerView) mRecyclerView).getRecyclerView();
                setMarginForVerticalGridLayout(recyclerView);
            }
        }
    }

    // 针对 纵向且 网格布局，进行Padding设置，为了配合 CollectionViewGridLayoutNew 的layoutinset。
    // 比如当 一排展示3个格子，但是格子间距是0，recyclerview左右二测有边距时，仅仅通过itemdecoration是无法让每个格子从预设位置开始布局，
    protected void setMarginForVerticalGridLayout(RecyclerView recyclerView) {
        int paddingValues[] = ((ILayoutInSet) layout).getPaddingValues();
        if (paddingValues[0] > 0 || paddingValues[1] > 0 || paddingValues[2] > 0 || paddingValues[3] > 0) {
//                recyclerView.setClipToPadding(false);
        }

        if (layout instanceof UDCollectionLayout) {//grid布局layoutInSet {@link GridLayoutItemDecoration}
            if (layout.orientation == RecyclerView.VERTICAL) {//bottom为0，是因为Footer也是个cell，需要特殊处理spacing
                recyclerView.setPadding(paddingValues[0] - layout.getItemSpacingPx(), paddingValues[1], paddingValues[2] - layout.getItemSpacingPx(), 0);
            } else {
                recyclerView.setPadding(paddingValues[0], paddingValues[1] - layout.getlineSpacingPx(), 0, paddingValues[3] - layout.getlineSpacingPx());
            }
        } else if (layout instanceof UDWaterFallLayout) {//瀑布流布局layoutInSet, outRect.left = horizontalSpace / 2
            recyclerView.setPadding(paddingValues[0] - layout.getItemSpacingPx() / 2, paddingValues[1], paddingValues[2] - layout.getItemSpacingPx() / 2, 0);
        }
    }

    private final class ClickListener implements View.OnClickListener, ClickHelper {
        private int position;
        private LuaValue cell;

        ClickListener(LuaValue cell, int position) {
            this.position = position;
            this.cell = cell;
        }

        @Override
        public void updataListener(LuaValue cell, int position) {
            this.position = position;
            this.cell = cell;
        }

        @Override
        public void onClick(View v) {
            if (!canDoClick())
                return;
            LuaFunction delegate = null;
            if (typeClickDelegate != null) {
                delegate = typeClickDelegate.get(getReuseId(position));
            }
            if (delegate == null) {
                delegate = clickDelegate;
            }
            if (delegate != null) {
                int[] sr = getSectionAndRowIn(position);
                delegate.invoke(varargsOf(cell, toLuaInt(sr[0]), toLuaInt(sr[1])));
            }
        }

    }


    private final class LongClickListener implements View.OnLongClickListener, ClickHelper {
        private int position;
        private LuaValue cell;

        LongClickListener(LuaValue cell, int position) {
            this.position = position;
            this.cell = cell;
        }

        @Override
        public void updataListener(LuaValue cell, int position) {
            this.position = position;
            this.cell = cell;
        }

        @Override
        public boolean onLongClick(View view) {

            if (!canDoClick())
                return true;

            LuaFunction delegate = null;
            if (typeLongClickDelegate != null) {
                delegate = typeLongClickDelegate.get(getReuseId(position));
            }
            if (delegate == null)
                delegate = clickLongDelegate;

            if (delegate != null) {
                int[] sr = getSectionAndRowIn(position);
                delegate.invoke(varargsOf(cell, toLuaInt(sr[0]), toLuaInt(sr[1])));
            }

            return true;
        }

    }

    private interface ClickHelper {
        void updataListener(LuaValue cell, int position);
    }

    private boolean canDoClick() {
        LuaViewManager m = (LuaViewManager) getGlobals().getJavaUserdata();
        MLSInstance instance = m != null ? m.instance : null;
        if (instance != null) {
            return instance.getClickEventLimiter().canDoClick();
        }
        return true;
    }
}