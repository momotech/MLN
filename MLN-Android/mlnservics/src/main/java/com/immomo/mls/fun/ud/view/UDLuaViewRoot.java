package com.immomo.mls.fun.ud.view;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.ArrayMap;
import android.view.View;

import com.immomo.mls.Environment;
import com.immomo.mls.fun.constants.MotionEvent;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDCCanvas;
import com.immomo.mls.fun.ud.UDPaint;
import com.immomo.mls.fun.ud.UDCanvas;
import com.immomo.mls.fun.ui.LuaViewGroup;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.exception.InvokeError;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2020-01-02
 * 充当Lua层View的ViewRoot实现
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDLuaViewRoot extends UDViewGroup<LuaViewGroup> {
    public static final String LUA_CLASS_NAME = "LuaViewRoot";

    public static final String[] methods = {
            "closeHardWare",
            "setOnTouchListener",
            "doInNextFrame",
            "doAfter",
            "removeTask",
            "invalidate",
    };

    private static final boolean CLEAR_NOT_USE_DATA = false;

    private LuaFunction onTouchFunction;
    private boolean touchListenerSet = false;
    private LuaValue onTouchNativeParams;

    private LuaValue onDrawNativeParams;

    private final ArrayMap<String, Runnable> delayTasks;
    private UDCCanvas udCanvas;

    @LuaApiUsed(ignore = true)
    protected UDLuaViewRoot(long L, LuaValue[] v) {
        super(L, v);
        delayTasks = new ArrayMap<>();
        javaUserdata.setWillNotDraw(false);
    }

    @Override
    protected LuaViewGroup newView(LuaValue[] init) {
        return new LuaViewGroup<UDLuaViewRoot>(getContext(), this) {
            @Override
            protected void onDraw(Canvas canvas) {
                super.onDraw(canvas);
                onDrawCallback(canvas);
            }
        };
    }

    @Override
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDLuaViewRoot.class))
    })
    public void __onLuaGc() {
        super.__onLuaGc();
        final View view = getView();
        if (view == null) return;
        for (Runnable r : delayTasks.values()) {
            view.removeCallbacks(r);
        }
        delayTasks.clear();
    }

    @Override
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDLuaViewRoot.class))
    })
    public LuaValue[] refresh(LuaValue[] p) {
        view.invalidate();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = UDArray.class),
            }, returns = @LuaApiUsed.Type(UDLuaViewRoot.class))
    })
    public LuaValue[] invalidate(LuaValue[] p) {
        LuaValue.destroyAllParams(p);
//        LuaTable table = p[0].toLuaTable();
//        double l = table.get(1).toDouble();
//        double t = table.get(2).toDouble();
//        double r = table.get(3).toDouble();
//        double b = table.get(4).toDouble();
//        table.destroy();
//        view.invalidate(
//                DimenUtil.dpiToPx(l),
//                DimenUtil.dpiToPx(t),
//                DimenUtil.dpiToPx(r),
//                DimenUtil.dpiToPx(b));
        view.invalidate();
        return null;
    }

    @LuaApiUsed(ignore = true)
    protected LuaValue[] closeHardWare(LuaValue[] v) {
        UDPaint udpait = v.length > 0 && v[0].isUserdata() ? (UDPaint) v[0].toUserdata() : null;
        Paint paint = null;
        if (udpait != null && udpait.getJavaUserdata() != null) {
            paint = udpait.getJavaUserdata();
        }
        getView().setLayerType(View.LAYER_TYPE_SOFTWARE, paint);
        if (udpait != null) {
            udpait.destroy();
        }
        return null;
    }

    /**
     * Android Test only
     * <p>
     * 设置触摸事件 setOnTouchListener(function)
     * function原型: function(table) return bool
     * 会将触摸事件封装成table回调
     * table封装效果见: {@link #onTouchListener}
     */
    @LuaApiUsed(ignore = true)
    private LuaValue[] setOnTouchListener(LuaValue[] v) {
        if (onTouchFunction != null) {
            onTouchFunction.destroy();
        }
        if (onTouchNativeParams != null) {
            onTouchNativeParams.destroy();
        }
        onTouchFunction = v[0].toLuaFunction();
        onTouchNativeParams = v[1];
        if (!touchListenerSet) {
            getView().setOnTouchListener(onTouchListener);
            touchListenerSet = true;
        }
        return null;
    }

    /**
     * Android Test only
     * <p>
     * 在下一帧执行lua函数
     * <p>
     * doInNextFrame(function, ...)
     */
    @LuaApiUsed(ignore = true)
    private LuaValue[] doInNextFrame(LuaValue[] v) {
        final LuaFunction fun = v[0].toLuaFunction();
        final LuaValue[] params = sub(v, 1);
        getView().post(new Runnable() {
            @Override
            public void run() {
                try {
                    fun.invoke(params);
                } catch (InvokeError e) {
                    if (!Environment.hook(e, globals))
                        throw e;
                }
                fun.destroy();
                if (params != null) {
                    destroyAllParams(params);
                }
            }
        });
        return null;
    }

    /**
     * Android Test only
     * 延迟一段时间后执行lua函数
     * doAfter(key, function, delay, ...)
     * delay: s
     */
    @LuaApiUsed(ignore = true)
    private LuaValue[] doAfter(LuaValue[] v) {
        final String key = v[0].toJavaString();
        final LuaFunction fun = v[1].toLuaFunction();
        final long delay = (long) (v[2].toDouble() * 1000);
        final LuaValue[] params = sub(v, 3);
        final Runnable task = new Runnable() {
            @Override
            public void run() {
                try {
                    fun.invoke(params);
                } catch (InvokeError e) {
                    if (!Environment.hook(e, globals))
                        throw e;
                }
                fun.destroy();
                if (params != null) {
                    destroyAllParams(params);
                }
                delayTasks.remove(key);
            }
        };
        delayTasks.put(key, task);
        getView().postDelayed(task, delay);
        return null;
    }

    /**
     * Android Test only
     * 移除延迟任务
     * removeTask(key)
     */
    @LuaApiUsed(ignore = true)
    private LuaValue[] removeTask(LuaValue[] v) {
        final String key = v[0].toJavaString();
        Runnable task = delayTasks.remove(key);
        if (task != null) {
            getView().removeCallbacks(task);
        }
        return null;
    }

    /**
     * Android Test Only
     *
     * 设置onDraw回调
     *
     * onDraw(function, luaNativeValue)
     */
    @Override
    public LuaValue[] onDraw(LuaValue[] values) {
        onDrawNativeParams = values.length > 1 ? values[1] : null;
        return super.onDraw(values);
    }

    /**
     * Android Test Only
     */
    @Override
    public void onDrawCallback(Canvas canvas) {
        if (onDrawCallback != null) {
            if (udCanvas == null) {
                udCanvas = new UDCCanvas(getGlobals(), canvas);
                udCanvas.onJavaRef();
            }
            udCanvas.resetCanvas(canvas);
            int c = canvas.save();
            if (onDrawNativeParams != null) {
                onDrawCallback.invoke(varargsOf(udCanvas, onDrawNativeParams));
            } else {
                onDrawCallback.invoke(varargsOf(udCanvas));
            }

            canvas.restoreToCount(c);
        }
    }

    /**
     * 触摸事件处理，将事件封装成table
     * 封装方式:
     * {
     *      3: action(int),
     *      4: rawX(double),
     *      5: rawY(double),
     *      6: pointerCount(int),
     *      7: index(int), 当前特殊事件的index，如某个手指按下或抬起事件
     * (11 + n):    n取值[0, pointerCount]
     *      {
     *          0: x(double),
     *          1: y(double),
     *          2: pid(int)
     *      }
     * }
     */
    private View.OnTouchListener onTouchListener = new View.OnTouchListener() {
        private int maxPointerCount = 1;
        LuaTable eventTable;

        @Override
        public boolean onTouch(View v, android.view.MotionEvent event) {
            if (eventTable == null) {
                eventTable = LuaTable.create(globals);
            }
            parseTable(eventTable, event);
            LuaValue[] ret = onTouchFunction.invoke(varargsOf(eventTable, onTouchNativeParams));

            return (ret != null && ret.length > 0) && ret[0].toBoolean();
        }

        private void parseTable(LuaTable table, android.view.MotionEvent e) {
            table.set(MotionEvent.action, e.getActionMasked());
            table.set(MotionEvent.rawX, DimenUtil.pxToDpi(e.getRawX()));
            table.set(MotionEvent.rawY, DimenUtil.pxToDpi(e.getRawY()));
            table.set(MotionEvent.index, e.getActionIndex());
            table.set(MotionEvent.time, e.getEventTime());

            int c = e.getPointerCount();
            maxPointerCount = c > maxPointerCount ? c : maxPointerCount;
            table.set(MotionEvent.pCount, c);

            for (int i = 0; i < c; i++) {
                int idx = MotionEvent.idxFrom + i + 1;
                LuaValue pointer = table.get(idx);
                if (pointer.isNil()) {
                    pointer = LuaTable.create(globals);
                    table.set(idx, pointer);
                }

                pointer.set(MotionEvent.x, DimenUtil.pxToDpi(e.getX(i)));
                pointer.set(MotionEvent.y, DimenUtil.pxToDpi(e.getY(i)));
                pointer.set(MotionEvent.pid, e.getPointerId(i));
            }

            /*
             * 是否需要清空其他多点数据？
             */
            if (!CLEAR_NOT_USE_DATA) return;

            for (int i = c; i < maxPointerCount; i++) {
                int idx = MotionEvent.idxFrom + i + 1;
                LuaValue pointer = table.get(idx);
                if (pointer.isTable()) {
                    pointer.toLuaTable().clearArray(MotionEvent.x, MotionEvent.pid);
                }
            }
        }
    };
}
