package com.immomo.mls.lite.interceptor

import com.immomo.mls.DebugPrintStream
import com.immomo.mls.LuaViewManager
import com.immomo.mls.MLSEngine
import com.immomo.mls.`fun`.globals.LuaView
import com.immomo.mls.lite.RealInterceptorChain
import com.immomo.mls.lite.data.ScriptResult
import com.immomo.mls.lite.interceptor.Interceptor

class HotReloadPrinterInterceptor : Interceptor {
    override fun intercept(chain: Interceptor.Chain): ScriptResult {
        val realChain = chain as RealInterceptorChain
        val exchange = realChain.exchange()
        if (MLSEngine.DEBUG) {
            val luaViewManager = exchange?.globals?.javaUserdata as? LuaViewManager
            luaViewManager?.STDOUT = DebugPrintStream(null)
        }
        return chain.proceed(chain.request())
    }
}