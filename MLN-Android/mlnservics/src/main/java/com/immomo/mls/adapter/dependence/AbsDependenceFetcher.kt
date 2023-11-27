package com.immomo.mls.adapter.dependence

import com.immomo.mls.util.LLog
import com.immomo.mls.wrapper.ScriptBundle
import org.json.JSONObject
import org.luaj.vm2.Globals
import java.io.File

abstract class AbsDependenceFetcher : DependenceFetcher {
    companion object {
        const val NAME_DEPENDENCE_CONFIG = "dependenceConfig.json"

        @Throws
        fun parseDepInfoFromBundle(sourceRootPath: String): DepInfo? {
            return File(sourceRootPath, NAME_DEPENDENCE_CONFIG).takeIf {
                it.exists() && it.isFile
            }?.let { configFile ->
                try {
                    val config = JSONObject(configFile.readText())
                    val allGroup = hashSetOf<DepGroup>()
                    val map = hashMapOf<String, DepWidget>()
                    config.optJSONArray("group")?.also { groups ->
                        repeat(groups.length()) { i ->
                            val group = groups.optJSONObject(i)
                            val depGroup = DepGroup(
                                name = group.optString("name"),
                                identifier = group.optString("identifier"),
                                version = group.optString("version")
                            )
                            allGroup.add(depGroup)
                            group.optJSONArray("widgets")?.also { widgets ->
                                repeat(widgets.length()) { j ->
                                    val widget = widgets.optJSONObject(j)
                                    DepWidget(
                                        name = widget.optString("name"),
                                        version = widget.optString("version"),
                                        size = widget.optJSONObject(
                                            "android" + (if (Globals.is32bit()) "32" else "64")
                                        )?.optLong("size", 0) ?: 0,
                                        group = depGroup,
                                        relativeDir = widget.optString("dir")
                                    ).also { map[it.name] = it }
                                }
                            }
                        }
                    }

                    DepInfo(allGroup, map)
                } catch (e: Exception) {
                    LLog.logError(e, "解析dependenceConfig.json失败 ", e.toString())
                    null
                }
            }
        }
    }

    open val retryCount = 1
    abstract override fun fetchLocalDependence(scriptBundle: ScriptBundle): Boolean

    @Throws
    override fun fetchDependence(scriptBundle: ScriptBundle) {
        val depInfo: DepInfo? = parseDepInfoFromBundle(scriptBundle.basePath)
        depInfo?.also {
            try {
                installDepInfo(it, scriptBundle)
            } catch (e: Exception) {
                LLog.logFatal(
                    LLog.TAG_DEPENDENCE,
                    e, "加载：${scriptBundle.url}的依赖${it}失败:$e"
                )
                throw e
            }
        }
    }

    private fun installDepInfo(
        it: DepInfo,
        scriptBundle: ScriptBundle
    ) {
        var count = 0
        while (true) {
            try {
                prepareAllGroup(it)
                findWidgetPath(it)
                scriptBundle.dependenceInfo = it
                break
            } catch (e: Exception) {
                count++
                if (count > retryCount) {
                    throw e
                }
            }
        }
    }

    /**
     *
     */
    @Throws
    abstract fun findWidgetPath(depInfo: DepInfo)

    @Throws
    abstract fun prepareAllGroup(depInfo: DepInfo)


}