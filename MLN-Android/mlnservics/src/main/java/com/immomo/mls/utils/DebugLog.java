/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import android.annotation.SuppressLint;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.wrapper.ScriptBundle;

import org.luaj.vm2.Globals;

import java.io.PrintStream;

import androidx.annotation.Nullable;

/**
 * Created by Xiong.Fangyu on 2019/3/21
 */
public class DebugLog implements Cloneable {
    protected static final double MS = 1000000;
    public long startTime;
    public double globalPrepareTime;
    public double envPrepareTime;
    public double loadTime;
    public double compileTime;
    public double prepareTime;
    public double executedTime;
    public double totalTime;
    public int bundleSize;
    public @Nullable String bundleString;
    public boolean executeSuccess;
    public String url;
    public String realLoadUrl;

    public void onStart(String url) {
        clear();
        this.url = url;
        startTime = now();
    }

    public void onGlobalPrepared() {
        long now = now();
        globalPrepareTime = (now - startTime) / MS;
        startTime = now;
    }

    public void envPrepared() {
        long now = now();
        envPrepareTime = (now - startTime) / MS;
        startTime = now;
    }

    public void loaded(ScriptBundle bundle) {
        if (bundle != null) {
            realLoadUrl = bundle.getUrl();
            this.bundleSize = bundle.size() + 1;
            if (MLSEngine.DEBUG)
                this.bundleString = bundle.getFlagDebugString();
        }
        long now = now();
        loadTime = (now - startTime) / MS;
        startTime = now;
    }

    public void prepared() {
        long now = now();
        prepareTime = (now - startTime) / MS;
        startTime = now;
    }

    public void compileEnd() {
        long now = now();
        compileTime = (now - startTime) / MS;
        startTime = now;
    }

    public void executedEnd(boolean success) {
        executeSuccess = success;
        long now = now();
        executedTime = (now - startTime) / MS;
        totalTime = executedTime + compileTime + prepareTime + loadTime + envPrepareTime;
    }

    public void clear() {
        url = null;
        bundleSize = 0;
        bundleString = null;
        envPrepareTime = 0;
        startTime = 0;
        loadTime = 0;
        compileTime = 0;
        prepareTime = 0;
        executedTime = 0;
        executeSuccess = false;
    }

    protected void log(PrintStream ps) {
        if (!MLSEngine.DEBUG)
            return;
        log(createLog(), ps);
    }

    private static final String TEMPLATE = "------Lua page executed. \n" +
            "url: %s\nrealLoadUrl: %s\n" +
            "load file : %d \t type: %s\n" +
            "global prepare cast: %.2f\n"+
            "prepare env cast: %.2f\n" +
            "load cast: %.2f\n" +
            "compile cast: %.2f\n" +
            "thread switch cast: %.2f\n" +
            "executed cast: %.2f\n" +
            "total: %.2f\n" +
            "arm: %s\n";

    @SuppressLint("DefaultLocale")
    public String createLog() {
        return String.format(TEMPLATE,
                url, realLoadUrl,
                bundleSize, String.valueOf(bundleString),
                globalPrepareTime,
                envPrepareTime,
                loadTime,
                compileTime,
                prepareTime,
                executedTime,
                totalTime,
                Globals.is32bit()?"32":"64");
    }

    protected void log(String s, PrintStream ps) {
        if (!MLSEngine.DEBUG) {
            return;
        }
        if (ps != null) {
            ps.print(s);
            ps.println();
        }
    }

    protected static final long now() {
        return System.nanoTime();
    }
}