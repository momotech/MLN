package com.mln.demo.android.activity;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mln.demo.R;
import com.mln.demo.android.adapter.IdeaLabelRvAdapter;
import com.mln.demo.android.adapter.InspirPagerAdapter;
import com.mln.demo.android.entity.InspirHotEntity;
import com.mln.demo.android.fragment.InspirPagerFragment;
import com.mln.demo.android.interfaceview.InspirView;
import com.mln.demo.android.presenter.InspirPresenter;

import java.util.ArrayList;
import java.util.List;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager.widget.ViewPager;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-08 15:46
 */
public class IdeaMassActivity extends AppCompatActivity implements View.OnClickListener, InspirView {
    private static final String TAG_ = IdeaMassActivity.class.getSimpleName();

    private Context context;
    private IdeaLabelRvAdapter labelRvAdapter;
    private InspirPagerAdapter pagerAdapter;
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
    private ViewPager inspirPager;


    private List<Fragment> fragments;
    private int curTab;


    int getConvertViewId() {
        return R.layout.idea_mass_top_view;
    }

    void initData() {
        context = this;
        presenter = new InspirPresenter(context, this);
        fragments = new ArrayList<>();
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

        //fragment
        tvHot = findViewById(R.id.tv_hot);
        tvRecent = findViewById(R.id.tv_recent);
        inspirTab = findViewById(R.id.inspir_tab);
        inspirPager = findViewById(R.id.inspirPager);

        labelRvAdapter = new IdeaLabelRvAdapter(context);
        LinearLayoutManager manager = new LinearLayoutManager(context);
        manager.setOrientation(RecyclerView.HORIZONTAL);
        rvLabels.setLayoutManager(manager);
//
        //请求数据
        presenter.syncGetData();

        inspirTab.getChildAt(0).setSelected(true);
        pagerAdapter = new InspirPagerAdapter(getSupportFragmentManager(), fragments);
    }

    void setListener() {
        tvHot.setOnClickListener(this);
        tvRecent.setOnClickListener(this);
        inspirPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                resetTab(position);
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
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
            inspirPager.setCurrentItem(index);
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

        if (fragments.size() == 0 && pagerAdapter != null) {
            fragments.add(new InspirPagerFragment(list));
            fragments.add(new InspirPagerFragment(list));
            if (inspirPager.getAdapter() == null) {
                inspirPager.setAdapter(pagerAdapter);
            } else {
                pagerAdapter.notifyDataSetChanged();
            }
        }
        if (ivImg != null)
            ivImg.setBackgroundResource(R.drawable.idea_header);
    }

    @Override
    public void fetchUI(List<InspirHotEntity> list) {

    }
}
