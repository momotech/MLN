package com.immomo.mls.utils;

import android.graphics.Rect;
import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.fun.globals.LuaView;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.StopWatch;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.concurrent.atomic.AtomicBoolean;

public class WhiteScreenUtil {

    private final WeakReference<View> view;
    private final Object tag;
    private final AtomicBoolean hasLoadData;
    private final String url;
    private final CheckTask checkTask;
    private int detectTime;
    private boolean wasWhite;
    private final int detectLimit = MLSAdapterContainer.getMaybeWhiteScreenAdapter().getDetectTimes();
    private int screenWidth, screenHeight;

    public WhiteScreenUtil(final WeakReference<View> view, final Object tag, final AtomicBoolean hasLoadData, final String url) {
        this.view = view;
        this.tag = tag;
        this.hasLoadData = hasLoadData;
        this.url = url;
        checkTask = new CheckTask();
        if (view.get() != null) {
            screenWidth = AndroidUtil.getScreenWidth(view.get().getContext());
            screenHeight = AndroidUtil.getScreenHeight(view.get().getContext());
        }
    }

    public void checkList() {
        if (MLSAdapterContainer.getMaybeWhiteScreenAdapter().isEnable() && MLSAdapterContainer.getMaybeWhiteScreenAdapter().getCheckInterval() > 0)
            MainThreadExecutor.postDelayed(tag, checkTask, MLSAdapterContainer.getMaybeWhiteScreenAdapter().getCheckInterval() * 1000L);
    }

    public class CheckTask implements Runnable {

        private static final String TAG = "LuaWhiteScreenCheckTask";

        @Override
        public void run() {
            try {
                StopWatch stopWatch = new StopWatch();
                stopWatch.start();
                View ref = view.get();
                //view可见时
                if (ref instanceof RecyclerView) {
                    RecyclerView recyclerView = (RecyclerView) ref;
                    int area = screenWidth * screenHeight / 5;
                    //列表视图面积小于屏幕五分之一的不上传或者视图显示的
                    if (recyclerView.getWidth() * recyclerView.getHeight() < area || !ref.isShown()) {
                        return;
                    }
                    boolean hasCoverView = isViewCovered(recyclerView);
                    boolean hasChildren = recyclerView.getChildCount() > 0;
                    //判断是否异常白屏 未执行loaddata并且没有子视图以及没有触发空视图view的 为异常白屏
                    boolean isWhite = !hasLoadData.get() && !hasChildren && !hasCoverView;//指异常白屏显示但是为加载数据 本身就被gone掉的 不计入
                    if (detectTime < detectLimit && ((detectTime == 0 && isWhite) || wasWhite)) {
                        //在设定校验次数内 首次校验为白屏 上传数据后 开启下次校验直至达到次数 首次之外的校验  不论是否白屏 都会上传数据
                        detectTime++;
                        wasWhite = isWhite;
                        upload(isWhite);
                        checkList();
                    }
                }
                stopWatch.stop();
                MLSAdapterContainer.getConsoleLoggerAdapter().i(TAG, " detect white screen cast %s", stopWatch.getTime());
            } catch (Exception e) {
                MLSAdapterContainer.getConsoleLoggerAdapter().e(TAG, e);
            }

        }

        private void upload(boolean isWhite) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("isWhite", isWhite);
                jsonObject.put("url", url);
                jsonObject.put("detectTimes", detectTime);
                MLSAdapterContainer.getMaybeWhiteScreenAdapter().onMaybeListWhiteScreen(jsonObject.toString());
            } catch (JSONException e) {
            }
        }
    }


    public static void cancel(Object tag) {
        MainThreadExecutor.cancelAllRunnable(tag);
    }

    public boolean isViewCovered(final View view) {
        View currentView = view;
        Rect viewRect = new Rect();
        view.getGlobalVisibleRect(viewRect);
        Rect otherViewRect = new Rect();

        while (currentView.getParent() instanceof ViewGroup) {
            ViewGroup currentParent = (ViewGroup) currentView.getParent();
            // if the parent of view is not visible,return true
            if (currentParent.getVisibility() != View.VISIBLE)
                return true;

            int start = indexOfViewInParent(currentView, currentParent);
            for (int i = start + 1; i < currentParent.getChildCount(); i++) {
                View otherView = currentParent.getChildAt(i);
                if (otherView.getVisibility() != View.VISIBLE)
                    continue;
                otherView.getGlobalVisibleRect(otherViewRect);
                // if view intersects its older brother(covered),return true
                //Lua视图树中是否有View显示在列表上方
                //view显示在列表View上方，并且View的中心在列表View的中心，宽至少是列表View的1/3
                if (Rect.intersects(viewRect, otherViewRect)
                        && otherViewRect.width() > viewRect.width() / 3
                        && isInArea(otherViewRect.centerX(), otherViewRect.centerY()))
                    return true;
            }
            currentView = currentParent;
            if (currentView instanceof LuaView)
                break;
        }
        return false;
    }

    private boolean isInArea(int centerX, int centerY) {
        int centerYInScreen = screenHeight / 2;
        int offset = 200;
        return centerX == screenWidth / 2 && centerY > centerYInScreen - offset && centerY < centerYInScreen + offset;
    }

    private int indexOfViewInParent(View view, ViewGroup parent) {
        int index;
        for (index = 0; index < parent.getChildCount(); index++) {
            if (parent.getChildAt(index) == view)
                break;
        }
        return index;
    }
}
