package com.mln.demo.android.fragment;

import android.content.Context;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;


import com.mln.demo.R;
import com.mln.demo.android.adapter.InspirRvAdapter;
import com.mln.demo.android.entity.InspirHotEntity;
import com.mln.demo.android.interfaceview.InspirView;
import com.mln.demo.android.presenter.InspirPresenter;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by zhangxin
 * DateTime: 2019-11-08 14:09
 * 灵感集-热门fragment
 */
public class InspirPagerFragment extends BaseFragment {


    private RecyclerView recycleView;

    private Context context;
    private InspirRvAdapter adapter;
    private String min_id;
    private List<InspirHotEntity> inspirDatas;
    private InspirPresenter presenter;
    private int mLastCompletelyVisibleItemPosition;

    public InspirPagerFragment() {
    }

    public InspirPagerFragment(List<InspirHotEntity> inspirDatas) {
        this.inspirDatas = inspirDatas;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        recycleView = view.findViewById(R.id.recycleView);
        return view;
    }

    @Override
    int getConvertViewId() {
        return R.layout.fragment_inspir_hot;
    }

    @Override
    void initData() {
        context = getActivity();
        if (inspirDatas == null)
            inspirDatas = new ArrayList<>();
//        presenter = new InspirPresenter(context, this);
    }

    @Override
    void initView() {
        recycleView.setFocusable(false);
        adapter = new InspirRvAdapter(context, inspirDatas, getChildFragmentManager());
        GridLayoutManager layoutManager = new GridLayoutManager(getContext(), 2);
        layoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int i) {
                return 1;
            }
        });
        recycleView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);
                outRect.set(20, 20, 20, 20);
            }
        });
        recycleView.addOnScrollListener(new RecyclerView.OnScrollListener() {

            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                mLastCompletelyVisibleItemPosition = lastCompletelyVisibleItemPosition(recyclerView);
            }

            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);

                if (canLoadMoreData(recyclerView, newState)) {
                    loadMoreData();
                }
            }

            private boolean canLoadMoreData(@NonNull RecyclerView recyclerView, int newState) {
                return didStopScroll(recyclerView, newState) && onBottom(recyclerView);
            }

            private boolean didStopScroll(@NonNull RecyclerView recyclerView, int newState) {
                return newState == RecyclerView.SCROLL_STATE_IDLE;
            }

            private boolean onBottom(@NonNull RecyclerView recyclerView) {
                return mLastCompletelyVisibleItemPosition >= ((LinearLayoutManager) recyclerView.getLayoutManager()).getItemCount() - 1;
            }

            private int lastCompletelyVisibleItemPosition(@NonNull RecyclerView recyclerView) {
                RecyclerView.LayoutManager lm = recyclerView.getLayoutManager();
                if (lm instanceof LinearLayoutManager) {
                    return ((LinearLayoutManager) lm).findLastVisibleItemPosition();
                }
                return -1;
            }
        });
        recycleView.setLayoutManager(layoutManager);
        recycleView.setAdapter(adapter);

        //请求数据
//        presenter.syncGetData();

    }

    //加载更多
    private void loadMoreData() {
//        presenter.syncFetchData();
        inspirDatas.addAll(inspirDatas.size(),inspirDatas );
        adapter.notifyDataSetChanged();
    }

    @Override
    void setListener() {

    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }

//    @Override
//    public void refreshUI(List<InspirHotEntity> list) {
//        inspirDatas.clear();
//        inspirDatas.addAll(list);
//        adapter.notifyDataSetChanged();
//    }
//
//    @Override
//    public void fetchUI(List<InspirHotEntity> list) {
//        inspirDatas.addAll(inspirDatas.size(), list);
//        adapter.notifyDataSetChanged();
//    }
}
