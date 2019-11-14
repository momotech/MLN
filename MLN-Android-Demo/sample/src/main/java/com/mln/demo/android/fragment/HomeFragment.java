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
public class HomeFragment extends BaseFragment {
    TextView tvTab1;
    TextView tvTab2;
    LinearLayout llHomeTab;
    ViewPager viewPager;

    private View view;

    private List<Fragment> fragments;
    private int curTab;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        view = super.onCreateView(inflater, container, savedInstanceState);
        tvTab1 = view.findViewById(R.id.tv_tab1);
        tvTab2 = view.findViewById(R.id.tv_tab2);
        llHomeTab = view.findViewById(R.id.ll_home_tab);
        viewPager = view.findViewById(R.id.viewPager);
        return view;
    }

    @Override
    int getConvertViewId() {
        return R.layout.fragment_home;
    }

    @Override
    void initData() {
        fragments = new ArrayList<>();
        fragments.add(new HomeAttenFragment());
        fragments.add(new HomeAttenFragment());
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
            viewPager.setCurrentItem(index);
            curTab = index;
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()) {
            case R.id.tv_tab1:
                resetTab(0);
                break;
            case R.id.tv_tab2:
                resetTab(1);
                break;
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }
}
