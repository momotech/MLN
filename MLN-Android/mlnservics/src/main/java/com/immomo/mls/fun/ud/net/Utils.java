/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.net;

import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.RelativePathUtils;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;
import java.util.Set;

/**
 * Created by XiongFangyu on 2018/8/10.
 */
final class Utils {

    static void post(String url, Map params, HttpResponse response) throws Exception{
        doMethod("POST", url, params, response, null);
    }

    static void get(String url, Map params, HttpResponse response) throws Exception{
        doMethod("GET", url, params, response, null);
    }

    static void download(String url, final String path, Map params, final ProgressCallback progressCallback, final HttpResponse response) throws Exception {
        doMethod("GET", url, params, response, new IReadData() {
            @Override
            public void readData(InputStream is, final int total) throws Exception {
                FileUtil.copy(is, path, total, new FileUtil.ProgressCallback() {
                    @Override
                    public void onProgress(final float p) {
                        progressCallback.onProgress(p, total);
                    }
                });
                response.setPath(RelativePathUtils.getLocalUrl(path));
            }
        });
    }

    private static void doMethod(String method, String url, Map params, HttpResponse response, IReadData readData) throws Exception{
        HttpURLConnection connection = null;
        try {

            if ("GET".equals(method)) {
                url = addParamsToUrl(url,params);
            }

            final URL URL = new URL(url);
            connection = (HttpURLConnection) URL.openConnection();
            connection.setRequestMethod(method);
            connection.setConnectTimeout(30000);

            if ("POST".equals(method)) {
                addParamsToHeader(params, connection);
            }

            connection.connect();
            int code = connection.getResponseCode();

            response.setStatusCode(code);

            InputStream in = connection.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(in));
            StringBuilder reponseBuilder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                reponseBuilder.append(line);
            }
            String finalServerString = reponseBuilder.toString();
            response.setSourceData(finalServerString);
            response.setResponseMsg(reponseBuilder.toString());
            response.setError(!(code == HttpURLConnection.HTTP_OK));


            if (readData != null && code == HttpURLConnection.HTTP_OK) {
                readData.readData(connection.getInputStream(), connection.getContentLength());
            }

        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    // 向 header 中添加 参数
    private static void addParamsToHeader(Map params, HttpURLConnection connection) {
        if (params != null) {
            Set<Map.Entry> entrySet = params.entrySet();
            for (Map.Entry e : entrySet) {
                Object k = e.getKey();
                Object v = e.getValue();
                if (k == null || v == null)
                    continue;
                connection.setRequestProperty(k.toString(), v.toString());
            }
        }
    }

    private static String addParamsToUrl(String url, Map params) {
        StringBuffer stringBuffer = new StringBuffer(url);

        stringBuffer.append("?");

        Set<Map.Entry> entrySet = params.entrySet();
        for (Map.Entry e : entrySet) {
            Object k = e.getKey();
            Object v = e.getValue();

            if (k == null || v == null)
                continue;

            stringBuffer.append(k);
            stringBuffer.append("=");
            stringBuffer.append(v);
            stringBuffer.append("&");
        }

        return stringBuffer.toString();
    }

    interface ProgressCallback {
        void onProgress(float p, long total);
    }

    private static interface IReadData {
        void readData(InputStream is, int total) throws Exception;
    }
}