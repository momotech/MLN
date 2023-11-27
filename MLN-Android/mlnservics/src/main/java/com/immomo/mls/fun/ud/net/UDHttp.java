/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.net;

import android.text.TextUtils;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.utils.LVCallback;
import com.immomo.mls.utils.MainThreadExecutor;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.functions.Function3;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;

import static com.immomo.mls.fun.ud.net.CachePolicy.API_ONLY;
import static com.immomo.mls.fun.ud.net.CachePolicy.CACHE_ONLY;
import static com.immomo.mls.fun.ud.net.CachePolicy.CACHE_OR_API;
import static com.immomo.mls.fun.ud.net.CachePolicy.CACHE_THEN_API;
import static com.immomo.mls.fun.ud.net.CachePolicy.REFRESH_CACHE_BY_API;

/**
 * http
 */
@LuaClass(name = "Http", gcByLua = false)
public class UDHttp {
    public static final String LUA_CLASS_NAME = "Http";

    protected static final String KEY_CACHE_POLICY = "cachePolicy";
    protected static final String KEY_ENC_TYPE = "encType";

    private String baseUrl;

    protected Globals globals;

    public UDHttp(Globals globals, LuaValue[] init) {
        this.globals = globals;
    }

    public void __onLuaGc() {
        MLSAdapterContainer.getThreadAdapter().cancelTaskByTag(hashCode());
        globals = null;
    }

