package com.jdd.android.mln

import org.objectweb.asm.ClassVisitor
import org.objectweb.asm.MethodVisitor
import org.objectweb.asm.Opcodes


private fun MethodVisitor.addModuleConfig(moduleConfig: ModuleConfig) {


    visitVarInsn(Opcodes.ALOAD, 0)
    visitInsn(Opcodes.ICONST_1)
    visitMethodInsn(
        Opcodes.INVOKESTATIC,
        "com/immomo/mls/utils/ProcessUtils",
        "isRunningInMainProcess",
        "(Landroid/content/Context;Z)Z",
        false
    )
    visitVarInsn(Opcodes.ALOAD, 0)
    visitInsn(Opcodes.ICONST_0)
    visitMethodInsn(
        Opcodes.INVOKESTATIC,
        "com/immomo/mls/MLSEngine",
        "init",
        "(Landroid/content/Context;Z)Lcom/immomo/mls/MLSBuilder;",
        false
    )
    val className = moduleConfig.className.replace(".", "/")

    visitMethodInsn(
        Opcodes.INVOKESTATIC,
        className,
        "registerUD",
        "()[Lcom/immomo/mls/wrapper/Register\$UDHolder;",
        false
    )
    visitMethodInsn(
        Opcodes.INVOKEVIRTUAL,
        "com/immomo/mls/MLSBuilder",
        "registerUD",
        "([Lcom/immomo/mls/wrapper/Register\$UDHolder;)Lcom/immomo/mls/MLSBuilder;",
        false
    )

    visitMethodInsn(
        Opcodes.INVOKESTATIC,
        className,
        "registerSingleInstance",
        "()[Lcom/immomo/mls/MLSBuilder\$SIHolder;",
        false
    )
    visitMethodInsn(
        Opcodes.INVOKEVIRTUAL,
        "com/immomo/mls/MLSBuilder",
        "registerSingleInsance",
        "([Lcom/immomo/mls/MLSBuilder\$SIHolder;)Lcom/immomo/mls/MLSBuilder;",
        false
    )

    visitMethodInsn(
        Opcodes.INVOKESTATIC,
        className,
        "registerLT",
        "()[Lcom/immomo/mls/wrapper/Register\$SHolder;",
        false
    )
    visitMethodInsn(
        Opcodes.INVOKEVIRTUAL,
        "com/immomo/mls/MLSBuilder",
        "registerSC",
        "([Lcom/immomo/mls/wrapper/Register\$SHolder;)Lcom/immomo/mls/MLSBuilder;",
        false
    )

    visitMethodInsn(
        Opcodes.INVOKESTATIC,
        className,
        "registerLuaConstants",
        "()[Ljava/lang/Class;",
        false
    )
    visitMethodInsn(
        Opcodes.INVOKEVIRTUAL,
        "com/immomo/mls/MLSBuilder",
        "registerConstants",
        "([Ljava/lang/Class;)Lcom/immomo/mls/MLSBuilder;",
        false
    )

    visitMethodInsn(
        Opcodes.INVOKESTATIC,
        className,
        "registerCovert",
        "()[Lcom/immomo/mls/MLSBuilder\$CHolder;",
        false
    )
    visitMethodInsn(
        Opcodes.INVOKEVIRTUAL,
        "com/immomo/mls/MLSBuilder",
        "registerCovert",
        "([Lcom/immomo/mls/MLSBuilder\$CHolder;)Lcom/immomo/mls/MLSBuilder;",
        false
    )

}


internal class MLNClassInjectVisitor(
    classVisitor: ClassVisitor,
    val moduleConfigList: List<ModuleConfig>
) : ClassVisitor(Opcodes.ASM6, classVisitor) {

    override fun visitSource(source: String?, debug: String?) {
        super.visitSource(source, debug)
        visitInnerClass(
            "com/immomo/mls/wrapper/Register\$UDHolder",
            "com/immomo/mls/wrapper/Register",
            "UDHolder",
            Opcodes.ACC_PUBLIC or Opcodes.ACC_FINAL or Opcodes.ACC_STATIC
        )

        visitInnerClass(
            "com/immomo/mls/MLSBuilder\$SIHolder",
            "com/immomo/mls/MLSBuilder",
            "SIHolder",
            Opcodes.ACC_PUBLIC or Opcodes.ACC_STATIC
        )

        visitInnerClass(
            "com/immomo/mls/wrapper/Register\$SHolder",
            "com/immomo/mls/wrapper/Register",
            "SHolder",
            Opcodes.ACC_PUBLIC or Opcodes.ACC_FINAL or Opcodes.ACC_STATIC
        )

        visitInnerClass(
            "com/immomo/mls/MLSBuilder\$CHolder",
            "com/immomo/mls/MLSBuilder",
            "CHolder",
            Opcodes.ACC_PUBLIC or Opcodes.ACC_STATIC
        )
    }

    override fun visitMethod(
        access: Int,
        name: String,
        desc: String,
        signature: String?,
        exceptions: Array<String>?
    ): MethodVisitor? = super.visitMethod(access, name, desc, signature, exceptions).let { mv ->
        return if (name == "onCreate" && desc == "()V") {
            object : MethodVisitor(Opcodes.ASM6, mv) {
                override fun visitInsn(opcode: Int) = when (opcode) {
                    Opcodes.RETURN -> {
                        moduleConfigList.forEach { mv.addModuleConfig(it) }
                    }
                    else -> Unit
                }.also { super.visitInsn(opcode) }
            }
        } else {
            mv
        }
    }
}