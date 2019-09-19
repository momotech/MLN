/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;


import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;

/**
 * IO 处理
 *
 * @author song
 * @date 15/11/10
 */
public class IOUtil {
    public static final int BUFFER_SIZE = 8 * 1024; //8k

    public static void closeQuietly(Closeable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (Throwable t) {}
        }
    }

    /**
     * convert a inputstream to bytes
     *
     * @param input
     * @return
     */
    public static byte[] toBytes(final InputStream input) {
        byte[] buffer = new byte[BUFFER_SIZE];
        int bytesRead;
        final ByteArrayOutputStream output = new ByteArrayOutputStream();
        try {
            while ((bytesRead = input.read(buffer)) != -1) {
                output.write(buffer, 0, bytesRead);
            }
            return output.toByteArray();
        } catch (Exception e) {
            return null;
        } finally {
            closeQuietly(output);
        }
    }

    /**
     * convert input stream of inputEncoding to stream of DEFAULT_ENCODE
     *
     * @param input
     * @param inputEncoding
     * @return
     */
    public static byte[] toBytes(final InputStream input, final String inputEncoding) {
        byte[] result = toBytes(input);
        if (result != null && inputEncoding != null && !"utf-8".equalsIgnoreCase(inputEncoding)) {
            try {
                return new String(result, inputEncoding).getBytes("utf-8");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return result;
    }

    /**
     * read input stream to bytes
     *
     * @param input
     * @param length
     * @return
     */
    public static byte[] toBytes(final InputStream input, int length) {
        if (length > 0) {
            byte[] bytes = new byte[length];
            int count;
            int pos = 0;
            try {
                while (pos < length && ((count = input.read(bytes, pos, length - pos)) != -1)) {
                    pos += count;
                }
            } catch (IOException e) {
                e.printStackTrace();
            }

            if (pos != length) {
                return null;
            }
            return bytes;
        } else {
            return toBytes(input);
        }
    }

}