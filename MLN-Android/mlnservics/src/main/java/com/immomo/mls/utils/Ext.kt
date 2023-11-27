package com.example.android.utils

import android.content.Context
import android.os.Looper
import android.view.View
import androidx.fragment.app.Fragment
import androidx.lifecycle.LifecycleOwner
import com.immomo.mls.Constants
import com.immomo.mls.utils.ScriptBundleParseUtils
import com.immomo.mls.wrapper.ScriptBundle
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext


fun String?.isAssets() = !this.isNullOrEmpty() && this.contains(Constants.ASSETS_PREFIX)
fun parseToBundleExt(oldUrl: String, localPath: String): ScriptBundle {
    return ScriptBundleParseUtils.getInstance().parseToBundle(oldUrl, localPath)
}

fun ScriptBundle.context(mContext: Context?) = apply { context = mContext }

fun LifecycleOwner.toContext() = when (this) {
    is Fragment -> this.activity
    is View -> this.context
    else -> this as? Context
}

internal inline fun <T> T.runInMain(crossinline block: () -> T) {
    if (Looper.myLooper() == Looper.getMainLooper()) {
        block()
    } else runBlocking {
        withContext(Dispatchers.Main) {
            block()
        }
    }
}