package com.immomo.mls.maker


import androidx.lifecycle.LifecycleOwner
import com.example.android.utils.context
import com.example.android.utils.toContext
import com.immomo.mls.lite.data.ScriptResult
import com.immomo.mls.wrapper.ScriptBundle
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.InternalCoroutinesApi
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.FlowCollector
import kotlinx.coroutines.flow.consumeAsFlow
import kotlinx.coroutines.launch
import kotlin.coroutines.CoroutineContext

abstract class AbstractLuaMaker(private val lifecycleOwner: LifecycleOwner) : ILuaMaker {
    override val coroutineContext: CoroutineContext = Dispatchers.Main
    private val resultFlow = Channel<Result<ScriptResult>>()
    val emptyScriptBundle =
        ScriptBundle("", "").context(lifecycleOwner.toContext())

    @OptIn(InternalCoroutinesApi::class)
    override suspend fun collect(collector: FlowCollector<Result<ScriptResult>>) {
        build()
        resultFlow.consumeAsFlow ().collect(collector)
    }

    fun execute(data: BundleResult) {
        launch {
            when (data) {
                is BundleResult.Success -> luaClient.newCall(data.result.context(lifecycleOwner.toContext()))
                    .execute()?.also {
                        resultFlow.send(Result.success(it))
                    } ?: error()
                is BundleResult.Error -> error(data.e)
            }
        }
    }

    private fun error(e: Exception? = null) = launch {
        //显示错误视图
        execute(BundleResult.Success(emptyScriptBundle))
        resultFlow.send(Result.failure(e ?: Exception("执行失败")))
    }
}


sealed class BundleResult {
    data class Error(val e: Exception?) : BundleResult()
    data class Success(val result: ScriptBundle) : BundleResult()
}