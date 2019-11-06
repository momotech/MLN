package com.mln.demo.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.Toast;

import com.mln.demo.R;

import androidx.annotation.Nullable;

/**
 * Created by fanqiang on 2018/12/25.
 */
public class WebActivity extends Activity {
    public static final String INTENT_URL = "INTENT_URL";
    private WebView webView;
    private String url;

    public static void startActivity(Context context,String url){
        Intent intent = new Intent(context,WebActivity.class);
        intent.putExtra(INTENT_URL,url);
        context.startActivity(intent);
    }
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        url = getIntent().getStringExtra(INTENT_URL);
        setContentView(R.layout.activity_web);
        webView = findViewById(R.id.wv);
        webView.setWebChromeClient(client);
        webView.loadUrl(url);
    }

    private WebChromeClient client = new WebChromeClient(){
        private final int TOAST_DURATION_LEAST = 500;
        private boolean tip = false;
        private Toast toast;
        private long toastBegin;
        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            if(newProgress != 100 && !tip){
                toast = Toast.makeText(view.getContext(),view.getContext().getText(R.string.wait),Toast.LENGTH_SHORT);
                toast.show();
                toastBegin = System.currentTimeMillis();
                tip = true;
            }else if(newProgress == 100  && tip){
                long current = System.currentTimeMillis();
                if(current - toastBegin >= TOAST_DURATION_LEAST)
                    toast.cancel();
                else{
                    view.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            toast.cancel();
                        }
                    },TOAST_DURATION_LEAST - (current - toastBegin));
                }
            }

        }
    };

    @Override
    protected void onDestroy() {
        webView.setWebChromeClient(null);
        super.onDestroy();
    }
}
