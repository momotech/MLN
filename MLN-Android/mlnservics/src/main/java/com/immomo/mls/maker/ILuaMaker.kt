package com.immomo.mls.maker

import com.immomo.mls.adapter.ScriptReader
import com.immomo.mls.lite.LuaClient
import com.immomo.mls.lite.data.ScriptResult
import com.immomo.mls.utils.loader.Callback
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.FlowCollector

interface ILuaMaker : Callback, CoroutineScope {
    //异步时需要 同步时 可以通过拦截器直接操作
    val scriptReader: ScriptReader?
    val luaClient: LuaClient
    fun build()
    suspend fun collect(collector: FlowCollector<Result<ScriptResult>>)
}
