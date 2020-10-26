/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.content.Context;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.Environment;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.MLSInstance;
import com.immomo.mls.fun.other.Size;
import com.immomo.mmui.ud.AdapterLuaFunction;
import com.immomo.mmui.ud.UDColor;
import com.immomo.mls.fun.ui.IRefreshRecyclerView;
import com.immomo.mls.fun.ui.OnLoadListener;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.weight.load.ILoadViewDelegete;

import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed
public abstract class UDBaseRecyclerAdapter<L extends UDBaseRecyclerLayout> extends JavaUserdata implements OnLoadListener {
    public static final String LUA_CLASS_NAME = "__BaseRecyclerAdapter";
    //(section,row) 返回不同类型的id 字符串
    private AdapterLuaFunction reuseIdDelegate;
    // 普通类型初始化view的函数
    private LuaFunction initCellDelegate;
    //type类型初始化view的函数，若设置，则没有找到的type直接报错
    private Map<String, LuaFunction> typeCellDelegate;
    //(cell,section,row) 设置普通类型
    private AdapterLuaFunction bindDataDelegate;
    //(cell,section,row) 设置普通类型，若设置，则没有找到的type直接报错
    private Map<String, AdapterLuaFunction> bindTypeDataDelegate;
    // Header是否开启
    private AdapterLuaFunction headerValidDelegate;
    // Header类型初始化view的函数
    private LuaFunction initHeaderDelegate;
    //(cell,section,row) 设置Header类型
    private AdapterLuaFunction bindHeaderDelegate;
    //返回由多少组多数
    private AdapterLuaFunction sectionCountDelegate;
    //(section) 返回某组有多少数据
    private AdapterLuaFunction rowCountDelegate;

    //(cell,section,row) 普通item的点击事件
    private AdapterLuaFunction clickDelegate;

    //(cell,section,row) 普通item的 长按事件
    private AdapterLuaFunction clickLongDelegate;

    //(cell,section,row) 特殊item的点击事件，设置后，没找到的type报错
    private Map<String, AdapterLuaFunction> typeClickDelegate;

    //(cell,section,row) 特殊item的长按事件，设置后，没找到的type报错
    private Map<String, AdapterLuaFunction> typeLongClickDelegate;


    //(cell, section, row) item即将消失时回调
    private AdapterLuaFunction cellDisappearDelegate;
    private Map<String, AdapterLuaFunction> cellDisappearTypeDelegate;
    //Callback(cell, section, row)
    private AdapterLuaFunction cellAppearDelegate;
    private Map<String, AdapterLuaFunction> cellAppearTypeDelegate;
    //header消失时回调
    private LuaFunction headerDisappearDelegate;
    //header显示时回调
    private LuaFunction headerAppearDelegate;
    //点击cell后高亮
    public boolean showPressed = false;
    //点击后的高亮颜色
    public int pressedColor;
    private boolean pressedColorSet = false;

    private UDColor returnColor;

    private static final int DEFAULT_PRESSED_COLOR = 0xFFD3D3D3;
    DefaultItemAnimator mDefaultItemAnimator;
    /**
     * 长度除以2为section个数
     * 偶数下标为开始位置（包含）
     * 奇数下标为结束位置（不包含）
     * 相减为改组长度
     */
    private int[] sections;
    private AtomicInteger allCount;
    /**
     * 所有id缓存，reload的时候清除
     */
    private SparseArray<String> reuseIdCache;

    private final IDGenerator idGenerator;
    private IDGenerator recycledViewPoolIdGenerator;

    protected ILoadViewDelegete loadViewDelegete;
    private OnLoadListener onLoadListener;

    private Adapter mAdapter;

    protected L layout;

    protected int viewWidth;
    protected int viewHeight;

    private boolean reloadWhenViewSizeInit = false;
    private boolean notifyWhenViewSizeInit = false;
    protected int orientation = RecyclerView.VERTICAL;
    protected View mRecyclerView;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDBaseRecyclerAdapter(long L) {
        super(L, null);
        idGenerator = new IDGenerator();
        pressedColor = DEFAULT_PRESSED_COLOR;
        pressedColorSet = false;
    }
    public static native void _init();
    public static native void _register(long l, String parent);

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

