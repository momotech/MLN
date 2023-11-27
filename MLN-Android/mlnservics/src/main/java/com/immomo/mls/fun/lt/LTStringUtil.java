/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.lt;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Paint;
import android.text.TextUtils;
import android.util.TypedValue;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.TypeFaceAdapter;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.EncryptUtil;
import com.immomo.mls.util.JsonUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaValue;

import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by fanqiang on 2018/10/11.
 */
@LuaClass(isStatic = true, isSingleton = true)
public class LTStringUtil {
    public static final String LUA_CLASS_NAME = "StringUtil";

    @LuaBridge
    public static LuaValue md5(String content) {
        if (content == null) {
            return LuaValue.Nil();
        }

        return LuaString.valueOf(EncryptUtil.md5Hex(content));
    }

    @LuaBridge
    public static int length(String content) {
        if (content == null) {
            return 0;
        }
        return content.length();
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "obj", value = String.class)
            }, returns = @LuaBridge.Type(value = Map.class))
    })
    public static Map jsonToMap(LuaValue obj) {
        Map<String, Object> map = null;
        try {
            String temp = null;
            if (obj.isString()) {
                temp = obj.toJavaString();
            }
            obj.destroy();
            if (TextUtils.isEmpty(temp)) {
                return null;
            }
            map = JsonUtil.toMap(new JSONObject(temp));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return map;
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "obj", value = String.class)
            }, returns = @LuaBridge.Type(value = List.class))
    })
    public static List jsonToArray(LuaValue obj) {
        List array = null;
        try {
            String temp = null;
            if (obj.isString()) {
                temp = obj.toJavaString();
            }
            obj.destroy();
            if (TextUtils.isEmpty(temp)) {
                return null;
            }
            array = JsonUtil.toList(new JSONArray(temp));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return array;
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "obj", value = List.class)
            }, returns = @LuaBridge.Type(value = String.class))
    })
    public static String arrayToJSON(LuaValue obj) {
        if (obj == null) {
            return null;
        }
        List list = null;
        if (obj instanceof UDArray) {
            list = ((UDArray) obj).getArray();
        }
        obj.destroy();
        if (list == null) {
            return null;
        }
        return JsonUtil.toJsonArray(list).toString();
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "obj", value = Map.class)
            }, returns = @LuaBridge.Type(value = String.class))
    })
    public static String mapToJSON(LuaValue obj) {
        if (obj == null) {
            return null;
        }
        Map map = null;
        if (obj instanceof UDMap) {
            map = ((UDMap) obj).getMap();
        }
        obj.destroy();
        if (map == null) {
            return null;
        }
        return JsonUtil.toJson(map).toString();
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "content", value = String.class),
                    @LuaBridge.Type(name = "fontSize", value = Float.class)
            }, returns = @LuaBridge.Type(value = UDSize.class))
    })
    public static UDSize sizeWithContentFontSize(Globals g, String content, float fontSize) {
        return callSizeWithContentFontSize(g, content, fontSize, null);
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "content", value = String.class),
                    @LuaBridge.Type(name = "fontName", value = String.class),
                    @LuaBridge.Type(name = "fontSize", value = Float.class)
            }, returns = @LuaBridge.Type(value = UDSize.class))
    })
    public static UDSize sizeWithContentFontNameSize(Globals g, String content, String fontName, float fontSize) {
        return callSizeWithContentFontSize(g, content, fontSize, fontName);
    }

    private static UDSize callSizeWithContentFontSize(Globals g, String content, float fontSize, @Nullable String fontName) {
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

    @LuaBridge
    public static @NonNull
    String replaceAllChar(@NonNull String src, String find, String replacement) {
        return src.replace(find, replacement);
    }

}