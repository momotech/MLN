package com.mln.demo.android.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;


import com.mln.demo.R;

import androidx.annotation.Nullable;

public class MineTimelineFragment extends BaseFragment {


    private View view;


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        view = super.onCreateView(inflater, container, savedInstanceState);
        return view;
    }

    @Override
    int getConvertViewId() {
        return R.layout.fragment_mine_timeline;
    }

    @Override
    void initData() {
    }

    @Override
    void initView() {
    }

    @Override
    void setListener() {

    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }
}