    public boolean hasClickFor(int type) {
        if (clickDelegate != null)
            return true;
        return typeClickDelegate != null && typeClickDelegate.get(getReuseIdByType(type)) != null;
    }

    public boolean hasLongClickFor(int type) {
        if (clickLongDelegate != null)
            return true;
        return typeLongClickDelegate != null && typeLongClickDelegate.get(getReuseIdByType(type)) != null;
    }

    public void doCellClick(LuaValue cell, int position) {
        if (!canDoClick())
            return;
        AdapterLuaFunction delegate = null;
        if (typeClickDelegate != null) {
            delegate = typeClickDelegate.get(getReuseId(position));
        }
        if (delegate == null) {
            delegate = clickDelegate;
        }
        if (delegate != null) {
            int[] sr = getSectionAndRowIn(position);
            delegate.fastInvoke(cell, sr[0] + 1, sr[1] + 1);
        }
    }

    public boolean doCellLongClick(LuaValue cell, int position) {
        if (!canDoClick())
            return true;

        AdapterLuaFunction delegate = null;
        if (typeLongClickDelegate != null) {
            delegate = typeLongClickDelegate.get(getReuseId(position));
        }
        if (delegate == null)
            delegate = clickLongDelegate;

        if (delegate != null) {
            int[] sr = getSectionAndRowIn(position);
            delegate.fastInvoke(cell, sr[0] + 1, sr[1] + 1);
        }

        return true;
    }
    //</editor-fold>

    //<editor-fold desc="API">

    @LuaApiUsed
    public boolean isShowPressed() {
        return showPressed;
    }

    @LuaApiUsed
    public void setShowPressed(boolean showPressed) {
        this.showPressed = showPressed;
        if (mAdapter != null) {
            mAdapter.notifyDataSetChanged();
        }
    }

    @LuaApiUsed
    public UDColor getPressedColor() {
        if (returnColor == null) {
            returnColor = new UDColor(globals, pressedColor);
            returnColor.onJavaRef();
        }
        returnColor.setColor(pressedColor);
        return returnColor;
    }

    @LuaApiUsed
    public void setPressedColor(UDColor color) {
        if (color == null) {
            pressedColor = DEFAULT_PRESSED_COLOR;
            pressedColorSet = false;
        } else {
            pressedColor = color.getColor();
            pressedColorSet = true;
        }
        if (mAdapter != null) {
            mAdapter.notifyDataSetChanged();
        }
    }

    /**
     * (string:function(section,row)) 返回不同类型的id 字符串
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void reuseId(long f) {
        if (f == 0)
            reuseIdDelegate = null;
        else
            reuseIdDelegate = new AdapterLuaFunction(globals, f);
    }

    /**
     * (function(cell)) 普通类型初始化view的函数
     * <p>
     * fun
     */
    @LuaApiUsed
    public void initCell(LuaFunction f) {
        initCellDelegate = f;
    }

    /**
     * ('type', fuction(cell)) type类型初始化view的函数，优先级比setViewInit高
     * <p>
     * id
     * fun
     */
    @LuaApiUsed
    public void initCellByReuseId(String t, LuaFunction f) {
        if (typeCellDelegate == null) {
            typeCellDelegate = new HashMap<>();
        }
        typeCellDelegate.put(t, f);
    }

    /**
     * (boolean:function(cell)) Header是否开启
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void headerValid(long f) {
        if (f == 0)
            headerValidDelegate = null;
        else
        headerValidDelegate = new AdapterLuaFunction(globals, f);
    }

    /**
     * (function(cell)) Header类型初始化view的函数
     * <p>
     * fun
     */
    @LuaApiUsed
    public void initHeader(LuaFunction f) {
        initHeaderDelegate = f;
    }

