package com.immomo.mls.utils;

import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;

/**
 * Created by wangduanqing on 2017/4/26.
 */

public class IOUtils {

    public static void closeQuietly(Closeable closeable) {
        closeAllQuietly(closeable);
    }

    public static void closeAllQuietly(Closeable... closeable) {
        if (closeable == null) {
            return;
        }
        for (Closeable c : closeable) {
            if (c != null) {
                try {
                    c.close();
                } catch (IOException ioe) {
                    // ignore
                }
            }
        }
    }

    public static byte[] toByteArray(URL url) throws Exception {
        URLConnection conn = url.openConnection();
        try {
            InputStream inputStream = conn.getInputStream();
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            byte[] buffer = new byte[4096];
            int len;
            while ((len = inputStream.read(buffer)) != -1) {
                output.write(buffer, 0, len);
            }
            inputStream.close();
            return output.toByteArray();
        } finally {
            if (conn instanceof HttpURLConnection) {
                ((HttpURLConnection) conn).disconnect();
            }
        }
    }

    public static String toString(InputStream inputStream) throws Exception {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buffer = new byte[4096];
        int len;
        while ((len = inputStream.read(buffer)) != -1) {
            output.write(buffer, 0, len);
        }
        inputStream.close();
        return new String(output.toByteArray());
    }
}
