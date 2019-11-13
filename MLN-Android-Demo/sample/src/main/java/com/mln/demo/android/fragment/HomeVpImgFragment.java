package com.mln.demo.android.fragment;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.mln.demo.R;

import androidx.annotation.Nullable;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-05 20:49
 */
public class HomeVpImgFragment extends BaseFragment {
    private ImageView vpImgs;
    private Context context;
    private String url;

    public HomeVpImgFragment(Context context, String url) {
        this.context = context;
        this.url = url;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        vpImgs = view.findViewById(R.id.vp_imgs);
        return view;
    }

    @Override
    int getConvertViewId() {
        return R.layout.home_list_vp_item;
    }

    @Override
    void initData() {

    }

    @Override
    void initView() {
        Glide.with(context).load(url).into(vpImgs);
        Log.e("url", "url--" + url);
    }

    @Override
    void setListener() {
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }
}
