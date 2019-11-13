package com.mln.demo.mln;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

/**
 * Project momodev
 * Package com.immomo.momo.util
 * Created by tangyuchun on 11/18/15.
 */
public class BroadcastHelper {
    /**
     * 发送广播
     *
     * @param action
     */
    public static void sendBroadcast(Context pContext, String action) {
        sendBroadcast(pContext, new Intent(action));
    }

    /**
     * 发送广播
     *
     * @param action
     */
    public static void sendBroadcast(Context pContext, Intent action) {
        LocalBroadcastManager.getInstance(pContext).sendBroadcast(action);
    }


    /**
     * UI注册广播监听事件
     *
     * @param receiver
     * @param action
     */
    public static void registerBroadcast(Context mContext, BroadcastReceiver receiver, String... action) {
        LocalBroadcastManager bm = LocalBroadcastManager.getInstance(mContext);
        if (receiver == null || action == null || action.length == 0) {
//            LogUtil.e(TAG, "receiver is null");
            return;
        }
        IntentFilter intentFilter = new IntentFilter();
        for (int i = 0; i < action.length; i++) {
            intentFilter.addAction(action[i]);
        }
        bm.registerReceiver(receiver, intentFilter);
    }

    public static void registerBroadcast(Context mContext, BroadcastReceiver receiver, IntentFilter filter) {
        if (receiver == null || filter == null) {
            return;
        }
        LocalBroadcastManager.getInstance(mContext).registerReceiver(receiver, filter);
    }

    /**
     * 取消广播接收
     *
     * @param receiver
     */
    public static void unregisterBroadcast(Context pContext, BroadcastReceiver receiver) {
        if (pContext == null || receiver == null) {
            return;
        }
        LocalBroadcastManager.getInstance(pContext).unregisterReceiver(receiver);
    }

}
