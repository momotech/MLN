/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.view.recycler;

import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_NOTCLIP;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.other.Adapter;
import com.immomo.mls.fun.other.ViewHolder;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDCell;
import com.immomo.mls.fun.ud.UDPoint;
import com.immomo.mls.fun.ud.view.IClipRadius;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.ud.view.UDViewGroup;
import com.immomo.mls.fun.ui.IRefreshRecyclerView;
import com.immomo.mls.fun.ui.IScrollEnabled;
import com.immomo.mls.fun.ui.LuaRecyclerView;
import com.immomo.mls.fun.ui.OnLoadListener;
import com.immomo.mls.fun.ui.SizeChangedListener;
import com.immomo.mls.fun.weight.MLSRecyclerView;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.utils.WhiteScreenUtil;
import com.immomo.mls.weight.load.ILoadViewDelegete;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.functions.Function4;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Created by XiongFangyu
 * (alias = {"CollectionView", "TableView", "WaterfallView"})
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDRecyclerView<T extends ViewGroup & IRefreshRecyclerView & OnLoadListener,
        A extends UDBaseRecyclerAdapter, L extends UDBaseRecyclerLayout> extends UDViewGroup<T> implements SizeChangedListener {
    public static final String[] LUA_CLASS_NAME = {"CollectionView", "TableView", "WaterfallView"};

    public static final String[] methods = new String[]{
            "refreshEnable",
            "loadEnable",
            "scrollDirection",
            "loadThreshold",
            "openReuseCell",
            "reloadData",
            "setScrollEnable",
            "setScrollEnabled",
            "reloadAtRow",
            "reloadAtSection",
            "showScrollIndicator",
            "scrollToTop",
            "scrollToCell",
            "scrollBy",
            "insertCellAtRow",
            "insertRow",
            "deleteCellAtRow",
            "deleteRow",
            "isRefreshing",
            "startRefreshing",
            "stopRefreshing",
            "isLoading",
            "stopLoading",
            "noMoreData",
            "resetLoading",
            "loadError",
            "adapter",
            "layout",
            "setRefreshingCallback",
            "setLoadingCallback",
            "setScrollingCallback",
            "setOnScrollCallback",
            "setScrollBeginCallback",
            "setScrollEndCallback",
            "setEndDraggingCallback",
            "setStartDeceleratingCallback",
            "insertCellsAtSection",
            "insertRowsAtSection",
            "deleteRowsAtSection",
            "deleteCellsAtSection",
            "addHeaderView",
            "removeHeaderView",
            "setContentInset",
            "getContentInset",
            "useAllSpanForLoading",
            "getRecycledViewNum",
            "isStartPosition",
            "cellWithSectionRow",
            "visibleCells",
            "scrollEnabled",
            "setOffsetWithAnim",
            "contentOffset",
            "disallowFling",
            "i_bounces",
            "i_pagingEnabled",
            "a_pagingEnabled",
            "fixScrollConflict",
    };
    private static final String TAG = "UDRecyclerView";

    private ILoadViewDelegete loadViewDelegete;

    protected boolean mScrollEnabled;
    protected boolean mRefreshEnabled;

    RecyclerView.LayoutManager mLayoutManager;
    private WhiteScreenUtil whiteScreenUtil;
    private PagerSnapHelper snapHelper;

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public UDRecyclerView(long L, LuaValue[] initParams) {
        super(L, initParams);
        mScrollEnabled = true;
        view.setSizeChangedListener(this);
    }

    @Override
    protected T newView(LuaValue[] init) {
        boolean loadEnable = false;
        if (init.length > 0) {
            mRefreshEnabled = init[0].toBoolean();
        }
        if (init.length > 1) {
            loadEnable = init[1].toBoolean();
        }
        LuaRecyclerView luaRecyclerView = new LuaRecyclerView(getContext(), this, mRefreshEnabled, loadEnable);
        return (T) luaRecyclerView;
    }

    public void setLoadViewDelegete(ILoadViewDelegete loadViewDelegete) {
        this.loadViewDelegete = loadViewDelegete;
    }

    //---------------------------------------API--------------------------------------
    protected A adapter;
    protected L layout;
    private int orientation = RecyclerView.VERTICAL;
    private LuaFunction refreshCallback;
    private LuaFunction loadCallback;
    private LuaFunction scrollCallback;
    private LuaFunction onScrollCallback;
    private LuaFunction scrollBeginCallback;
    private LuaFunction scrollEndCallback;
    private LuaFunction endDraggingCallback;
    private LuaFunction startDeceleratingCallback;
    private boolean scrollListenerAdded = false;
    private List<View> headerViews;
    private boolean useAllSpanForLoading = true;
    private float loadThreshold = 0;
    private boolean openReuseCell;
    private RecycledViewPoolManager poolManager;
    private float footerPaddingBottom = Float.MIN_VALUE;
    private LuaValue[] mContentInsetLuaValue;

    private int settedWidth;
    private int settedHeight;

    private boolean mAttachFirst = false;
    /**
     * 首次初始化执行  校验规定时间内是否执行加载数据 以监测白屏的可能性
     */
    private boolean isFirstInit = true;
    private AtomicBoolean hasLoadData = new AtomicBoolean();

    protected RecyclerView getRecyclerView() {
        return getView().getRecyclerView();
    }

    public L getLayout() {
        return layout;
    }

    @Override
    public void onAttached() {
        super.onAttached();
        mAttachFirst = true;
        if (isFirstInit) {
            whiteScreenUtil = new WhiteScreenUtil(new WeakReference<View>(getRecyclerView())
                    , getTaskTag()
                    , hasLoadData
                    , getLuaViewManager() == null ? "" : getLuaViewManager().url);
            whiteScreenUtil.checkList();
            isFirstInit = false;
        }
    }

    private Object getTaskTag() {
        return TAG + hashCode();
    }

    @Override
    public void onDetached() {
        super.onDetached();
        WhiteScreenUtil.cancel(getTaskTag());
    }
//<editor-fold desc="API">

    //<editor-fold desc="Property">
    @Override
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] clipToBounds(LuaValue[] p) {
        boolean clip = p[0].toBoolean();
        view.setClipToPadding(clip);
        view.setClipChildren(clip);
        view.getRecyclerView().setClipToPadding(clip);
        view.getRecyclerView().setClipChildren(clip);
        if (view instanceof IClipRadius) {//统一：clipToBounds(true)，切割圆角
            ((IClipRadius) view).forceClipLevel(clip ? LEVEL_FORCE_CLIP : LEVEL_FORCE_NOTCLIP);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] refreshEnable(LuaValue[] values) {
        if (values.length > 0) {
            mRefreshEnabled = values[0].toBoolean();
            getView().setRefreshEnable(mRefreshEnabled);
            return null;
        }

        return LuaValue.rBoolean(getView().isRefreshEnable());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] loadEnable(LuaValue[] values) {
        if (values.length > 0) {
            boolean enable = values[0].toBoolean();
            getView().setLoadEnable(enable);
            if (getRecyclerView().getAdapter() instanceof Adapter) {
                ((Adapter) getRecyclerView().getAdapter()).setFooterAdded(enable);
            }
            return null;
        }
        return LuaValue.rBoolean(getView().isLoadEnable());
    }


    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class))
    })
    public LuaValue[] scrollDirection(LuaValue[] values) {
        if (values.length > 0) {
            int newOrientation = parseDirection(values[0].toInt());
            boolean change = orientation != newOrientation;
            orientation = newOrientation;
            //动态设置，需要重新计算inset和spacing，两端统一差异
            if (change && adapter != null && layout != null) {
                layout.setOrientation(orientation);
                if (layout instanceof ILayoutInSet) {
                    removeAllItemDecorations(getRecyclerView());//移除之前的decoration
                    getRecyclerView().addItemDecoration(layout.getItemDecoration());
                    adapter.setMarginForVerticalGridLayout(getRecyclerView());
                }
            }
            setOrientation(getRecyclerView().getLayoutManager());

            return null;
        }
        return varargsOf(LuaNumber.valueOf(parseDirection(orientation)));
    }

    private int parseDirection(int old) {
        if (old == 0)
            return 1;
        return 0;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] loadThreshold(LuaValue[] values) {
        if (values.length > 0) {
            this.loadThreshold = (float) values[0].toDouble();
            ((MLSRecyclerView) getRecyclerView()).setLoadThreshold(loadThreshold);
            return null;
        }
        return varargsOf(LuaNumber.valueOf(loadThreshold));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] openReuseCell(LuaValue[] values) {
        if (values.length > 0) {
            openReuseCell = values[0].toBoolean();
            if (openReuseCell) {
                poolManager = RecycledViewPoolManager.getInstance(getGlobals());
                getRecyclerView().setRecycledViewPool(poolManager.getRecycleViewPoolInstance());
                if (adapter != null) {
                    RecyclerView.LayoutManager layoutManager = adapter.getLayoutManager();
                    if (layoutManager instanceof LinearLayoutManager) {
                        ((LinearLayoutManager) layoutManager).setRecycleChildrenOnDetach(true);
                    }
                    adapter.setRecycledViewPoolIDGenerator(poolManager.getIdGenerator());
                }
            } else {
                poolManager = null;
                if (adapter != null) {
                    adapter.setRecycledViewPoolIDGenerator(null);
                }
            }
            return null;
        } else {
            return LuaValue.rBoolean(openReuseCell);
        }
    }

    //滑动到指定位置
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDPoint.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setOffsetWithAnim(LuaValue[] values) {
        if (values.length == 1) {
            UDPoint point = (UDPoint) values[0];
            getView().smoothScrollTo(point.getPoint());
            point.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDPoint.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDPoint.class))
    })
    public LuaValue[] contentOffset(LuaValue[] p) {
        if (p.length == 1) {
            getView().setContentOffset(((UDPoint) p[0]).getPoint());
            p[0].destroy();
            return null;
        }
        return varargsOf(new UDPoint(globals, getView().getContentOffset()));
    }

    @LuaApiUsed(ignore = true)
    public LuaValue[] i_bounces(LuaValue[] bounces) {
        return null;
    }

    @LuaApiUsed(ignore = true)
    public LuaValue[] i_pagingEnabled(LuaValue[] bounces) {
        return null;
    }

    @LuaApiUsed(ignore = true)
    public LuaValue[] a_pagingEnabled(LuaValue[] values) {
        if (values.length > 0) {
            if (values[0].toBoolean()) {
                snapHelper = new PagerSnapHelper();
                snapHelper.attachToRecyclerView(getRecyclerView());
            } else {
                snapHelper.attachToRecyclerView(null);
            }
        }
        return null;
    }
