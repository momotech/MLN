package com.mln.demo.android.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mln.demo.R;
import com.mln.demo.android.adapter.HomeVpAdapter;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.viewpager.widget.ViewPager;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-05 20:49
 */
public class MineFragment extends BaseFragment {


    private LinearLayout llHomeTab;
    private ViewPager viewPager;
    private TextView tvTab1;
    private TextView tvTab2;
    private TextView tvTab3;

    private List<Fragment> fragments;
    private int curTab;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        llHomeTab = view.findViewById(R.id.ll_mine_tab);
        viewPager = view.findViewById(R.id.viewPager_mine);
        tvTab1 = view.findViewById(R.id.tab1_mine);
        tvTab2 = view.findViewById(R.id.tab2_mine);
        tvTab3 = view.findViewById(R.id.tab3_mine);
        return view;
    }

    @Override
    int getConvertViewId() {
        return R.layout.fragment_mine;
    }

    @Override
    void initData() {
        fragments = new ArrayList<>();
        fragments.add(new MineHomeFragment());
        fragments.add(new MineTimelineFragment());
        fragments.add(new MineCollectionFragment());
    }

    @Override
    void initView() {
        llHomeTab.getChildAt(0).setSelected(true);
        viewPager.setAdapter(new HomeVpAdapter(getChildFragmentManager(), fragments));
    }

    @Override
    void setListener() {
        tvTab1.setOnClickListener(this);
        tvTab2.setOnClickListener(this);
        tvTab3.setOnClickListener(this);

        viewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
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

    private void resetTab(int index) {
        if (index != curTab) {
            llHomeTab.getChildAt(0).setSelected(index == 0);
            llHomeTab.getChildAt(1).setSelected(index == 1);
            llHomeTab.getChildAt(2).setSelected(index == 2);

            viewPager.setCurrentItem(index);
            curTab = index;
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()) {
            case R.id.tab1_mine:
                resetTab(0);
                break;
            case R.id.tab2_mine:
                resetTab(1);
                break;
            case R.id.tab3_mine:
                resetTab(2);
                break;
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }

}