    /**
     * (fuction(cell,section,row)) 设置Header类型
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void fillHeaderData(long f) {
        if (f == 0)
            bindHeaderDelegate = null;
        else
        bindHeaderDelegate = new AdapterLuaFunction(globals, f);
    }

    protected void initWaterFallHeader() {
        if (headerValidDelegate != null) {
            boolean valid = headerValidDelegate.fastInvoke_Z();
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
    @CGenerate(params = "F")
    @LuaApiUsed
    public void fillCellData(long f) {
        if (f == 0)
            bindDataDelegate = null;
        else
        bindDataDelegate = new AdapterLuaFunction(globals, f);
    }

    /**
     * ('type',fuction(cell,section,row)) 设置普通类型
     * <p>
     * id
     * fun
     */
    @CGenerate(params = "0F")
    @LuaApiUsed
    public void fillCellDataByReuseId(String t, long f) {
        if (bindTypeDataDelegate == null) {
            bindTypeDataDelegate = new HashMap<>();
        }
        if (f == 0)
            bindTypeDataDelegate.put(t, null);
        else
        bindTypeDataDelegate.put(t, new AdapterLuaFunction(globals, f));
    }

    /**
     * (int:function()) 返回由多少组多数
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void sectionCount(long f) {
        if (f == 0)
            sectionCountDelegate = null;
        else
        sectionCountDelegate = new AdapterLuaFunction(globals, f);
    }

    /**
     * (int:function(section)) 返回某组有多少数据
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void rowCount(long f) {
        if (f == 0)
            rowCountDelegate = null;
        else
            rowCountDelegate = new AdapterLuaFunction(globals, f);
    }

    /**
     * (function(cell,section,row)) 普通item的点击事件
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void selectedRow(long f) {
        if (f == 0)
            clickDelegate = null;
        else
        clickDelegate = new AdapterLuaFunction(globals, f);
    }

    /**
     * (function(cell,section,row)) 普通item的 长按 事件
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void longPressRow(long f) {
        if (f == 0)
            clickLongDelegate = null;
        else
        clickLongDelegate = new AdapterLuaFunction(globals, f);
    }

    /**
     * ('type',function(cell,section,row)) 特殊item的点击事件，设置后，没找到的type报错
     * <p>
     * id
     * fun
     */
    @CGenerate(params = "0F")
    @LuaApiUsed
    public void selectedRowByReuseId(String t, long f) {
        if (typeClickDelegate == null) {
            typeClickDelegate = new HashMap<>();
        }
        if (f == 0)
            typeClickDelegate.put(t, null);
        else
        typeClickDelegate.put(t, new AdapterLuaFunction(globals, f));
    }

    /**
     * ('type',function(cell,section,row)) 特殊item的长按事件，设置后，没找到的type报错
     * <p>
     * id
     * fun
     */
    @CGenerate(params = "0F")
    @LuaApiUsed
    public void longPressRowByReuseId(String t, long f) {
        if (typeLongClickDelegate == null) {
            typeLongClickDelegate = new HashMap<>();
        }
        if (f == 0)
            typeLongClickDelegate.put(t, null);
        else
        typeLongClickDelegate.put(t, new AdapterLuaFunction(globals, f));
    }

    /**
     * 点击了编辑栏
     * IOS only
     */
    @LuaApiUsed
    public void editAction() {
    }

    /**
     * 返回针对某cell的事件配置
     * IOS only
     */
    @LuaApiUsed
    public void editParam() {
    }

    /**
     * Callback(cell, section, row) item即将消失时回调
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void cellDidDisappear(long f) {
        if (f == 0)
            cellDisappearDelegate = null;
        else
        this.cellDisappearDelegate = new AdapterLuaFunction(globals, f);
    }

    /**
     * ('type',Callback(cell, section, row))item显示时回调，设置后，没找到的type报错
     */
    @CGenerate(params = "0F")
    @LuaApiUsed
    public void cellDidDisappearByReuseId(String t, long f) {
        if (cellDisappearTypeDelegate == null) {
            cellDisappearTypeDelegate = new HashMap<>();
        }
        if (f == 0)
            cellDisappearTypeDelegate.put(t, null);
        else
        cellDisappearTypeDelegate.put(t, new AdapterLuaFunction(globals, f));
    }

    /**
     * Callback(cell, section, row) item显示时回调
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void cellWillAppear(long f) {
        if (f == 0)
            cellAppearDelegate = null;
        else
        cellAppearDelegate = new AdapterLuaFunction(globals, f);
    }

    /**
     * ('type',Callback(cell, section, row))item显示时回调，设置后，没找到的type报错
     */
    @CGenerate(params = "0F")
    @LuaApiUsed
    public void cellWillAppearByReuseId(String t, long f) {
        if (cellAppearTypeDelegate == null) {
            cellAppearTypeDelegate = new HashMap<>();
        }
        if (f == 0)
            cellAppearTypeDelegate.put(t, null);
        else
        cellAppearTypeDelegate.put(t, new AdapterLuaFunction(globals, f));
    }