    //<editor-fold desc="API">
    @LuaBridge
    public void setBaseUrl(String baseUrl) {
        if (!baseUrl.endsWith("/")) {
            baseUrl = baseUrl + "/";
        }
        this.baseUrl = baseUrl;
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "url", value = String.class),
                    @LuaBridge.Type(name = "params", value = Map.class),
                    @LuaBridge.Type(name = "callback", value = Function3.class, typeArgs = {Boolean.class, UDMap.class, UDMap.class, Unit.class}, typeArgsNullable = {false, true, true, false}),
            })
    })
    public void post(String url, Map params, LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().executeTaskByTag(hashCode(), generatePostTask(realUrl(url), params, callback));
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "url", value = String.class),
                    @LuaBridge.Type(name = "params", value = Map.class),
                    @LuaBridge.Type(name = "callback", value = Function3.class, typeArgs = {Boolean.class, UDMap.class, UDMap.class, Unit.class}, typeArgsNullable = {false, true, true, false}),
            })
    })
    public void get(String url, Map params, LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().executeTaskByTag(hashCode(), generateGetTask(realUrl(url), params, callback));
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "url", value = String.class),
                    @LuaBridge.Type(name = "params", value = Map.class),
                    @LuaBridge.Type(name = "progressCallback", value = Function2.class, typeArgs = {Float.class, Integer.class, Unit.class}),
                    @LuaBridge.Type(name = "callback", value = Function3.class, typeArgs = {Boolean.class, UDMap.class, UDMap.class, Unit.class}, typeArgsNullable = {false, true, true, false}),
            })
    })
    public void download(String url, Map params, LVCallback progressCallback, LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().executeTaskByTag(hashCode(), generateDownloadTask(realUrl(url), params, progressCallback, callback));
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "url", value = String.class),
                    @LuaBridge.Type(name = "params", value = Map.class),
                    @LuaBridge.Type(name = "filePaths", value = List.class),
                    @LuaBridge.Type(name = "parameterNames", value = List.class),
                    @LuaBridge.Type(name = "callback", value = Function3.class, typeArgs = {Boolean.class, UDMap.class, UDMap.class, Unit.class}, typeArgsNullable = {false, true, true, false}),
            })
    })
    public void upload(String url, Map params, List filePaths, List parameterNames, LVCallback callback) {
        Runnable task = generateUploadTask(realUrl(url), params, filePaths, parameterNames, callback);
        if (task != null) {
            MLSAdapterContainer.getThreadAdapter().executeTaskByTag(hashCode(), task);
        }
    }
    //</editor-fold>

    private String realUrl(String url) {
        if (TextUtils.isEmpty(baseUrl))
            return url;
        if (url.startsWith("http"))
            return url;
        if (url.startsWith("/")) {
            url = url.substring(1);
        }
        return baseUrl + url;
    }

    protected @NonNull
    Runnable generatePostTask(String url, Map params, LVCallback callback) {
        return new PostTask(globals, url, params, callback);
    }

    protected @NonNull
    Runnable generateGetTask(String url, Map params, LVCallback callback) {
        return new GetTask(globals, url, params, callback);
    }

    protected @NonNull
    Runnable generateDownloadTask(String url, Map params, LVCallback progressCallback, LVCallback callback) {
        return new DownloadTask(globals, url, params, progressCallback, callback);
    }

    protected
    Runnable generateUploadTask(String url, Map params, List fileList, List parameterNames, LVCallback callback) {
        return null;
    }

    protected static class GetTask extends BaseTask {

        protected GetTask(Globals g, String url, Map params, LVCallback callback) {
            super(g, url, params, callback);
        }

        @Override
        protected void doFromInternet(HttpResponse response, @EncType.Type int type) throws Exception {
            Utils.get(url, params, response);
        }
    }

    protected static class PostTask extends BaseTask {

        protected PostTask(Globals g, String url, Map params, LVCallback callback) {
            super(g, url, params, callback);
        }

        @Override
        protected void doFromInternet(HttpResponse response, @EncType.Type int type) throws Exception {
            Utils.post(url, params, response);
        }
    }

    protected static class DownloadTask extends BaseTask implements Utils.ProgressCallback {
        private String path;
        protected LVCallback progressCallback;

        protected DownloadTask(Globals g, String url, Map params, LVCallback progressCallback, LVCallback callback) {
            super(g, url, params, callback);
            this.progressCallback = progressCallback;
        }

        @Override
        protected void doFromInternet(HttpResponse response, @EncType.Type int type) throws Exception {
            Utils.download(url, path, params, this, response);
        }

        @Override
        protected int getCacheType() {
            return API_ONLY;
        }

        @Override
        protected void beforeTask() {
            Object o = params.remove(ResponseKey.Path);
            path = o != null ? o.toString() : null;
            if (TextUtils.isEmpty(path)) {
                path = new File(FileUtil.getCacheDir(), FileUtil.getUrlName(url)).getAbsolutePath();
            }
        }

        @Override
        public void onProgress(final float p, final long total) {
            if (progressCallback == null)
                return;
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    if (progressCallback != null)
                        progressCallback.call(p, total);
                }
            });
        }
    }

    protected abstract static class BaseTask implements Runnable {
        protected final String url;
        protected final Map params;
        protected final LVCallback callback;
        protected final Globals globals;

        protected BaseTask(Globals g, String url, Map params, LVCallback callback) {
            this.globals = g;
            this.url = url;
            this.params = params == null ? new HashMap() : params;
            this.callback = callback;
        }

        @Override
        public void run() {
            beforeTask();
            final HttpResponse response = newResponse();
            try {
                switch (getCacheType()) {
                    case CACHE_THEN_API:
                        HttpResponse cacheResponse = newResponse();
                        if (getFromCache(cacheResponse)) {
                            cacheResponse.setIsCache(true);
                            callback(globals, cacheResponse);
                        }
                        doFromInternet(response, getEncType());
                        updateCache(response);
                        break;
                    case CACHE_OR_API:
                        if (getFromCache(response)) {
                            response.setIsCache(true);
                        } else {
                            doFromInternet(response, getEncType());
                            updateCache(response);
                        }
                        break;
                    case CACHE_ONLY:
                        if (!getFromCache(response)) {
                            throw new Exception("no cache");
                        }
                        break;
                    case REFRESH_CACHE_BY_API:
                        doFromInternet(response, getEncType());
                        updateCache(response);
                        break;
                    case API_ONLY:
                    default:
                        doFromInternet(response, getEncType());
                        break;
                }
            } catch (Exception e) {
                parseError(e, response);
            } finally {
                callback(globals, response);
//                callback.destroy();
            }
        }

        /**
         * 获取缓存
         *
         * @param response
         * @return true if has cache, false otherwise
         */
        protected boolean getFromCache(HttpResponse response) {
            return false;
        }

        /**
         * 更新缓存
         *
         * @param response
         */
        protected void updateCache(HttpResponse response) {

        }

        protected void parseError(Exception e, HttpResponse response) {
            response.setStatusCode(-1);
            response.setResponseMsg(e.getMessage());
            response.setError(true);
        }

        protected abstract void doFromInternet(HttpResponse response, @EncType.Type int type) throws Exception;

        protected void beforeTask() {

        }

        protected HttpResponse newResponse() {
            return new HttpResponse();
        }

        protected void callback(final Globals globals, final HttpResponse response) {
            if (callback != null && globals != null && !globals.isDestroyed()) {
                MainThreadExecutor.post(new Runnable() {
                    @Override
                    public void run() {
                        if (globals.isDestroyed())
                            return;
                        if (response.isSuccess()) {
                            callback.call(LuaValue.True(), new UDMap(globals, response.getMessageMap()));
                        } else {
                            callback.call(LuaValue.False(),new UDMap(globals, response.getMessageMap()), new UDMap(globals, response.getMessageMap()));
                        }
                    }
                });
            }
        }

        protected @CachePolicy.CacheType
        int getCacheType() {
            Object o = params.remove(KEY_CACHE_POLICY);
            if (o == null) {
                return CachePolicy.API_ONLY;
            }
            if (o instanceof Integer) {
                return (int) o;
            }
            return Integer.parseInt(o.toString());
        }

        protected @EncType.Type
        int getEncType() {
            Object o = params.remove(KEY_ENC_TYPE);
            if (o == null) {
                return EncType.NORMAL;
            }
            if (o instanceof Integer) {
                return (int) o;
            }
            return Integer.parseInt(o.toString());
        }
    }
}