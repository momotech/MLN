package com.google.zxing;

import android.app.Activity;
import android.graphics.Bitmap;

import com.google.zxing.client.android.result.ResultHandler;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by XiongFangyu on 2018/4/11.
 */
public class OuterResultHandler {
    private static List<IResultHandler> resultHandlers = new ArrayList<>(2);

    /**
     * @hide
     */
    public static boolean handleDecodeInternally(Activity activity, Result rawResult, ResultHandler resultHandler, Bitmap barcode) {
        final int l = resultHandlers.size();
        for (int i = 0; i < l; i++) {
            IResultHandler handler = resultHandlers.get(i);
            if (handler != null) {
                if (handler.handle(activity, rawResult, resultHandler, barcode)) {
                    return true;
                }
            }
        }
        return false;
    }

    public static void registerResultHandler(IResultHandler handler) {
        if (!resultHandlers.contains(handler)) {
            resultHandlers.add(0, handler);
        }
    }

    public static void unregisterResultHandler(IResultHandler handler) {
        resultHandlers.remove(handler);
    }

    public interface IResultHandler {
        boolean handle(Activity activity, Result rawResult, ResultHandler resultHandler, Bitmap barcode);
    }
}
