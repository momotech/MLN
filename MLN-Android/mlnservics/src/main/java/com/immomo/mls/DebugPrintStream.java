/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls;

import com.immomo.mls.log.ErrorPrintStream;
import com.immomo.mls.log.ErrorType;

import java.io.FileDescriptor;
import java.io.FileOutputStream;
import java.io.PrintStream;

/**
 * Created by Xiong.Fangyu on 2020/8/21
 */
public class DebugPrintStream extends PrintStream implements ErrorPrintStream {
    public PrintStream inner;
    public DebugPrintStream(PrintStream inner) {
        super(new FileOutputStream(FileDescriptor.out));
        this.inner = inner;
    }

    @Override
    public void print(String s) {
        if (inner != null)
            inner.print(s);
        HotReloadHelper.log(s);
    }

    @Override
    public void println() {
        if (inner != null)
            inner.println();
    }

    @Override
    public void error(String s) {
        if (inner instanceof ErrorPrintStream) {
            ((ErrorPrintStream) inner).error(s);
        }
        HotReloadHelper.onError(s);
    }

    @Override
    public void error(String msg, ErrorType errorType) {
        if (inner instanceof ErrorPrintStream) {
            ((ErrorPrintStream) inner).error(msg, errorType);
        }
        HotReloadHelper.onError(msg);
    }
}
