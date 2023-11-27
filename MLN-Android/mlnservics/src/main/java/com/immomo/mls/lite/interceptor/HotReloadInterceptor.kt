package com.immomo.mls.lite.interceptor

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.example.android.utils.context
import com.example.android.utils.parseToBundleExt
import com.example.android.utils.runInMain
import com.immomo.mls.HotReloadHelper
import com.immomo.mls.MLSAdapterContainer
import com.immomo.mls.MLSEngine
import com.immomo.mls.adapter.dependence.DependenceFetcher
import com.immomo.mls.lite.data.ScriptResult
import com.immomo.mls.maker.BundleResult
import com.immomo.mls.wrapper.ScriptBundle
import kotlinx.coroutines.ExperimentalCoroutinesApi

@OptIn(ExperimentalCoroutinesApi::class)
class HotReloadInterceptor(
    var lifecycleOwner: LifecycleOwner?,
    val execute: (BundleResult) -> Unit,
    private val dependenceFetcher: DependenceFetcher? = null
) :
    Interceptor,
    HotReloadHelper.Callback, LifecycleEventObserver {
    private val mContext: Context?
        get() = when (lifecycleOwner) {
            is Fragment -> (lifecycleOwner as Fragment).activity
            else -> lifecycleOwner as? Context
        }

    init {
        lifecycleOwner?.lifecycle?.addObserver(this)
        HotReloadHelper.addCallback(this)
    }

    override fun intercept(chain: Interceptor.Chain): ScriptResult {
        return chain.proceed(chain.request())
    }

    private val emptyScriptBundle = mContext?.let {
        ScriptBundle("", "").context(it)
    }

    override fun onUpdateFiles(f: String?) = Unit

    override fun onReload(path: String, params: HashMap<String, String>?, state: Int) {
        lifecycleOwner?.let { owner ->
            runInMain {
                //热更新参数
                if (owner.lifecycle.currentState != Lifecycle.State.RESUMED)
                    return@runInMain
                MLSAdapterContainer.getToastAdapter().toast("MLNHotReload触发更新")
                if (params != null && params.containsKey("hotReload_SerialNum")) {
                    HotReloadHelper.setSerial(params["hotReload_SerialNum"].toString())
                }
                kotlin.runCatching {
                    val request = parseToBundleExt(path, path)
                        .apply {
                            dependenceFetcher?.fetchDependence(this)
                            append(hashMapOf("LuaHotReloadPath" to path))
                        }
                        .context(mContext)
                    execute(BundleResult.Success(request))
                }.onFailure { e ->
                    if (MLSEngine.DEBUG) {
                        execute(BundleResult.Error(Exception(e)))
                    }
                    MLSAdapterContainer.getConsoleLoggerAdapter().e("HotReload", e.message)
                }
            }
        }
    }

    override fun reloadFinish(): Boolean = true

    override fun onDisconnected(type: Int, error: String?) =
        MLSAdapterContainer.getToastAdapter().toast("MLNHotReload断开连接")

    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) = when (event) {
        Lifecycle.Event.ON_DESTROY -> {
            HotReloadHelper.removeCallback(this)
        }
        else -> {}
    }

}

public infix fun ScriptBundle.append(param: HashMap<Any, Any>) {
    if (this.params == null) {
        this.params = param
    } else {
        this.params.putAll(param)
    }
}