package com.jdd.android.mln

import org.objectweb.asm.*

internal typealias OnScanFinish = (
    className: String,
    moduleConfig: ModuleConfig?
) -> Unit

internal class MLNClassScanVisitor(
    private val classReader: ClassReader,
    private val onVisitEnd: OnScanFinish
) : ClassVisitor(Opcodes.ASM6) {
    private var moduleConfig: ModuleConfig? = null

    override fun visitAnnotation(desc: String, visible: Boolean): AnnotationVisitor? =
        when (desc) {

            MODULE_CONFIG_TYPE_NAME -> {
                ModuleConfigAnnotationVisitor(classReader) {
                    moduleConfig = it
                }
            }

            else -> null
        }

    override fun visitEnd() {
        onVisitEnd(classReader.className, moduleConfig)
    }

    companion object {
        var APP_ASM_CONTEXT_CLASS_NAME = ""

        const val MODULE_CONFIG_TYPE_NAME = "Lcom/immomo/mls/annotation/MLNRegister;"
    }
}