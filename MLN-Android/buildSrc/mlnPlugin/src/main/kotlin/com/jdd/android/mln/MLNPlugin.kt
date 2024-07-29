package com.jdd.android.mln

import com.android.build.gradle.AppExtension
import org.gradle.api.Plugin
import org.gradle.api.Project

open class MLNPluginConfig {
    var includeModules: Array<String>? = null

    override fun toString(): String {
        return includeModules?.joinToString(",") ?: ""
    }
}

/**
 * A MLN Plugin
 */
class MLNPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        // Register a task
        project.extensions.create("mlnPluginConfig", MLNPluginConfig::class.java)

        val android = project.extensions.findByType(AppExtension::class.java)
        android?.findApp()
        android?.registerTransform(MLNPluginTransform(project))
    }
}
