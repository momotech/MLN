package com.mln.demo.android.fragment.message.controller;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;


import com.mln.demo.R;

import androidx.appcompat.app.AppCompatActivity;

public class MessageDetailNotificationActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_message_detail_notification);
        setUpOnClickListenerForBackImageView();
    }

    private void setUpOnClickListenerForBackImageView() {
        ImageView mBackImageView = (ImageView) findViewById(R.id.backIndicator);
        mBackImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }
}