    /**
     * header消失时回调 (function())
     * <p>
     * fun
     */
    @LuaApiUsed
    public void headerDidDisappear(LuaFunction f) {
        headerDisappearDelegate = f;
    }

    /**
     * header显示时回调 (function())
     * <p>
     * fun
     */
    @LuaApiUsed
    public void headerWillAppear(LuaFunction f) {
        headerAppearDelegate = f;
    }
    //</editor-fold>

    //<editor-fold desc="adapter 调用">
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
        delegate.fastInvoke(cell);
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
            delegate.fastInvoke(cell);
        } else {
            ErrorUtils.debugLuaError("initHeader callback must not be nil!", globals);
        }
    }

    public void callFillDataHeader(LuaValue cell, int position) {
        if (bindHeaderDelegate != null) {//fillHeader，不声明不用报错
            bindHeaderDelegate.fastInvoke(cell, 2, position + 1);
        }
    }

    //判断新版Header是否可用(新版支持init,fill，heightforHeader)
    public boolean isNewHeaderValid() {
        if (headerValidDelegate != null) {
            return headerValidDelegate.fastInvoke_Z();
        }
        return false;
    }

    public void callFillDataCell(LuaValue cell, int position) {
        AdapterLuaFunction delegate = null;
        if (bindTypeDataDelegate != null) {
            delegate = bindTypeDataDelegate.get(getReuseId(position));
        }
        if (delegate == null) {
            delegate = bindDataDelegate;
        }
        if (delegate != null) {
            int[] sr = getSectionAndRowIn(position);
            delegate.fastInvoke(cell, sr[0] + 1, sr[1] + 1);
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
                headerDisappearDelegate.fastInvoke();
                return;
            }

            String reuseId = idGenerator.getReuseIdByType(holder.getItemViewType());
            AdapterLuaFunction delegate = null;
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
                delegate.fastInvoke(holder.getCell(), sr[0] + 1, sr[1] + 1);
            }

            return;
        }

        if (pos < sc) {
            if (headerDisappearDelegate != null) {
                headerDisappearDelegate.fastInvoke();
            }
            return;
        }

        AdapterLuaFunction delegate = null;
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
            delegate.fastInvoke(holder.getCell(), sr[0] + 1, sr[1] + 1);
        }
    }

    public void callCellAppear(ViewHolder holder) {
        if (cellAppearDelegate == null && headerAppearDelegate == null && cellAppearTypeDelegate == null)
            return;
        int sc = mAdapter.getHeaderCount();
        int pos = holder.getAdapterPosition();
        if (pos < sc) {
            if (headerAppearDelegate != null) {
                headerAppearDelegate.fastInvoke();
            }
            return;
        }

        AdapterLuaFunction delegate = null;
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
            delegate.fastInvoke(holder.getCell(), sr[0] + 1, sr[1] + 1);
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
        if (sectionCountDelegate != null) {
            sectionCount = sectionCountDelegate.fastInvoke_I();
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
            int rc = rowCountDelegate.fastInvokeI_I((i >> 1) + 1);
            result[i] = allCount;
            allCount += rc;
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
            String result = reuseIdDelegate.fastInvoke_S(sr[0] + 1, sr[1] + 1);

            if (MLSEngine.DEBUG && result.isEmpty()) {//统一报错，reuseid不能为""
                IllegalArgumentException e = new IllegalArgumentException("reuseId不能为空字符串");
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
        removeSparseArrayFromStart(reuseIdCache, index);
    }

    /**
     * 刷新整个view时调用
     */
    @CallSuper
    protected void onReload() {
        if (reuseIdCache != null) {
            reuseIdCache.clear();
        }
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
        int paddingValues[] = ((com.immomo.mls.fun.ud.view.recycler.ILayoutInSet) layout).getPaddingValues();
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
            recyclerView.setPadding(paddingValues[0] - layout.getItemSpacingPx() / 2, paddingValues[1], paddingValues[2] - layout.getItemSpacingPx() / 2, paddingValues[3]);
        }
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