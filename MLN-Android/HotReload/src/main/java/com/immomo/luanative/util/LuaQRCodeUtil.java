/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.util;

//import com.google.zxing.BarcodeFormat;
//import com.google.zxing.EncodeHintType;
//import com.google.zxing.MultiFormatWriter;
//import com.google.zxing.WriterException;
//import com.google.zxing.common.BitMatrix;
//
//import javax.swing.*;
//import java.awt.image.BufferedImage;
//import java.util.HashMap;
//import java.util.Map;

//import static com.google.zxing.client.j2se.MatrixToImageConfig.BLACK;
//import static com.google.zxing.client.j2se.MatrixToImageConfig.WHITE;

public class LuaQRCodeUtil {

//    public static ImageIcon generateQRCode(String content, int width, int height) {
//        // 设置字符集编码
//        Map<EncodeHintType, Object> hints = new HashMap<>();
//        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
//        try {
//            BitMatrix bitMatrix = new MultiFormatWriter().encode(content, BarcodeFormat.QR_CODE, width, height, hints);
//            BufferedImage img = toBufferedImage(bitMatrix);
//            return new ImageIcon(img);
//        } catch (WriterException e) {
//
//        }
//        return null;
//    }
//
//    public static BufferedImage toBufferedImage(BitMatrix matrix) {
//        int width = matrix.getWidth();
//        int height = matrix.getHeight();
//        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
//        for (int x = 0; x < width; x++) {
//            for (int y = 0; y < height; y++) {
//                image.setRGB(x, y,  (matrix.get(x, y) ? BLACK : WHITE));
//            }
//        }
//        return image;
//    }
}