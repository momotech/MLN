package com.mln.demo.android.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mln.demo.R;
import com.mln.demo.android.adapter.InspirPagerAdapter;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.viewpager.widget.ViewPager;


/**
 * Created by zhangxin
 * DateTime: 2019-11-08 13:49
 */
public class InspirFragment extends BaseFragment {


    private TextView tvHot;
    private TextView tvRecent;
    private LinearLayout inspirTab;
    private ViewPager inspirPager;

    private View view;

    private List<Fragment> fragments;
    private int curTab;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        view = super.onCreateView(inflater, container, savedInstanceState);
        tvHot = view.findViewById(R.id.tv_hot);
        tvRecent = view.findViewById(R.id.tv_recent);
        inspirTab = view.findViewById(R.id.inspir_tab);
        inspirPager = view.findViewById(R.id.inspirPager);
        return view;
    }

    @Override
    int getConvertViewId() {
        return R.layout.fragment_inspir;
    }

    @Override
    void initData() {
        fragments = new ArrayList<>();
//        fragments.add(new InspirPagerFragment());
//        fragments.add(new InspirPagerFragment());
    }

    @Override
    void initView() {
        inspirTab.getChildAt(0).setSelected(true);
        inspirPager.setAdapter(new InspirPagerAdapter(getChildFragmentManager(), fragments));
    }

    @Override
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
        super.onClick(v);
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
    public void onDestroyView() {
        super.onDestroyView();
    }
}
