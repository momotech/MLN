package com.immomo.mls.util

object LLog {
    const val TAG_DEPENDENCE = "luadep"

    @JvmStatic
    fun log(obj: Any, vararg params: Any) {
        LogUtil.d("lc_dep_" + obj.javaClass.name, params.fold("") { acc, s ->
            "$acc $s"
        })
    }

    @JvmStatic
    fun logError(throwable: Throwable?, vararg params: Any) {
        val msg = params.fold("") { acc, s ->
            "$acc $s"
        }
        val tag = "lc_dep_"
        LogUtil.e(tag, throwable?.message, msg)
    }

    fun logFatal(tag: String, throwable: Throwable, msg: String) {
        LogUtil.e(throwable, "lc_dep_$tag  $msg")
    }

}