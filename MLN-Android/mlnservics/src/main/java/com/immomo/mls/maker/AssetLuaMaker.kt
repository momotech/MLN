package com.immomo.mls.maker

import androidx.lifecycle.LifecycleOwner
import com.example.android.utils.toContext
import com.immomo.mls.InitData
import com.immomo.mls.adapter.ScriptReader
import com.immomo.mls.lite.LuaClient
import com.immomo.mls.lite.data.UserdataType
import com.immomo.mls.lite.interceptor.AssetsInterceptor
import com.immomo.mls.lite.interceptor.HotReloadInterceptor
import com.immomo.mls.lite.interceptor.HotReloadPrinterInterceptor
import com.immomo.mls.lite.interceptor.InitDataParamInterceptor
import com.immomo.mls.utils.ScriptLoadException
import com.immomo.mls.wrapper.ScriptBundle

class AssetLuaMaker(private val lifecycleOwner: LifecycleOwner, val data: InitData) :
    AbstractLuaMaker(lifecycleOwner) {
    override val scriptReader: ScriptReader? = null
    override val luaClient: LuaClient by lazy {
        LuaClient.newDefaultBuilder()
            .addPreProcessorInterceptor(InitDataParamInterceptor(data))
            .addResourceProcessorInterceptor(AssetsInterceptor())
            .addMiddlewareInterceptors(HotReloadInterceptor(lifecycleOwner, ::execute))
            .addCustomUserDataInjectInterceptor(HotReloadPrinterInterceptor())
            .userdataType(UserdataType.ONLY_FULL)
            .build(lifecycleOwner)
    }

    override fun build() {
        ScriptBundle.Builder(data.url, "")
            .context(lifecycleOwner.toContext())
            .forceLoadAssetResource(true)
            .build()
            .also {
                execute(BundleResult.Success(it))
            };
    }

    override fun onScriptLoadSuccess(scriptFile: ScriptBundle?) = Unit

    override fun onScriptLoadFailed(e: ScriptLoadException?) = Unit
}