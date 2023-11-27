package com.immomo.mls.processor

import com.google.auto.common.MoreElements
import com.immomo.mls.annotation.CreatedByApt
import com.immomo.mls.annotation.LuaClass
import com.immomo.mls.annotation.MLN
import com.immomo.mls.annotation.MLNRegister
import com.immomo.mls.processor.LuaClassGenerator.LuaApiUsed
import com.squareup.javapoet.*
import kotlin.reflect.KClass
import javax.annotation.processing.ProcessingEnvironment
import javax.lang.model.element.Element
import javax.lang.model.element.Modifier
import javax.lang.model.element.TypeElement
import javax.lang.model.type.MirroredTypeException


class LuaRegisterGenerator(builder: Builder) {
    companion object {
        const val packageName = "com.immomo.mln.bridge"
    }

    private val normalUserDataClass = ClassName.get("com.immomo.mls.wrapper", "Register.UDHolder")
    private val staticUserDataClass = ClassName.get("com.immomo.mls.wrapper", "Register.SHolder")
    private val singletonUserDataClass =
        ClassName.get("com.immomo.mls", "MLSBuilder.SIHolder")
    private val convertUserDataClass = ClassName.get("com.immomo.mls", "MLSBuilder.CHolder")
    private val enumUserDataClass = ClassName.get("java.lang", "Class")
    private val registerClass = ClassName.get("com.immomo.mls.wrapper", "Register")
    private val mlsBuilderClass = ClassName.get("com.immomo.mls", "MLSBuilder")
    private val normalUDCodeBlock = CodeBlock.builder()
    private val staticUDCodeBlock = CodeBlock.builder()
    private val singletonUDCodeBlock = CodeBlock.builder()
    private val enumUDCodeBlock = CodeBlock.builder()
    private val convertUDCodeBlock = CodeBlock.builder()
    private val normalUserData: MethodSpec.Builder
    private val staticUserData: MethodSpec.Builder
    private val singletonUserData: MethodSpec.Builder
    private val enumUserData: MethodSpec.Builder
    private val convertUserData: MethodSpec.Builder

    init {

        normalUDCodeBlock.indent().beginControlFlow("return new \$T[]", normalUserDataClass)
        staticUDCodeBlock.indent().beginControlFlow("return new \$T[]", staticUserDataClass)
        singletonUDCodeBlock.indent().beginControlFlow("return new \$T[]", singletonUserDataClass)
        enumUDCodeBlock.indent().beginControlFlow("return new \$T[]", enumUserDataClass)
        convertUDCodeBlock.indent().beginControlFlow("return new \$T[]", convertUserDataClass)

        normalUserData = MethodSpec.methodBuilder("registerUD")
            .addModifiers(Modifier.PUBLIC, Modifier.STATIC)
            .returns(ArrayTypeName.of(normalUserDataClass))
        staticUserData = MethodSpec.methodBuilder("registerLT")
            .addModifiers(Modifier.PUBLIC, Modifier.STATIC)
            .returns(ArrayTypeName.of(staticUserDataClass))
        singletonUserData = MethodSpec.methodBuilder("registerSingleInstance")
            .addModifiers(Modifier.PUBLIC, Modifier.STATIC)
            .returns(ArrayTypeName.of(singletonUserDataClass))
        enumUserData = MethodSpec.methodBuilder("registerLuaConstants")
            .addModifiers(Modifier.PUBLIC, Modifier.STATIC)
            .returns(ArrayTypeName.of(enumUserDataClass))
        convertUserData = MethodSpec.methodBuilder("registerCovert")
            .addModifiers(Modifier.PUBLIC, Modifier.STATIC)
            .returns(ArrayTypeName.of(convertUserDataClass))
    }

