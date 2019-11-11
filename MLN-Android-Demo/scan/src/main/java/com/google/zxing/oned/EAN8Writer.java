/*
 * Copyright 2009 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.zxing.oned;

import java.util.Map;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;

/**
 * This object renders an EAN8 code as a {@link BitMatrix}.
 *
 * @author aripollak@gmail.com (Ari Pollak)
 */
public final class EAN8Writer extends UPCEANWriter {

    private static final int CODE_WIDTH = 3 + // start guard
            (7 * 4) + // left bars
            5 + // middle guard
            (7 * 4) + // right bars
            3; // end guard

    @Override
    public BitMatrix encode(String contents,
                            BarcodeFormat format,
                            int width,
                            int height,
                            Map<EncodeHintType, ?> hints) throws WriterException {
        if (format != BarcodeFormat.EAN_8) {
            throw new IllegalArgumentException("Can only encode EAN_8, but got "
                    + format);
        }

        return super.encode(contents, format, width, height, hints);
    }

    /**
     * @return a byte array of horizontal pixels (false = white, true = black)
     */
    @Override
    public boolean[] encode(String contents) {
        if (contents.length() != 8) {
            throw new IllegalArgumentException(
                    "Requested contents should be 8 digits long, but got " + contents.length());
        }

        boolean[] result = new boolean[CODE_WIDTH];
        int pos = 0;

        pos += appendPattern(result, pos, UPCEANReader.START_END_PATTERN, true);

        for (int i = 0; i <= 3; i++) {
            int digit = Integer.parseInt(contents.substring(i, i + 1));
            pos += appendPattern(result, pos, UPCEANReader.L_PATTERNS[digit], false);
        }

        pos += appendPattern(result, pos, UPCEANReader.MIDDLE_PATTERN, false);

        for (int i = 4; i <= 7; i++) {
            int digit = Integer.parseInt(contents.substring(i, i + 1));
            pos += appendPattern(result, pos, UPCEANReader.L_PATTERNS[digit], true);
        }
        appendPattern(result, pos, UPCEANReader.START_END_PATTERN, true);

        return result;
    }

}
