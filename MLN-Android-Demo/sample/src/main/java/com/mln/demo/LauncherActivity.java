package com.mln.demo;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.TextView;

import com.mln.demo.android.activity.MainTabActivity;
import com.mln.demo.mln.activity.LuaViewActivity;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

/**
 * Created by zhang.ke
 * on 2019-11-13
 */
public class LauncherActivity extends AppCompatActivity implements View.OnClickListener {
    private Switch switchbtn;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        switchbtn = findViewById(R.id.mln_native_switch);
        final TextView btn = findViewById(R.id.mln_native_btn);

        switchbtn.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @SuppressLint("SetTextI18n")
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    btn.setText("MLN 美丽说");
                    App.getApp().initMLN();
                } else {
                    btn.setText("Native 美丽说");
                }
            }
        });
        btn.setOnClickListener(this);

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.mln_native_btn:
                if (switchbtn.isChecked()) {
                    startActivity(new Intent(this, LuaViewActivity.class));
                } else {
                    startActivity(new Intent(this, MainTabActivity.class));
                }
                break;
        }
    }
}
