/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.log;

import androidx.annotation.NonNull;

import com.immomo.mls.utils.MainThreadExecutor;

import java.io.FileDescriptor;
import java.io.FileOutputStream;
import java.io.PrintStream;

/**
 * Created by XiongFangyu on 2018/9/6.
 */
public class DefaultPrintStream extends PrintStream implements ErrorPrintStream {
    private final IPrinter printer;
    public DefaultPrintStream(@NonNull IPrinter out) {
        super(new FileOutputStream(FileDescriptor.out));
        printer = out;
    }

    public IPrinter getPrinter() {
        return printer;
    }

    public void print(final String s) {
        if (MainThreadExecutor.isMainThread()) {
            printer.print(s);
        } else {
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    printer.print(s);
                }
            });
        }
    }

    public void println() {
        if (MainThreadExecutor.isMainThread()) {
            printer.println();
        } else {
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    printer.println();
                }
            });
        }
    }

    public void error(final String s) {
        if (MainThreadExecutor.isMainThread()) {
            printer.error(s);
        } else {
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    printer.error(s);
                }
            });
        }
    }

    public void error(final String msg, final ErrorType errorType) {
        if (MainThreadExecutor.isMainThread()) {
            printer.error(msg, errorType);
        } else {
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    printer.error(msg, errorType);
                }
            });
        }
    }
}