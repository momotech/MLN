package com.mln.demo.android.activity;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.bumptech.glide.Glide;
import com.mln.demo.R;
import com.mln.demo.android.fragment.DiscFragment;
import com.mln.demo.android.fragment.HomeFragment;
import com.mln.demo.android.fragment.MineFragment;
import com.mln.demo.android.fragment.message.controller.MessageFragment;
import com.mln.demo.android.util.Constant;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;

public class MainTabActivity extends BaseActivity {

    ImageView ivHome;
    ImageView ivDesc;
    ImageView ivPlus;
    ImageView ivMsg;
    ImageView ivMine;
    LinearLayout llTab;
    FrameLayout fragment;
    private Activity activity;
    private Fragment[] fragments;

    private int curTab;
    private Fragment homeFragment;
    private Fragment discFragment;
    private Fragment msgFragment;
    private Fragment mineFragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    int getConvertViewId() {
        return R.layout.activity_main_android;
    }

    @Override
    void initData() {
        activity = this;
        homeFragment = new HomeFragment();
        discFragment = new DiscFragment();
        msgFragment = new MessageFragment();
        mineFragment = new MineFragment();
        fragments = new Fragment[]{homeFragment, discFragment, null, msgFragment, mineFragment};
    }

    @Override
    void initView() {
        ivHome = findViewById(R.id.iv_home);
        ivDesc = findViewById(R.id.iv_desc);
        ivPlus = findViewById(R.id.iv_plus);
        ivMsg = findViewById(R.id.iv_msg);
        ivMine = findViewById(R.id.iv_mine);
        llTab = findViewById(R.id.ll_tab);
        fragment = findViewById(R.id.fragment);

        for (int i = 0; i < llTab.getChildCount(); i++) {
            ImageView image = (ImageView) llTab.getChildAt(i);
            if (i == 0) {
                Glide.with(activity).load(Constant.tab_selected[i]).into(image);
            } else {
                Glide.with(activity).load(Constant.tab_unselected[i]).into(image);
            }
            image.setOnClickListener(this);

        }
        getSupportFragmentManager().beginTransaction().add(R.id.fragment, fragments[curTab]).show(fragments[curTab]).commit();
    }

    private void toggerTab(int index) {
        if (index != 2 && index != curTab) {
            FragmentTransaction trx = getSupportFragmentManager().beginTransaction();
            trx.hide(fragments[curTab]);
            if (!fragments[index].isAdded()) {
                trx.add(R.id.fragment, fragments[index]);
            }
            trx.show(fragments[index]).commit();
            //上一个tab改为不选中
            Glide.with(activity).load(Constant.tab_unselected[curTab]).into((ImageView) llTab.getChildAt(curTab));
            //当前改为选中
            Glide.with(activity).load(Constant.tab_selected[index]).into((ImageView) llTab.getChildAt(index));
            curTab = index;

        }
    }

    @Override
    void setListener() {

    }

    @Override
    public void onClick(View v) {
        int pos = 0;
        switch (v.getId()) {
            case R.id.iv_home:
                pos = 0;
                break;
            case R.id.iv_desc:
                pos = 1;
                break;
            case R.id.iv_msg:
                pos = 3;
                break;
            case R.id.iv_mine:
                pos = 4;
                break;
        }
        toggerTab(pos);
    }
}