    private val className: String = builder.className
    fun addStatement(env: ProcessingEnvironment, type: TypeElement) {
        if (type.getAnnotation(CreatedByApt::class.java) != null)
            return

        val annotation = type.getAnnotation(MLN::class.java)
        when (annotation.type) {
            MLN.Type.Normal -> {
                addNormal(type, env)
            }
            MLN.Type.Static -> {
                val classFullName = env.elementUtils.getBinaryName(type).toString()
                staticUDCodeBlock.add(
                    "Register.newSHolderWithLuaClass(\$L.LUA_CLASS_NAME,\$L.class),\n",
                    classFullName,
                    classFullName
                )
            }
            MLN.Type.Singleton -> {
                val classFullName = env.elementUtils.getBinaryName(type).toString()
                singletonUDCodeBlock.add(
                    "new MLSBuilder.SIHolder(\$L.LUA_CLASS_NAME,\$L.class),\n",
                    classFullName,
                    classFullName
                )
            }
            MLN.Type.Const -> {
                val classFullName = env.elementUtils.getBinaryName(type).toString()
                enumUDCodeBlock.add(
                    "\$L.class,\n",
                    classFullName
                )
            }
            else -> {}

        }
        try {
            annotation.convertClass
        } catch (e: MirroredTypeException) {
            if (e.typeMirror.toString() != "java.lang.Object") {
                val classFullName = env.elementUtils.getBinaryName(type).toString()
                convertUDCodeBlock.add(
                    "new MLSBuilder.CHolder(\$L.class, \$L.J, \$L.G),",
                    e.typeMirror.toString(),
                    classFullName,
                    classFullName
                )
            }
        }

    }

    private fun addNormal(
        type: TypeElement,
        env: ProcessingEnvironment
    ) {
        if (type.getAnnotation(LuaClass::class.java) != null) {
            val classFullName = env.elementUtils.getBinaryName(type).toString()
            normalUDCodeBlock.add(
                "Register.newUDHolderWithLuaClass(\$L.LUA_CLASS_NAME,\$L.class,false),\n",
                classFullName,
                classFullName
            )
        } else {
            val classFullName = env.elementUtils.getBinaryName(type).toString()
            normalUDCodeBlock.add(
                "Register.newUDHolder(\$L.LUA_CLASS_NAME,\$L.class,true,\$L.methods),\n",
                classFullName,
                classFullName,
                classFullName
            )
        }
    }

    fun build(): JavaFile {
        val forImport = FieldSpec.builder(registerClass, "mRegister").build()
        val forImport2 = FieldSpec.builder(mlsBuilderClass, "mRegister2").build()
        normalUDCodeBlock.endControlFlow("").unindent()
        staticUDCodeBlock.endControlFlow("").unindent()
        singletonUDCodeBlock.endControlFlow("").unindent()
        enumUDCodeBlock.endControlFlow("").unindent()
        convertUDCodeBlock.endControlFlow("").unindent()

        val aptUserDataHolder = TypeSpec.classBuilder(className)
            .addAnnotation(CreatedByApt::class.java)
            .addAnnotation(LuaApiUsed)
            .addAnnotation(MLNRegister::class.java)
            .addModifiers(
                Modifier.PUBLIC,
                Modifier.FINAL
            )
            .addField(forImport)
            .addField(forImport2)
            .addMethod(normalUserData.addCode(normalUDCodeBlock.build()).build())
            .addMethod(staticUserData.addCode(staticUDCodeBlock.build()).build())
            .addMethod(singletonUserData.addCode(singletonUDCodeBlock.build()).build())
            .addMethod(enumUserData.addCode(enumUDCodeBlock.build()).build())
            .addMethod(convertUserData.addCode(convertUDCodeBlock.build()).build())
            .build()


        return JavaFile.builder(packageName, aptUserDataHolder)
            .build()
    }

    class Builder(var logger: Logger, var type: TypeElement, lc: MLN?) {
        val className: String

        init {
            val str = MoreElements.getPackage(type).qualifiedName.toString()
            className = str.replace(".", "$$") + "\$\$Register"
        }

        fun build() = LuaRegisterGenerator(this)
    }
}