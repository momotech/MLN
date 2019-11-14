package com.mln.demo.android.util;

import android.util.Log;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-07 12:25
 */
public class HttpHelper {

    public static final String GET = "GET";

    public interface HttpCallback {
        void successCallback(String str);

        void errorCallback();
    }

    public static void doMethod(String method, String url, HttpCallback callback) {

        String result = null;
        HttpURLConnection connection = null;
        try {
            final URL URL = new URL(url);
            connection = (HttpURLConnection) URL.openConnection();
            connection.setRequestMethod(method);
            connection.setConnectTimeout(30000);
            connection.connect();
            int code = connection.getResponseCode();
            Log.e("http", "code---->" + code);
            if (code == HttpURLConnection.HTTP_OK) {

                InputStream in = connection.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(in));
                StringBuilder reponseBuilder = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    reponseBuilder.append(line);
                }
                result = reponseBuilder.toString();
                callback.successCallback(result);
            } else {
                Log.e("http", "请求失败---->" + code);
                callback.errorCallback();
            }

        } catch (Exception e) {
            e.printStackTrace();
            Log.e("http", "exception---->" + e.getMessage());
            callback.errorCallback();
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    public static void reqHttp(final String method, final String url, final HttpCallback callback) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                doMethod(method, url, callback);
            }
        }).start();
    }

}
