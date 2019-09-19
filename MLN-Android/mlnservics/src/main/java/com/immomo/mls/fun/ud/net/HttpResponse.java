/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.net;

import android.text.TextUtils;

import com.immomo.mls.util.JsonUtil;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/6/29.
 */
public class HttpResponse {
    public static final String CACHE_KEY = ResponseKey.Cache;
    public static final String ERROR_MSG_KEY = ErrorKey.MSG;
    public static final String ERROR_CODE_KEY = ErrorKey.CODE;

    private int code;
    private String message;
    private Map messageMap;
    private boolean isCache = false;
    private String localPath;
    private boolean error = false;

    public void setStatusCode(int code) {
        this.code = code;
    }

    public void setResponseMsg(String msg) {
        this.message = msg;
        try {
            JSONObject jo = new JSONObject(message);
            messageMap = JsonUtil.toMap(jo);
            setIsCache(isCache);
            setPath(localPath);
        } catch (Throwable t) {
            messageMap = new HashMap();
            messageMap.put(ERROR_MSG_KEY, msg);
            messageMap.put(ERROR_CODE_KEY, code);
            error = true;
        }
    }

    public void setSourceData(String data) {
        message = data;
    }

    public void setIsCache(boolean isCache) {
        this.isCache = isCache;
        if (messageMap != null)
            messageMap.put(CACHE_KEY, isCache);
    }

    public void setPath(String localPath) {
        this.localPath = localPath;
        if (messageMap != null && !TextUtils.isEmpty(localPath)) {
            messageMap.put(ResponseKey.Path, localPath);
        }
    }

    public void setResponse(Map<String, Object> res) {
        messageMap = res;
        setIsCache(isCache);
        setPath(localPath);
    }

    public boolean isError() {
        return error;
    }

    public void setError(boolean error) {
        this.error = error;
    }

    public boolean isResponseValid() {
        return messageMap != null;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public Map getMessageMap() {
        return messageMap;
    }

    public boolean isSuccess() {
        return !error;
    }
}