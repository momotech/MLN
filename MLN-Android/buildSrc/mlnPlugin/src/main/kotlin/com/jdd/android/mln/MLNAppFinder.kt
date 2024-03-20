package com.jdd.android.mln

import com.android.build.gradle.AppExtension
import groovy.util.XmlSlurper
import groovy.util.slurpersupport.Node
import groovy.util.slurpersupport.NodeChild

fun AppExtension.findApp() {
    this.sourceSets.asMap["main"]?.manifest?.srcFile?.let { it ->
        val parse = XmlSlurper().parse(it)
        val packageName = (parse.getAt(0) as Node).attributes()["package"].toString()

        (parse.children()
            .firstOrNull { node -> node is NodeChild && node.name() == "application" } as? NodeChild)?.let {
            val namespace = "http://schemas.android.com/apk/res/android"
            var appName = it.attributes()["{$namespace}name"].toString()
            if (appName.startsWith("."))
                appName = packageName + appName
            MLNClassScanVisitor.APP_ASM_CONTEXT_CLASS_NAME = appName.replace(".", "/")
        }
    }

}