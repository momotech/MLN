package com.mln.demo.android.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;


public abstract class BaseFragment extends Fragment implements View.OnClickListener {

    private View mview;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        mview = inflater.inflate(getConvertViewId(), null);
        return mview;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initData();
        initView();
        setListener();
    }

    abstract int getConvertViewId();

    abstract void initData();

    abstract void initView();

    abstract void setListener();

    @Override
    public void onClick(View v) {
    }
}
