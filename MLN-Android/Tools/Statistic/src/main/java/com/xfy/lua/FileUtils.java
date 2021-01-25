/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.lua;

import java.io.*;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public class FileUtils {
    public static final int BUFFER_SIZE = 8 * 1024; //8k

    public static byte[] readBytes(File f) throws IOException {
        try (InputStream inputStream = new FileInputStream(f)) {
            return toBytes(inputStream);
        }
    }

    public static void closeQuietly(Closeable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (Throwable t) {}
        }
    }

    public static byte[] toBytes(final InputStream input) {
        byte[] buffer = new byte[BUFFER_SIZE];
        int bytesRead;
        try (ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            while ((bytesRead = input.read(buffer)) != -1) {
                output.write(buffer, 0, bytesRead);
            }
            return output.toByteArray();
        } catch (Exception e) {
            return null;
        }
    }

    public static void writeFile(File file, byte[] data) throws Exception {
        try (BufferedOutputStream dest = new BufferedOutputStream(new FileOutputStream(file), BUFFER_SIZE)) {
            dest.write(data);
            dest.flush();
        }
    }
}
