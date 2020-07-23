/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import com.immomo.mls.adapter.ConsoleLoggerAdapter;
import com.immomo.mls.adapter.IFileCache;
import com.immomo.mls.adapter.MLSEmptyViewAdapter;
import com.immomo.mls.adapter.MLSGlobalEventAdapter;
import com.immomo.mls.adapter.MLSGlobalStateListener;
import com.immomo.mls.adapter.MLSHttpAdapter;
import com.immomo.mls.adapter.MLSLoadViewAdapter;
import com.immomo.mls.adapter.MLSQrCaptureAdapter;
import com.immomo.mls.adapter.MLSReloadButtonCreator;
import com.immomo.mls.adapter.MLSResourceFinderAdapter;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.adapter.OnRemovedUserdataAdapter;
import com.immomo.mls.adapter.PreinstallError;
import com.immomo.mls.adapter.ScriptReaderCreator;
import com.immomo.mls.adapter.ToastAdapter;
import com.immomo.mls.adapter.TypeFaceAdapter;
import com.immomo.mls.adapter.X64PathAdapter;
import com.immomo.mls.adapter.impl.DefaultConsoleLoggerAdapter;
import com.immomo.mls.adapter.impl.DefaultEmptyViewAdapter;
import com.immomo.mls.adapter.impl.DefaultHttpAdapter;
import com.immomo.mls.adapter.impl.DefaultLoadViewAdapter;
import com.immomo.mls.adapter.impl.DefaultResourceFinderAdapterImpl;
import com.immomo.mls.adapter.impl.DefaultScriptReaderCreatorImpl;
import com.immomo.mls.adapter.impl.DefaultThreadAdapter;
import com.immomo.mls.adapter.impl.DefaultToastAdapter;
import com.immomo.mls.adapter.impl.DefaultTypeFaceAdapter;
import com.immomo.mls.adapter.impl.FileCacheImpl;
import com.immomo.mls.adapter.impl.MLSReloadButtonCreatorImpl;
import com.immomo.mls.adapter.impl.X64PathAdapterImpl;
import com.immomo.mls.fun.ui.DefaultSafeAreaAdapter;
import com.immomo.mls.fun.ui.MLNSafeAreaAdapter;
import com.immomo.mls.provider.ImageProvider;
import com.immomo.mls.utils.AssertUtils;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class MLSAdapterContainer {
    private static MLSThreadAdapter threadAdapter = new DefaultThreadAdapter();
    private static ConsoleLoggerAdapter consoleLoggerAdapter = new DefaultConsoleLoggerAdapter();
    private static MLSHttpAdapter httpAdapter = new DefaultHttpAdapter();
    private static MLSGlobalStateListener globalStateListener;
    private static ToastAdapter toastAdapter = new DefaultToastAdapter();
    private static MLSGlobalEventAdapter globalEventAdapter;
    private static MLSEmptyViewAdapter emptyViewAdapter = new DefaultEmptyViewAdapter();
    private static MLSLoadViewAdapter loadViewAdapter = new DefaultLoadViewAdapter();
    private static TypeFaceAdapter typeFaceAdapter = new DefaultTypeFaceAdapter();
    private static MLSResourceFinderAdapter resourceFinderAdapter = new DefaultResourceFinderAdapterImpl();
    private static ImageProvider imageProvider;
    private static ScriptReaderCreator scriptReaderCreator = new DefaultScriptReaderCreatorImpl();
    private static MLSQrCaptureAdapter qrCaptureAdapter;
    private static OnRemovedUserdataAdapter onRemovedUserdataAdapter;
    private static MLSReloadButtonCreator reloadButtonCreator = new MLSReloadButtonCreatorImpl();
    private static PreinstallError preinstallError;
    private static IFileCache fileCache = new FileCacheImpl();
    private static MLNSafeAreaAdapter safeAreaAdapter = new DefaultSafeAreaAdapter();
    private static X64PathAdapter x64PathAdapter = new X64PathAdapterImpl();

    public static MLSThreadAdapter getThreadAdapter() {
        return threadAdapter;
    }

    public static void setThreadAdapter(MLSThreadAdapter threadAdapter) {
        MLSAdapterContainer.threadAdapter = threadAdapter;
    }

    public static MLSQrCaptureAdapter getQrCaptureAdapter() {
        return qrCaptureAdapter;
    }

    public static void setQrCaptureAdapter(MLSQrCaptureAdapter qrCaptureAdapter) {
        MLSAdapterContainer.qrCaptureAdapter = qrCaptureAdapter;
    }

    public static ConsoleLoggerAdapter getConsoleLoggerAdapter() {
        return consoleLoggerAdapter;
    }

    public static void setConsoleLoggerAdapter(ConsoleLoggerAdapter consoleLoggerAdapter) {
        MLSAdapterContainer.consoleLoggerAdapter = consoleLoggerAdapter;
    }

    public static @NonNull MLSHttpAdapter getHttpAdapter() {
        return httpAdapter;
    }

    public static void setHttpAdapter(MLSHttpAdapter httpAdapter) {
        MLSAdapterContainer.httpAdapter = httpAdapter;
    }

    public static MLSGlobalStateListener getGlobalStateListener() {
        return globalStateListener;
    }

    public static void setGlobalStateListener(MLSGlobalStateListener globalStateListener) {
        MLSAdapterContainer.globalStateListener = globalStateListener;
    }

    public static ToastAdapter getToastAdapter() {
        return toastAdapter;
    }

    public static void setToastAdapter(ToastAdapter toastAdapter) {
        MLSAdapterContainer.toastAdapter = toastAdapter;
    }

    public static MLSGlobalEventAdapter getGlobalEventAdapter() {
        return globalEventAdapter;
    }

    public static void setGlobalEventAdapter(MLSGlobalEventAdapter globalEventAdapter) {
        MLSAdapterContainer.globalEventAdapter = globalEventAdapter;
    }

    public static MLSEmptyViewAdapter getEmptyViewAdapter() {
        return emptyViewAdapter;
    }

    public static void setEmptyViewAdapter(MLSEmptyViewAdapter emptyViewAdapter) {
        MLSAdapterContainer.emptyViewAdapter = emptyViewAdapter;
    }

    public static MLSLoadViewAdapter getLoadViewAdapter() {
        return loadViewAdapter;
    }

    public static void setLoadViewAdapter(MLSLoadViewAdapter loadViewAdapter) {
        MLSAdapterContainer.loadViewAdapter = loadViewAdapter;
    }

    public static TypeFaceAdapter getTypeFaceAdapter() {
        return typeFaceAdapter;
    }

    public static void setTypeFaceAdapter(TypeFaceAdapter typeFaceAdapter) {
        MLSAdapterContainer.typeFaceAdapter = typeFaceAdapter;
    }

    public static MLSResourceFinderAdapter getResourceFinderAdapter() {
        return resourceFinderAdapter;
    }

    public static void setResourceFinderAdapter(MLSResourceFinderAdapter resourceFinderAdapter) {
        MLSAdapterContainer.resourceFinderAdapter = resourceFinderAdapter;
    }

    public static ImageProvider getImageProvider() {
        return imageProvider;
    }

    public static void setImageProvider(ImageProvider imageProvider) {
        MLSAdapterContainer.imageProvider = imageProvider;
    }

    public static ScriptReaderCreator getScriptReaderCreator() {
        return scriptReaderCreator;
    }

    public static void setScriptReaderCreator(ScriptReaderCreator scriptReaderCreator) {
        MLSAdapterContainer.scriptReaderCreator = scriptReaderCreator;
    }

    public static OnRemovedUserdataAdapter getOnRemovedUserdataAdapter() {
        return onRemovedUserdataAdapter;
    }

    public static void setOnRemovedUserdataAdapter(OnRemovedUserdataAdapter onRemovedUserdataAdapter) {
        MLSAdapterContainer.onRemovedUserdataAdapter = onRemovedUserdataAdapter;
    }

    public static MLSReloadButtonCreator getReloadButtonCreator() {
        return reloadButtonCreator;
    }

    public static void setReloadButtonCreator(MLSReloadButtonCreator reloadButtonCreator) {
        AssertUtils.assertNullForce(reloadButtonCreator);
        MLSAdapterContainer.reloadButtonCreator = reloadButtonCreator;
    }

    public static PreinstallError getPreinstallError() {
        return preinstallError;
    }

    public static void setPreinstallError(PreinstallError preinstallError) {
        MLSAdapterContainer.preinstallError = preinstallError;
    }

    public static IFileCache getFileCache() {
        return fileCache;
    }

    public static void setFileCache(IFileCache fileCache) {
        MLSAdapterContainer.fileCache = fileCache;
    }

    public static MLNSafeAreaAdapter getSafeAreaAdapter() {
        return safeAreaAdapter;
    }

    public static void setSafeAreaAdapter(MLNSafeAreaAdapter safeAreaAdapter) {
        MLSAdapterContainer.safeAreaAdapter = safeAreaAdapter;
    }

    public static X64PathAdapter getX64PathAdapter() {
        return x64PathAdapter;
    }

    public static void setX64PathAdapter(X64PathAdapter x64PathAdapter) {
        MLSAdapterContainer.x64PathAdapter = x64PathAdapter;
    }
}