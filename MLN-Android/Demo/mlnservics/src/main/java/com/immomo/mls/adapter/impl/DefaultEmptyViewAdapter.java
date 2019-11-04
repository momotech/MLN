package com.immomo.mls.adapter.impl;

import android.content.Context;
import android.graphics.Color;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import com.immomo.mls.adapter.MLSEmptyViewAdapter;

/**
 * Created by XiongFangyu on 2018/7/18.
 */
public class DefaultEmptyViewAdapter implements MLSEmptyViewAdapter {

    @Override
    public <T extends View & EmptyView> T createEmptyView(Context context) {
        EV ev = new EV(context);
        ev.setTextColor(Color.BLACK);
        ev.setTextSize(50);
        ev.setGravity(Gravity.CENTER);
        return (T) ev;
    }

    private static class EV extends TextView implements EmptyView {
        private CharSequence title;
        private CharSequence msg;

        public EV(Context context) {
            super(context);
        }

        @Override
        public void setTitle(CharSequence title) {
            this.title = title;
            refresh();
        }

        @Override
        public void setMessage(CharSequence msg) {
            this.msg = msg;
            refresh();
        }

        private void refresh() {
            if (title != null && msg != null) {
                setText(title + "\n" + msg);
            } else if (title != null) {
                setText(title);
            } else {
                setText(msg);
            }
        }
    }
}
