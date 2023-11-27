package com.immomo.mls.lite.interceptor

import com.immomo.mls.lite.RealInterceptorChain
import com.immomo.mls.lite.data.ScriptResult
import com.immomo.mls.utils.ScriptLoadException
import java.net.ProtocolException
import java.util.*

/**
 * lua 脚本执行异常 降级策略拦截器
 */
class ScriptLoadExceptionInterceptor(val MAX_RETRY_TIMES: Int) : Interceptor {

    @Throws(Exception::class)
    override fun intercept(chain: Interceptor.Chain): ScriptResult {
        val realChain = chain as RealInterceptorChain
        var request = chain.request()
        var retryCount = 0
        val otherError: MutableList<StackTraceElement?> = ArrayList()
        val errorMsg: MutableList<String?> = ArrayList()
        while (true) {
            try {
                return chain.proceed(request)
            } catch (e: ScriptLoadException) {
                realChain.transmitter().recycle() //回收上次的global
                realChain.transmitter().scriptLoadFailed(chain.call(), e)
                Collections.addAll(otherError, *Arrays.copyOfRange(e.stackTrace, 0, 6))
                errorMsg.add(e.message)
                request = request.newBuilder()
                    .forceLoadAssetResource(true)
                    .build()
                if (++retryCount >= MAX_RETRY_TIMES) {
                    //处理关联信息
                    val host =
                        StringBuilder("${e.message} \nToo many script-load requests {2} each error take 6 lines of stack trace\n")
                    errorMsg.forEachIndexed { index, s ->
                        host.append(index + 1).append(":").append(s).append("\n")
                    }
                    val protocolException = ProtocolException(host.toString())
                    protocolException.stackTrace = otherError.filterNotNull().toTypedArray()
                    otherError.clear()
                    errorMsg.clear()
                    throw protocolException
                }
            }
        }
    }

    companion object {
        private const val TAG = "ScriptLoadExceptionInterceptor"
    }

}