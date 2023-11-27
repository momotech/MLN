package com.immomo.mls.lite.interceptor


import android.net.Uri
import com.immomo.mls.Constants
import com.immomo.mls.InitData
import com.immomo.mls.lite.data.ScriptResult
import com.immomo.mls.utils.UrlParams

class InitDataParamInterceptor(val data: InitData) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): ScriptResult {
        val extraData =
            chain.request().params ?: kotlin.run {
                chain.request().params = hashMapOf()
                chain.request().params
            }
        extraData.put("urlParams", UrlParams(chain.request().url))
        if (!data.extras.isNullOrEmpty()) {
            extraData.putAll(data.extras)
        }
        if (!extraData.containsKey(Constants.KEY_URL)) {
            extraData[Constants.KEY_URL] = chain.request().url
        }
        if (!extraData.containsKey(Constants.KEY_LUA_SOURCE)) {
            extraData[Constants.KEY_LUA_SOURCE] = chain.request().url
        }
        kotlin.runCatching {
            extraData.put("isInner", chain.request().url.toUri().host?.contains("test"))
        }
        return chain.proceed(chain.request())
    }

    fun String.toUri(): Uri = Uri.parse(this)

}
