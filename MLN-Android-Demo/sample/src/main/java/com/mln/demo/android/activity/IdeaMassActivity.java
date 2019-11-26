package com.mln.demo.android.activity;

import android.content.Context;
import android.graphics.Rect;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mln.demo.R;
import com.mln.demo.android.adapter.IdeaLabelRvAdapter;
import com.mln.demo.android.adapter.InspirRvAdapter;
import com.mln.demo.android.entity.InspirHotEntity;
import com.mln.demo.android.interfaceview.InspirView;
import com.mln.demo.android.presenter.InspirPresenter;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-08 15:46
 */
public class IdeaMassActivity extends AppCompatActivity implements View.OnClickListener, InspirView, SwipeRefreshLayout.OnRefreshListener {
    private static final String TAG_ = IdeaMassActivity.class.getSimpleName();

    private Context context;
    private IdeaLabelRvAdapter labelRvAdapter;
    private InspirRvAdapter adapter;
    private InspirPresenter presenter;
    private ImageView ivBack;
    private ImageView ivShare;
    private ImageView ivImg;
    private TextView tvAttention;
    private TextView tvTitle;
    private TextView tvContentNum;
    private TextView tvBrowseNum;
    private LinearLayout llNum;
    private ImageView ivLogo;
    private RecyclerView rvLabels;

    // fragment
    private TextView tvHot;
    private TextView tvRecent;
    private LinearLayout inspirTab;
    private RecyclerView recycleView;

    private int mLastCompletelyVisibleItemPosition;


    private int curTab;
    private SwipeRefreshLayout swipLayout;

    public IdeaMassActivity() {
    }


    int getConvertViewId() {
        return R.layout.idea_mass_top_view;
    }

    void initData() {
        context = this;
        presenter = new InspirPresenter(context, this);
    }

    void initView() {
        ivBack = findViewById(R.id.iv_back);
        ivShare = findViewById(R.id.iv_share);
        ivImg = findViewById(R.id.iv_img);
        tvAttention = findViewById(R.id.tv_attention);
        tvTitle = findViewById(R.id.tv_title);
        tvContentNum = findViewById(R.id.tv_content_num);
        tvBrowseNum = findViewById(R.id.tv_browse_num);
        llNum = findViewById(R.id.ll_num);
        ivLogo = findViewById(R.id.iv_logo);
        rvLabels = findViewById(R.id.rv_labels);
        View rvLabelsSwipe = findViewById(R.id.label_swipe);
        rvLabelsSwipe.setEnabled(false);

        //fragment
        tvHot = findViewById(R.id.tv_hot);
        tvRecent = findViewById(R.id.tv_recent);
        inspirTab = findViewById(R.id.inspir_tab);
        swipLayout = findViewById(R.id.swipLayout);
        recycleView = findViewById(R.id.inspirPagerRecyclerView);

        labelRvAdapter = new IdeaLabelRvAdapter(context);
        LinearLayoutManager manager = new LinearLayoutManager(context);
        manager.setOrientation(RecyclerView.HORIZONTAL);
        rvLabels.setLayoutManager(manager);

        swipLayout.setOnRefreshListener(this);
        swipLayout.setEnabled(false);

        recycleView.setVerticalScrollBarEnabled(false);
        recycleView.setHorizontalScrollBarEnabled(false);
        adapter = new InspirRvAdapter(context);
        GridLayoutManager layoutManager = new GridLayoutManager(context, 2);
        layoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int i) {
                if (i == adapter.getItemCount()-1) {
                    return 2;
                }
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
                    presenter.syncFetchData();
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

//
        //请求数据
        presenter.syncGetData();

        inspirTab.getChildAt(0).setSelected(true);
    }

    void setListener() {
        tvHot.setOnClickListener(this);
        tvRecent.setOnClickListener(this);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        final long startTime = System.currentTimeMillis();
        Log.d("keye", "oncreate: " + startTime);
        getWindow().getDecorView().getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            //当layout结束后回调此方法
            @Override
            public void onGlobalLayout() {
                long endTime = System.currentTimeMillis();

                Log.d("keye", "onGlobalLayout:  layout cast = " + (endTime - startTime));

                //删除监听
//                getWindow().getDecorView().getViewTreeObserver().removeOnGlobalLayoutListener(this);  //api16以上才能用（4.1）

            }
        });
        super.onCreate(savedInstanceState);

        setContentView(getConvertViewId());
        initData();
        initView();
        setListener();
    }


    private void resetTab(int index) {
        if (index != curTab) {
            inspirTab.getChildAt(0).setSelected(index == 0);
            inspirTab.getChildAt(1).setSelected(index == 1);
            curTab = index;
        }
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tv_hot:
                resetTab(0);
                break;
            case R.id.tv_recent:
                resetTab(1);
                break;
        }
    }

    @Override
    public void refreshUI(List<InspirHotEntity> list) {
        if (labelRvAdapter != null) {
            if (rvLabels.getAdapter() == null) {
                rvLabels.setAdapter(labelRvAdapter);
            }
            labelRvAdapter.updateList(list);
        }

        if (adapter != null) {
            if (recycleView.getAdapter() == null) {
                recycleView.setAdapter(adapter);
            } else {
                adapter.updateList(list);
            }
        }
        if (ivImg != null)
            ivImg.setBackgroundResource(R.drawable.idea_header);
    }

    @Override
    public void fetchUI(List<InspirHotEntity> list) {
        if (adapter != null) {
            if (recycleView.getAdapter() == null) {
                recycleView.setAdapter(adapter);
            } else {
                adapter.loadMore(list);
            }
        }
    }

    @Override
    public void onRefresh() {

    }
}
