package com.mln.demo.activity;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import androidx.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.immomo.mls.fun.weight.LinearLayout;
import com.immomo.mls.util.DimenUtil;

public class WeidgetTesterActivity extends Activity {
    private static final int WRAP = ViewGroup.LayoutParams.WRAP_CONTENT;
    private static final String TAG = "WeidgetTesterActivity";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        /*RadiusTesterView view = new RadiusTesterView(this);
        view.setBackgroundColor(Color.RED);
        view.setRadiusColor(Color.WHITE);
        view.setRadius(100);

        BorderBackgroundDrawable d = new BorderBackgroundDrawable();
        view.setBackgroundDrawable(d);
        d.setGradientColor(Color.RED, Color.BLUE, (IBorderRadiusView.TYPE_LINEAR | IBorderRadiusView.VERTICAL));*/


        /*LinearLayout layout = new LinearLayout(this);
        layout.setBackgroundColor(Color.BLUE);

        TextView tv = new TextView(this);
        tv.setBackgroundColor(0x90000000);
        tv.setText("haha");
        tv.setTextColor(Color.WHITE);
        ViewGroup.MarginLayoutParams p = newLayoutParams(-2, -2);
        layout.addView(tv, p);

        TextView tv2 = new TextView(this);
        tv2.setBackgroundColor(0x10000000);
        tv2.setText("9999");
        tv2.setTextColor(Color.WHITE);
        layout.addView(tv2, -2, -2);

        TextView tv3 = new TextView(this);
        tv3.setBackgroundColor(0x90000000);
        tv3.setText("111hahalksdjgklasdjfklasdjfklsadjfkl;jsadl;kfjasdaaaaaaaa");
        tv3.setTextColor(Color.WHITE);
        LinearLayout.LayoutParams p1 = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,ViewGroup.LayoutParams.WRAP_CONTENT);
        p1.priority = 1;
        layout.addView(tv3, p1);

//        layout.setReverse(true);

        FrameLayout frameLayout = new FrameLayout(this);
        frameLayout.addView(layout, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        setContentView(frameLayout);*/
        final LinearLayout linearLayout = new LinearLayout(this);
        linearLayout.setBackgroundColor(0xffffff00);
        linearLayout.setLayoutParams(new ViewGroup.LayoutParams(DimenUtil.dpiToPx(92.6f), DimenUtil.dpiToPx(100)));

        TextView tv = new TextView(this);
        tv.setTextSize(13);
        tv.setTextColor(0xff323333);
        tv.setBackgroundColor(0xffff00ff);
        tv.setText("一二三四五六七,");
//        tv.setLines(1);
//        tv.setMaxLines(1);
        tv.setSingleLine();
        tv.setEllipsize(TextUtils.TruncateAt.END);
        linearLayout.addView(tv, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        linearLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Test test = new Test(v.getContext());
                linearLayout.addView(test);
            }
        });

        FrameLayout frameLayout = new FrameLayout(this);
        frameLayout.addView(linearLayout);
        frameLayout.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Log.d(TAG, "onTouch: " + event);
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
                }
                return true;
            }
        });
        frameLayout.setFocusable(true);
        frameLayout.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                Log.d(TAG, "onKey:" + event);
                return false;
            }
        });
        setContentView(frameLayout);
    }

    private static ViewGroup.MarginLayoutParams newLayoutParams(int w, int h) {
        return new ViewGroup.MarginLayoutParams(w, h);
    }

    private final class Test extends View {

        public Test(Context context) {
            super(context);
        }
    }
}
