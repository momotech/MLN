package com.jdd.android.mln

import org.objectweb.asm.AnnotationVisitor
import org.objectweb.asm.ClassReader
import org.objectweb.asm.Opcodes

internal class ModuleConfig(
    val className: String// like com/immomo/mln/bridge/com$$immomo$$demo$$Register
)

internal class ModuleConfigAnnotationVisitor(
    private val classReader: ClassReader,
    val onVisitEnd: (ModuleConfig) -> Unit
) : AnnotationVisitor(Opcodes.ASM6) {

    override fun visitEnd() {
        onVisitEnd(ModuleConfig(classReader.className))
    }
}