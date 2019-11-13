package com.mln.demo.android.fragment;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.mln.demo.R;
import com.mln.demo.android.adapter.HomeRvAdapter;
import com.mln.demo.android.entity.HomeRvEntity;
import com.mln.demo.android.interfaceview.IHomeView;
import com.mln.demo.android.presenter.HomePresenter;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-06 16:49
 * 首页-关注fragment
 */
public class HomeAttenFragment extends BaseFragment implements IHomeView {


    RecyclerView recycleView;
    TextView tvSearch;

    private Context context;
    private View view;
    private HomeRvAdapter adapter;
    private String min_id;
    private List<HomeRvEntity> homeDatas;
    private HomePresenter presenter;
    private int mLastCompletelyVisibleItemPosition;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        view = super.onCreateView(inflater, container, savedInstanceState);
        recycleView=view.findViewById(R.id.recycleView);
        tvSearch=view.findViewById(R.id.tv_search);
        return view;
    }

    @Override
    int getConvertViewId() {
        return R.layout.fragment_home_atten;
    }

    @Override
    void initData() {
        context = getActivity();
        homeDatas = new ArrayList<>();
        presenter = new HomePresenter(context, this);
    }

    @Override
    void initView() {
        recycleView.setFocusable(false);
        adapter = new HomeRvAdapter(context, homeDatas, getChildFragmentManager());
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(context);
        recycleView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);
                outRect.set(0, 0, 0, 20);
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

               changeAdapterData(newState);
               lazyLoad(newState);

                if (canLoadMoreData(recyclerView, newState)) {
                    loadMoreData();
                }
            }

            private void changeAdapterData(int newState) {
                RecyclerView.Adapter adapter = recycleView.getAdapter();
                if (adapter instanceof HomeRvAdapter) {
                    ((HomeRvAdapter) adapter).setRecyclerState(newState);
                }
            }

            // 懒加载逻辑
            private void lazyLoad(int newState) {

                Context context = recycleView.getContext();

                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                        if (context instanceof Activity && (((Activity) context).isFinishing() || ((Activity) context).isDestroyed())) {
                            return;
                        }
                    } else {
                        if (context instanceof Activity && (((Activity) context).isFinishing())) {
                            return;
                        }
                    }

                    if (Glide.with(context).isPaused()) {
                        Glide.with(context).resumeRequests();
                    }

                } else {
                    Glide.with(context).pauseRequests();
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

        presenter.syncGetData();
    }

    //加载更多
    private void loadMoreData() {
       presenter.syncFetchData();
    }

    @Override
    void setListener() {

    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }

    @Override
    public void refreshUI(List<HomeRvEntity> list) {
        homeDatas.clear();
        homeDatas.addAll(list);
        adapter.notifyDataSetChanged();
    }

    @Override
    public void fetchUI(List<HomeRvEntity> list) {
        homeDatas.addAll(homeDatas.size(), list);
        adapter.notifyDataSetChanged();
    }
}
