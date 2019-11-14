package com.mln.demo.android.util;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-07 13:20
 */
public class ToastUtil {
    private static Handler handler = new Handler(Looper.getMainLooper());
    private static Toast toast = null;
    private static Object synObj = new Object();

    public static void showMessage(final Context act, final String msg) {
        showMessage(act, msg, Toast.LENGTH_SHORT);
    }

    private static void showMessage(final Context act, final String msg,
                                    final int len) {
        new Thread(new Runnable() {
            public void run() {
                handler.post(new Runnable() {
                    public void run() {
                        synchronized (synObj) {
                            if (toast != null) {
                                toast.setText(msg);
                                toast.setDuration(len);
                            } else {
                                toast = Toast.makeText(act, msg, len);
                            }
                            toast.show();
                        }
                    }
                });
            }
        }).start();
    }

}
