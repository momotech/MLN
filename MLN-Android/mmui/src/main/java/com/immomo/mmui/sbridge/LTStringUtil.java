package com.immomo.mmui.sbridge;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Paint;
import android.text.TextUtils;
import android.util.TypedValue;

import androidx.annotation.Nullable;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.TypeFaceAdapter;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.EncryptUtil;
import com.immomo.mls.util.JsonUtil;
import com.immomo.mmui.ud.UDSize;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.List;
import java.util.Map;

/**
 * Created by MLN Template
 * 注册方法：
 * new Register.NewStaticHolder(LTStringUtil.LUA_CLASS_NAME, LTStringUtil.class)
 */
@LuaApiUsed
public class LTStringUtil {
    /**
     * Lua类名
     */
    public static final String LUA_CLASS_NAME = "StringUtil";
    //<editor-fold desc="native method">

    /**
     * 初始化方法
     * 反射调用
     *
     * @see com.immomo.mls.wrapper.Register.NewStaticHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     *
     * @see com.immomo.mls.wrapper.Register.NewStaticHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>
    //<editor-fold desc="Bridge API">

    @LuaApiUsed
    static String md5(String content) {
        if (content == null)
            return null;
        return EncryptUtil.md5Hex(content);
    }

    @LuaApiUsed
    static int length(String content) {
        if (content == null) {
            return 0;
        }
        return content.length();
    }

    @CGenerate(params = "G")
    @LuaApiUsed
    static UDMap jsonToMap(long g, String temp) {
        if (TextUtils.isEmpty(temp)) {
            return null;
        }
        Map<String, Object> map = null;
        try {
            map = JsonUtil.toMap(new JSONObject(temp));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return new UDMap(Globals.getGlobalsByLState(g), map);
    }

    @CGenerate(params = "G")
    @LuaApiUsed
    static UDArray jsonToArray(long g, String temp) {
        if (TextUtils.isEmpty(temp)) {
            return null;
        }
        List array = null;
        try {
            array = JsonUtil.toList(new JSONArray(temp));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return new UDArray(Globals.getGlobalsByLState(g), array);
    }

    @LuaApiUsed
    static String arrayToJSON(UDArray arr) {
        if (arr == null) {
            return null;
        }
        List list = arr.getJavaUserdata();
        arr.destroy();
        return JsonUtil.toJsonArray(list).toString();
    }

    @LuaApiUsed
    static String mapToJSON(UDMap obj) {
        if (obj == null) {
            return null;
        }
        Map map = obj.getJavaUserdata();
        obj.destroy();
        return JsonUtil.toJson(map).toString();
    }

    @CGenerate(params = "G")
    @LuaApiUsed
    public static UDSize sizeWithContentFontSize(long g, String content, float fontSize) {
        return callSizeWithContentFontSize(g, content, fontSize, null);
    }

    @CGenerate(params = "G")
    @LuaApiUsed
    public static UDSize sizeWithContentFontNameSize(long g, String content, String fontName, float fontSize) {
        return callSizeWithContentFontSize(g, content, fontSize, fontName);
    }

    private static UDSize callSizeWithContentFontSize(long L, String content, float fontSize, @Nullable String fontName) {
        Globals g = Globals.getGlobalsByLState(L);
        LuaViewManager m = (LuaViewManager) g.getJavaUserdata();
        Context c = m != null ? m.context : null;
        if (c == null || TextUtils.isEmpty(content) || fontSize <= 0) {
            return new UDSize(g, new Size());
        }
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        Resources r = c.getResources();
        float textSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, fontSize, r.getDisplayMetrics());
        paint.setTextSize(textSize);

        int br = 1;
        if (!TextUtils.isEmpty(fontName)) {
            TypeFaceAdapter a = MLSAdapterContainer.getTypeFaceAdapter();
            if (a != null)
                paint.setTypeface(a.create(fontName));
        }

        String maxLenghtText = null;
        if (content.contains("\n")) {
            String[] splits = content.split("\n");
            br = splits.length;
            for (String split : splits) {
                if (maxLenghtText == null) {
                    maxLenghtText = split;
                    continue;
                }
                if (paint.measureText(maxLenghtText) < paint.measureText(split)) {
                    maxLenghtText = split;
                }
            }
        } else {
            maxLenghtText = content;
        }

        Paint.FontMetricsInt fontMetrics = paint.getFontMetricsInt();
        float singleHeight = (fontMetrics.descent - fontMetrics.ascent) * br;

        UDSize size = new UDSize(g, new Size());
        size.setWidth((float) Math.ceil(DimenUtil.pxToDpi(paint.measureText(maxLenghtText))));
        size.setHeight((float) Math.ceil(DimenUtil.pxToDpi(singleHeight)));
        return size;
    }
    //</editor-fold>

}
