/*
 * Copyright 2007 ZXing authors
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

package com.google.zxing;

/**
 * Thrown when a barcode was not found in the image. It might have been
 * partially detected but could not be confirmed.
 *
 * @author Sean Owen
 */
public final class NotFoundException extends ReaderException {

    private static final NotFoundException INSTANCE = new NotFoundException();

    static {
        INSTANCE.setStackTrace(NO_TRACE); // since it's meaningless
    }

    private NotFoundException() {
        // do nothing
    }

    public static NotFoundException getNotFoundInstance() {
        return INSTANCE;
    }

}