//</editor-fold>

    //<editor-fold desc="Method">

    /**
     * 重新渲染
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] reloadData(LuaValue[] values) {
        if (adapter != null) {
            hasLoadData.set(true);
            adapter.reload();
        }
        return null;
    }

    /**
     * 是否可以滚动
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setScrollEnable(LuaValue[] values) {
        setScrollEnable(values[0].toBoolean());
        return null;
    }

    /**
     *  适配coordinate嵌套list后再嵌套list
     * @param values
     * @return
     */
    @LuaApiUsed
    public LuaValue[] setScrollEnabled(LuaValue[] values) {
        setScrollEnable(values[0].toBoolean());
        getRecyclerView().setNestedScrollingEnabled(values[0].toBoolean());
        return null;
    }

    private void setScrollEnable(boolean enable) {
        mScrollEnabled = enable;

        if (mLayoutManager instanceof IScrollEnabled) {
            ((IScrollEnabled) mLayoutManager).setScrollEnabled(mScrollEnabled);
        }

        getView().setRefreshEnable(mScrollEnabled && mRefreshEnabled);
    }

    /**
     * (section,row) 重新渲染某个item
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] reloadAtRow(LuaValue[] values) {
        if (values.length == 3) {
            if (adapter != null) {
                hasLoadData.set(true);
                adapter.reloadAtRow(values[1].toInt() - 1, values[0].toInt() - 1, values[2].toBoolean());
            }
        }
        return null;
    }

    /**
     * (section) 重新渲染某个section
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] reloadAtSection(LuaValue[] values) {
        if (values.length == 2) {
            if (adapter != null) {
                hasLoadData.set(true);
                adapter.reloadAtSection(values[0].toInt() - 1, values[1].toBoolean());
            }
        }
        return null;
    }

    /**
     * 设置滚动条的显隐
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] showScrollIndicator(LuaValue[] values) {
        if (values.length >= 1) {
            boolean show = values[0].toBoolean();
            getRecyclerView().setVerticalScrollBarEnabled(show);
            getRecyclerView().setHorizontalScrollBarEnabled(show);
            return null;
        }

        boolean scrollBarEnabled = orientation == RecyclerView.VERTICAL ? getRecyclerView().isVerticalScrollBarEnabled() : getRecyclerView().isHorizontalScrollBarEnabled();
        return LuaValue.varargsOf(LuaBoolean.valueOf(scrollBarEnabled));
    }

    /**
     * 滚动到顶
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] scrollToTop(LuaValue[] values) {
        boolean anim = false;
        if (values.length >= 1) {
            anim = values[0].toBoolean();
        }
        if (mScrollEnabled)
            callScrollToTop(anim);
        return null;
    }

    /**
     * 滚动到某个item
     * <p>
     * row
     * section
     * anim
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] scrollToCell(LuaValue[] values) {
        if (adapter != null && values.length >= 2) {
            if (!mScrollEnabled) {
                return null;
            }
            int position = adapter.getPositionBySectionAndRow(values[1].toInt() - 1, values[0].toInt() - 1);
            RecyclerView recyclerView = getRecyclerView();
            if (recyclerView instanceof MLSRecyclerView && values.length >= 3) {
                ((MLSRecyclerView) recyclerView).smoothMoveToPosition(!values[2].toBoolean(), position + adapter.getAdapter().getHeaderCount());
            }
        }
        return null;
    }


    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] scrollBy(LuaValue[] values) {
        if (adapter != null && values.length >= 2) {
            RecyclerView recyclerView = getRecyclerView();
            recyclerView.scrollBy(DimenUtil.dpiToPx(values[0].toFloat()), DimenUtil.dpiToPx(values[1].toFloat()));
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] insertCellAtRow(LuaValue[] values) {
        if (adapter != null) {
            hasLoadData.set(true);
            adapter.setItemAnimated(false);
            adapter.insertCellAtRow(values[1].toInt() - 1, values[0].toInt() - 1);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] insertRow(LuaValue[] values) {
        if (adapter == null || values.length < 2)
            return null;

        boolean animated = false;
        if (values.length >= 3) {
            animated = values[2].toBoolean();
        }
        hasLoadData.set(true);
        adapter.insertCellAtRowAnimated(values[1].toInt() - 1, values[0].toInt() - 1, animated);
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] deleteCellAtRow(LuaValue[] values) {
        if (adapter != null) {
            adapter.setItemAnimated(false);
            adapter.deleteCellAtRow(values[1].toInt() - 1, values[0].toInt() - 1);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] deleteRow(LuaValue[] values) {

        if (adapter == null || values.length < 2)
            return null;

        boolean animated = false;
        if (values.length >= 3) {
            animated = values[2].toBoolean();
        }

        adapter.deleteCellAtRowAnimated(values[1].toInt() - 1, values[0].toInt() - 1, animated);
        return null;
    }

    /**
     * 判断是否正在刷新
     *
     * @return
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] isRefreshing(LuaValue[] values) {
        return LuaValue.rBoolean(getView().isRefreshing());
    }

    /**
     * 执行下拉刷新动画，并回调 Android专用
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] startRefreshing(LuaValue[] values) {
        getView().startRefreshing();
        return null;
    }

    /**
     * 停止下拉刷新动画
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] stopRefreshing(LuaValue[] values) {
        getView().stopRefreshing();
        return null;
    }

    /**
     * 判断是否正在加载
     *
     * @return
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] isLoading(LuaValue[] values) {
        return LuaValue.rBoolean(getView().isLoading());
    }

    /**
     * 停止加载
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] stopLoading(LuaValue[] values) {
        getView().stopLoading();
        return null;
    }

    /**
     * 通知无更多数据，将加载动画删除
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] noMoreData(LuaValue[] values) {
        getView().noMoreData();
        return null;
    }

    /**
     * 重置加载状态，和noMoreData相反
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] resetLoading(LuaValue[] values) {
        getView().resetLoading();
        return null;
    }

    /**
     * 加载失败，显示点击加载
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] loadError(LuaValue[] values) {
        getView().loadError();
        return null;
    }

    /**
     * 设置adapter，不同类型adapter类型不同
     * <p>
     * adapter
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDBaseRecyclerAdapter.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDBaseRecyclerAdapter.class))
    })
    public final LuaValue[] adapter(LuaValue[] values) {
        if (values.length > 0) {
            LuaValue value = values[0];
            if (value != null && value.isUserdata()) {
                final A a = (A) value.toUserdata();
                MainThreadExecutor.postAtFrontOfQueue(new Runnable() {
                    @Override//解决adapter 与其他方法的时序问题
                    public void run() {
                        onAdapterSet(a);
                    }
                });
            }
            return null;
        }
        return varargsOf(adapter != null ? adapter : Nil());
    }

    /**
     * 设置layout，不同类型layout类型不同
     * <p>
     * UDBaseRecyclerLayout layout
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDBaseRecyclerLayout.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDBaseRecyclerLayout.class))
    })
    public LuaValue[] layout(LuaValue[] values) {
        if (values.length > 0) {
            LuaValue value = values[0];
            if (value != null && value.isUserdata()) {
                L l = (L) value.toUserdata();
                if (adapter != null) {
                    adapter.setLayout(l, getView());
                }
                this.layout = l;
            }
            return null;
        }

        return varargsOf(this.layout != null ? layout : Nil());
    }

    /**
     * 设置下拉刷新的回调
     * <p>
     * fun
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function0.class, typeArgs = {Unit.class})
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setRefreshingCallback(LuaValue[] values) {
        if (refreshCallback != null)
            refreshCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction())
            refreshCallback = value.toLuaFunction();
        return null;
    }

    /**
     * 设置上拉加载的回调
     * <p>
     * fun
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function0.class, typeArgs = {Unit.class})
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setLoadingCallback(LuaValue[] values) {
        if (loadCallback != null)
            loadCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction())
            loadCallback = value.toLuaFunction();
        return null;
    }

    /**
     * 滚动回调
     * <p>
     * fun
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function2.class, typeArgs = {
                            Integer.class, Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setScrollingCallback(LuaValue[] values) {
        if (scrollCallback != null)
            scrollCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            scrollCallback = value.toLuaFunction();
            if (scrollCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    //仅限android 意图是提供滑动为负数的
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function2.class, typeArgs = {
                            Float.class, Float.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setOnScrollCallback(LuaValue[] values) {
        if (onScrollCallback != null)
            onScrollCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            onScrollCallback = value.toLuaFunction();
            if (onScrollCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    /**
     * 开始滚动回调
     * <p>
     * fun
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function2.class, typeArgs = {
                            Integer.class, Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setScrollBeginCallback(LuaValue[] values) {
        if (scrollBeginCallback != null)
            scrollBeginCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            scrollBeginCallback = value.toLuaFunction();
            if (scrollBeginCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    /**
     * 结束滚动回调
     * <p>
     * fun
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function2.class, typeArgs = {
                            Integer.class, Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setScrollEndCallback(LuaValue[] values) {
        if (scrollEndCallback != null)
            scrollEndCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            scrollEndCallback = value.toLuaFunction();
            if (scrollEndCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function2.class, typeArgs = {
                            Integer.class, Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setEndDraggingCallback(LuaValue[] values) {
        if (endDraggingCallback != null)
            endDraggingCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            endDraggingCallback = value.toLuaFunction();
            if (endDraggingCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function2.class, typeArgs = {
                            Integer.class, Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setStartDeceleratingCallback(LuaValue[] values) {
        if (startDeceleratingCallback != null)
            startDeceleratingCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            startDeceleratingCallback = value.toLuaFunction();
            if (startDeceleratingCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] insertCellsAtSection(LuaValue[] values) {
        if (adapter != null) {
            hasLoadData.set(true);
            adapter.setItemAnimated(false);
            adapter.insertCellsAtSection(values[0].toInt() - 1, values[1].toInt() - 1, (values[2].toInt() - values[1].toInt()) + 1);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] insertRowsAtSection(LuaValue[] values) {
        if (adapter != null) {
            hasLoadData.set(true);
            adapter.setItemAnimated(values[3].toBoolean());
            adapter.insertCellsAtSection(values[0].toInt() - 1, values[1].toInt() - 1, (values[2].toInt() - values[1].toInt()) + 1);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] deleteRowsAtSection(LuaValue[] values) {
        if (adapter != null) {
            adapter.setItemAnimated(values[3].toBoolean());
            checkEndRowBeyondBounds(values);
            adapter.deleteCellsAtSection(values[0].toInt() - 1, values[1].toInt() - 1, (values[2].toInt() - values[1].toInt()) + 1);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] deleteCellsAtSection(LuaValue[] values) {
        if (adapter != null) {
            adapter.setItemAnimated(false);
            checkEndRowBeyondBounds(values);
            adapter.deleteCellsAtSection(values[0].toInt() - 1, values[1].toInt() - 1, (values[2].toInt() - values[1].toInt()) + 1);
        }
        return null;
    }

    @Deprecated
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDView.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] addHeaderView(LuaValue[] values) {
        ErrorUtils.debugDeprecatedMethod("WaterfallView:addHeaderView method is deprecated, use WaterfallAdapter:initHeader and WaterfallAdapter:fillHeaderData methods instead!", getGlobals());
        UDView v = (UDView) values[0];
        if (adapter == null) {
            if (headerViews == null) {
                headerViews = new ArrayList<>();
            }
            headerViews.add(v.getView());
            return null;
        }
        adapter.getAdapter().addHeaderView(v.getView());
        return null;
    }

    @Deprecated
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] removeHeaderView(LuaValue[] values) {
        ErrorUtils.debugDeprecatedMethod("WaterfallView:removeHeaderView method is deprecated, use WaterfallAdapter:initHeader and WaterfallAdapter:fillHeaderData methods instead!", getGlobals());
        if (headerViews != null) {
            headerViews.clear();
        }
        if (adapter != null) {
            adapter.getAdapter().removeAllHeaderView();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] setContentInset(LuaValue[] values) {
        mContentInsetLuaValue = values;
        if (values.length > 3) {
            footerPaddingBottom = DimenUtil.dpiToPx((float) values[2].toDouble());
        }
        setFooterViewMaigin();
        return null;
    }

    /**
     * function
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function4.class, typeArgs = {
                            Float.class, Float.class, Float.class, Float.class, Unit.class
                    })
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] getContentInset(LuaValue[] values) {
        if (values.length >= 1 && values[0].isFunction()) {
            if (mContentInsetLuaValue != null)
                values[0].toLuaFunction().invoke(mContentInsetLuaValue);
            else {
                LuaValue zero = LuaNumber.valueOf(0);
                values[0].toLuaFunction().invoke(varargsOf(zero, zero, zero, zero));
            }
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] useAllSpanForLoading(LuaValue[] values) {
        useAllSpanForLoading = values[0].toBoolean();
        if (adapter != null) {
            adapter.getAdapter().useAllSpanForLoading(useAllSpanForLoading);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class))
    })
    public LuaValue[] getRecycledViewNum(LuaValue[] values) {
        return LuaValue.rNumber(poolManager != null ? poolManager.getRecycledViewNum() : 0);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] isStartPosition(LuaValue[] values) {
        if (orientation == RecyclerView.VERTICAL) {
            return LuaValue.rBoolean(!getRecyclerView().canScrollVertically(-1));
        } else {
            return LuaValue.rBoolean(!getRecyclerView().canScrollHorizontally(-1));
        }
    }

    /**
     * section
     * row
     *
     * @return 返回指定位置的cell，版本1.0.2
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(LuaValue.class))
    })
    public LuaValue[] cellWithSectionRow(LuaValue[] values) {
        if (adapter == null) {
            return LuaValue.rNil();
        }
        int position = adapter.getPositionBySectionAndRow(values[0].toInt() - 1, values[1].toInt() - 1);
        View view = getRecyclerView().getLayoutManager().findViewByPosition(position);
        if (view == null) {
            return LuaValue.rNil();
        }
        ViewHolder holder = (ViewHolder) getRecyclerView().getChildViewHolder(view);
        return varargsOf(holder.getCell());
    }

    /**
     * @return 返回当前屏幕展示的所有cell，版本1.0.2
     */
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDArray.class))
    })
    public LuaValue[] visibleCells(LuaValue[] values) {
        List list = new ArrayList();
        if (adapter == null) {
            return varargsOf(new UDArray(getGlobals(), list));
        }

        RecyclerView.LayoutManager layoutManager = getRecyclerView().getLayoutManager();
        if (layoutManager == null) {
            return varargsOf(new UDArray(getGlobals(), list));
        }

        int firstPosition = ((MLSRecyclerView) getRecyclerView()).findFirstVisibleItemPosition();
        int lastPosition = ((MLSRecyclerView) getRecyclerView()).findLastVisibleItemPosition();
        for (int i = firstPosition; i < lastPosition + 1; i++) {
            View view = layoutManager.findViewByPosition(i);
            if (view == null) {
                continue;
            }
            ViewHolder holder = (ViewHolder) getRecyclerView().getChildViewHolder(view);
            if (holder.getCell() != null) {//header、footer的getCell为空
                list.add(holder.getCell());
            }
        }
        return varargsOf(new UDArray(getGlobals(), list));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] scrollEnabled(LuaValue[] values) {
        if (values.length > 0) {
            LuaValue value = values[0];
            getRecyclerView().setLayoutFrozen(value.toBoolean());
            return null;
        }

        return LuaValue.rBoolean(getRecyclerView().isLayoutFrozen());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] disallowFling(LuaValue[] values) {
        if (values.length > 0) {
            boolean enable = values[0].toBoolean();
            ((MLSRecyclerView) getRecyclerView()).setDisallowFling(enable);
            return null;
        }
        return LuaValue.rBoolean(((MLSRecyclerView) getRecyclerView()).isDisallowFling());
    }

    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="call by uirecyclerview">
    public void callbackRefresh() {
        if (refreshCallback != null)
            refreshCallback.invoke(null);
    }

    public void callbackLoading() {
        if (loadCallback != null)
            loadCallback.invoke(null);
    }

    public void setFooterViewMaigin() {
        if (loadViewDelegete != null && footerPaddingBottom != Float.MIN_VALUE) {
            View footer = loadViewDelegete.getLoadView().getView();
            footer.setPadding(footer.getPaddingLeft(), footer.getPaddingTop(), footer.getPaddingRight(), (int) footerPaddingBottom);
        }
    }
    //</editor-fold>

    //<editor-fold desc="OnScrollListener">
    private RecyclerView.OnScrollListener onScrollListener = new RecyclerView.OnScrollListener() {
        private boolean scrolling = false;
        private boolean isDragging = false;
        private boolean newSettlingState;

        @Override
        public void onScrollStateChanged(RecyclerView recyclerView, int newState) {

            //停止拖拽，触发时机：拖拽中-->非拖拽状态。
            if (isDragging && newState != RecyclerView.SCROLL_STATE_DRAGGING) {
                if (endDraggingCallback != null) {
                    callbackWithPoint(endDraggingCallback, false);
                }
            }
            isDragging = newState == RecyclerView.SCROLL_STATE_DRAGGING;//更新拖拽状态

            if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                newSettlingState = false;
                scrolling = false;

                if (scrollEndCallback != null) {

                    SCROLL_TO_POSITION enumPosition = getScrollBottomOrTop();

                    callbackWithPoint(scrollEndCallback, enumPosition.position);
                }

                return;
            }

            if (newState == RecyclerView.SCROLL_STATE_SETTLING) {
                newSettlingState = true;
            }

            if (!scrolling) {
                scrolling = true;
                if (scrollBeginCallback != null) {
                    callbackWithPoint(scrollBeginCallback);
                }
            }
        }

        @NonNull
        private SCROLL_TO_POSITION getScrollBottomOrTop() {
            SCROLL_TO_POSITION scroll_to_position = SCROLL_TO_POSITION.SCROLL_TO_OTHER;

            if (!getRecyclerView().canScrollVertically(1))  // 底部
                scroll_to_position = SCROLL_TO_POSITION.SCROLL_TO_BOTTOM;
            else if (!getRecyclerView().canScrollVertically(-1)) {  // 顶部
                scroll_to_position = SCROLL_TO_POSITION.SCROLL_TO_TOP;
            }

            return scroll_to_position;
        }

        @Override
        public void onScrolled(RecyclerView recyclerView, int dx, int dy) {

            if (mAttachFirst)
                mAttachFirst = false;
            else {
                if (scrollCallback != null)
                    callbackWithPoint(scrollCallback);
                if (onScrollCallback != null)
                    callbackWithPoint(onScrollCallback, dx, dy);
            }
            if (newSettlingState) {

                if (startDeceleratingCallback != null) {
                    callbackWithPoint(startDeceleratingCallback);
                }
            }
            newSettlingState = false;
        }


        private void callbackWithPoint(LuaFunction c, int top_middle_bottom) {
            float sx = getRecyclerView().computeHorizontalScrollOffset();
            float sy = getRecyclerView().computeVerticalScrollOffset();
            c.invoke(varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(sx)), LuaNumber.valueOf(DimenUtil.pxToDpi(sy)), LuaNumber.valueOf(top_middle_bottom)));
        }

        private void callbackWithPoint(LuaFunction c) {
            float sx = getRecyclerView().computeHorizontalScrollOffset();
            float sy = getRecyclerView().computeVerticalScrollOffset();
            c.invoke(varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(sx)), LuaNumber.valueOf(DimenUtil.pxToDpi(sy))));
        }

        private void callbackWithPoint(LuaFunction c, boolean decelerating) {
            float sx = getRecyclerView().computeHorizontalScrollOffset();
            float sy = getRecyclerView().computeVerticalScrollOffset();
            c.invoke(varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(sx)), LuaNumber.valueOf(DimenUtil.pxToDpi(sy)), decelerating ? LuaValue.True() : LuaValue.False()));
        }

        private void callbackWithPoint(LuaFunction c, int dx, int dy) {
            c.invoke(varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(dx)), LuaNumber.valueOf(DimenUtil.pxToDpi(dy))));
        }
    };


    //</editor-fold>

    //<editor-fold desc="SizeChangedListener">
    @Override
    public void onSizeChanged(int w, int h) {
        if (this.adapter != null) {
            if (settedWidth > 0 && settedWidth != w
                    || (settedHeight > 0 && settedHeight != h))
                return;
            this.adapter.setViewSize(w, h);
        }
    }
    //</editor-fold>

    @Override
    public void setWidth(float w) {
        super.setWidth(w);
        settedWidth = (int) w;
    }

    @Override
    public void setHeight(float h) {
        super.setHeight(h);
        settedHeight = (int) h;
    }

    @Override
    public LuaValue[] setMinWidth(LuaValue[] p) {//两端统一，不支持宽高限制
        ErrorUtils.debugDeprecatedMethod("Not support 'setMinWidth'  method!", getGlobals());
        return super.setMinWidth(p);
    }

    @Override
    public LuaValue[] setMaxWidth(LuaValue[] pa) {
        ErrorUtils.debugDeprecatedMethod("Not support 'setMaxWidth'  method!", getGlobals());
        return super.setMaxWidth(pa);
    }

    @Override
    public LuaValue[] setMinHeight(LuaValue[] p) {
        ErrorUtils.debugDeprecatedMethod("Not support 'setMinHeight'  method!", getGlobals());
        return super.setMinHeight(p);
    }

    @Override
    public LuaValue[] setMaxHeight(LuaValue[] pa) {
        ErrorUtils.debugDeprecatedMethod("Not support 'setMaxHeight'  method!", getGlobals());
        return super.setMaxHeight(pa);
    }

    @Override
    public LuaValue[] addView(LuaValue[] var) {
        ErrorUtils.debugDeprecatedMethod("not support addView", getGlobals());
        return super.addView(var);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDRecyclerView.class))
    })
    public LuaValue[] fixScrollConflict(LuaValue[] values) {
        if (values.length > 0) {
            boolean param = values[0].toBoolean();
            if (getRecyclerView() instanceof MLSRecyclerView)
                ((MLSRecyclerView) getRecyclerView()).setFixScrollConflict(param);
            return null;
        }
        return null;
    }

    @CallSuper
    protected void onAdapterSet(A a) {
        this.adapter = a;
        adapter.setLoadViewDelegete(loadViewDelegete);
        setFooterViewMaigin();
        final RecyclerView recyclerView = getRecyclerView();
        if (layout != null) {
            layout.setOrientation(orientation);
            layout.setAdapter(adapter);
            adapter.setLayout(layout, getView());
            removeAllItemDecorations(recyclerView);//移除之前的decoration
            recyclerView.addItemDecoration(layout.getItemDecoration());

            if (layout instanceof ILayoutInSet) {//修复原CollectionViewGridLayout 两端差异
                adapter.setMarginForVerticalGridLayout(recyclerView);
            }
        }

        adapter.setRecyclerView(getView());

        if (headerViews != null) {
            adapter.getAdapter().addHeaderViews(headerViews);
            headerViews.clear();
            headerViews = null;
        }
        adapter.getAdapter().useAllSpanForLoading(useAllSpanForLoading);
        adapter.initWaterFallHeader();
        a.setOnLoadListener(getView());
        int w = recyclerView.getWidth();
        int h = recyclerView.getHeight();
        a.setViewSize(w, h);
        Adapter adapter = a.getAdapter();
        adapter.setFooterAdded(getView().isLoadEnable());

        recyclerView.setAdapter(adapter);

        mLayoutManager = a.getLayoutManager();
        recyclerView.setLayoutManager(mLayoutManager);

        setOrientation(mLayoutManager);

        if (openReuseCell) {
            if (mLayoutManager instanceof LinearLayoutManager) {
                ((LinearLayoutManager) mLayoutManager).setRecycleChildrenOnDetach(true);
            }
            if (this.adapter != null) {
                this.adapter.setRecycledViewPoolIDGenerator(poolManager.getIdGenerator());
            }
        } else {
            if (this.adapter != null) {
                this.adapter.setRecycledViewPoolIDGenerator(null);
            }
        }

        setScrollEnable(mScrollEnabled);
    }

    //setApater前，移除所有decoration，防止重复设置添加多个
    private void removeAllItemDecorations(RecyclerView recyclerView) {
        for (int i = 0; i < recyclerView.getItemDecorationCount(); i++) {
            recyclerView.removeItemDecorationAt(i);
        }
    }

    public void callScrollToTop(boolean anim) {
        if (!anim) {
            getRecyclerView().scrollToPosition(0);
        } else {
            getRecyclerView().smoothScrollToPosition(0);
        }
    }

    private void setOrientation(RecyclerView.LayoutManager layoutManager) {
        if (layoutManager instanceof LinearLayoutManager) {
            ((LinearLayoutManager) layoutManager).setOrientation(orientation);
        }
        if (layout != null) {
            layout.setOrientation(orientation);
        }
        if (adapter != null) {
            adapter.setOrientation(orientation);
        }
    }

    private int getOrientation() {
        RecyclerView.LayoutManager layoutManager = getRecyclerView().getLayoutManager();
        if (layoutManager instanceof LinearLayoutManager) {
            return ((LinearLayoutManager) layoutManager).getOrientation();
        }
        return RecyclerView.VERTICAL;
    }

    private void checkEndRowBeyondBounds(LuaValue[] values) {
        if (MLSEngine.DEBUG)
            adapter.getPositionBySectionAndRow(values[0].toInt() - 1, values[2].toInt() - 1);
    }

    // 是否 滑动到最底部和最顶部
    public enum SCROLL_TO_POSITION {
        SCROLL_TO_TOP(1),
        SCROLL_TO_BOTTOM(2),

        SCROLL_TO_OTHER(-1);

        private int position = -1;

        SCROLL_TO_POSITION(int s) {
            this.position = s;
        }
    }

}