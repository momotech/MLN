package com.mln.demo.android.presenter;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.utils.MainThreadExecutor;
import com.mln.demo.android.interfaceview.BaseView;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by zhang.ke
 * on 2019-11-08
 */
public abstract class BasePresenter<T> {
    protected List<T> list;

    public BasePresenter() {
        this.list = new ArrayList<>();
    }

    public void syncGetData() {
        MLSAdapterContainer.getThreadAdapter().executeTaskByTag(hashCode(), new Runnable() {
            @Override
            public void run() {
                try {//TODO sleep...... 为了列表适配与加载分离
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                }
                final List<T> datalist = getData();

                final BaseView<T> baseView = getBaseView();
                if (baseView != null && datalist != null) {
                    MainThreadExecutor.post(new Runnable() {
                        @Override
                        public void run() {
                            baseView.refreshUI(datalist);//切主线程
                        }
                    });
                }
            }
        });
    }

    public void syncFetchData() {
        MLSAdapterContainer.getThreadAdapter().executeTaskByTag(hashCode(), new Runnable() {
            @Override
            public void run() {
                try {//TODO sleep......
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                }
                final List<T> datalist = fetchData();

                final BaseView<T> baseView = getBaseView();
                if (baseView != null && datalist != null) {
                    MainThreadExecutor.post(new Runnable() {
                        @Override
                        public void run() {
                            baseView.fetchUI(datalist);//切主线程
                        }
                    });
                }
            }
        });
    }

    public abstract BaseView<T> getBaseView();

    protected abstract List<T> getData();

    protected abstract List<T> fetchData();
}
