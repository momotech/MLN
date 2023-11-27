package com.immomo.mls.adapter.dependence

import com.immomo.mls.wrapper.ScriptBundle

interface DependenceFetcher {
    /**
     * 检查本地依赖是否存在，使用简单校验，校验size
     * @return true 加载成功，false 加载失败
     */
    fun fetchLocalDependence(scriptBundle: ScriptBundle):Boolean

    /**
     * 加载给定的 scriptBundle 所包含的依赖信息
     * @param scriptBundle
     * @return 是否完成加载
     */
    @Throws
    fun fetchDependence(scriptBundle: ScriptBundle)
}

data class DepInfo(
    val allGroups: Set<DepGroup>,
    val widgetPathMap: Map<String, DepWidget>
)

data class DepGroup(
    val name: String,
    val identifier: String,
    val version: String,
    //需要在准备依赖过程中赋值
    var dirPath: String? = null
)

data class DepWidget(
    val name: String,
    val version: String,
    val group: DepGroup,
    val size: Long,
    val relativeDir: String?,
    //需要在查找过程中赋值
    var filePath: String? = null
) {
    //多文件构成依赖，记录主文件外,暂时不支持
    var children: Map<String, String>? = null
}