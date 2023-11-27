package com.immomo.mls.wrapper

import com.immomo.mls.adapter.dependence.DepInfo
import com.immomo.mls.util.LLog
import org.luaj.vm2.utils.ResourceFinder

class DepResourceFinder(private val dependenceInfo: DepInfo?) : ResourceFinder {
    var errorMsg: String = ""

    override fun preCompress(name: String?): String {
        var nameFinal = name ?: ""
        if (nameFinal.endsWith(".lua")) {
            nameFinal = nameFinal.replace(".lua", "").trim()
        }
        return nameFinal
    }

    override fun findPath(name: String?): String? {
        errorMsg = ""
        if (dependenceInfo == null) {
            return null
        }
        val depWidget = dependenceInfo.widgetPathMap[name]
        if (depWidget == null) {
            errorMsg = "DepResourceFinder $name 查找失败：${dependenceInfo.allGroups}"
            return null
        }
        val filePath = depWidget.filePath
        if (filePath.isNullOrBlank()) {
            errorMsg =
                "DepResourceFinder $name 查找失败：filePath为空:$depWidget，请检查DependenceFetcher中的逻辑是否有误"
            return null
        }
        return filePath
    }

    override fun getContent(name: String?): ByteArray? = null

    override fun afterContentUse(name: String?) {
        //do nothing
    }

    override fun getError(): String {
        return errorMsg
    }
}