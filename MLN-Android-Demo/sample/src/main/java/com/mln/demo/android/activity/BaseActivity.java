package com.mln.demo.android.activity;

import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

public abstract class BaseActivity extends AppCompatActivity implements View.OnClickListener {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getConvertViewId());
        initData();
        initView();
        setListener();
    }

    abstract int getConvertViewId();

    abstract void initData();

    abstract void initView();

    abstract void setListener();

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            //点击屏幕返回键
            this.finish();
        }
        return true;
    }

    @Override
    public void onClick(View v) {

    }
}
