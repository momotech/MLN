package com.immomo.momo.mua.generator

import com.google.devtools.ksp.*
import com.google.devtools.ksp.processing.*
import com.google.devtools.ksp.symbol.*
import com.squareup.kotlinpoet.*
import com.squareup.kotlinpoet.ParameterizedTypeName.Companion.parameterizedBy
import java.io.File
import java.io.OutputStream
import java.io.OutputStreamWriter
import java.nio.charset.StandardCharsets
import java.util.regex.Pattern
import javax.xml.stream.events.Comment
import kotlin.math.log

inline fun <reified T> Any?.castOrNull(): T? = this as? T

class MuaBuilderProcessorProvider : SymbolProcessorProvider {
    override fun create(
        environment: SymbolProcessorEnvironment
    ): SymbolProcessor {
        return MuaBuilderProcessor(environment.codeGenerator, environment.logger)
    }
}


class MuaBuilderProcessor(
    val codeGenerator: CodeGenerator,
    val logger: KSPLogger
) : SymbolProcessor {
    private val LUA_CLASS_NAME_PATTERN = Pattern.compile(".*LUA_CLASS_NAME = \"(.*)\";")
    private val LUA_CLASS_NAME_ARRAY_PATTERN = Pattern.compile(".*LUA_CLASS_NAME = \\{\"(.*)\"};")
    private val packageName = "mlnkit"
    override fun process(resolver: Resolver): List<KSAnnotated> {
        resolver.getSymbolsWithAnnotation("org.luaj.vm2.utils.LuaApiUsed")
            .filter { it is KSClassDeclaration }.also {
                it.forEach {
                    checkIgnoreTypeArgClass(it)
                }
                it.forEach {
                    it.accept(LuaApiUsedBuilderVisitor(resolver), Unit)
                }
            }

        resolver.getSymbolsWithAnnotation("com.immomo.mls.annotation.LuaClass")
            .filter { it is KSClassDeclaration }
            .forEach {
                it.accept(LuaClassBuilderVisitor(resolver), Unit)
            }
        resolver.getSymbolsWithAnnotation("com.immomo.mls.wrapper.ConstantClass")
            .filter { it is KSClassDeclaration }
            .forEach {
                it.accept(LuaConstantClassBuilderVisitor(resolver), Unit)
            }
        return emptyList()
    }

    private fun checkIgnoreTypeArgClass(classDeclaration: KSAnnotated) {
        if (classDeclaration !is KSClassDeclaration) {
            return
        }

        val apiInfo = classDeclaration.annotations.first {
            it.shortName.asString() == "LuaApiUsed"
        }.arguments.associate { it.name?.asString() to it.value }

        val classNames = classDeclaration.realClassName()

        val ignoreTypeArgs = apiInfo["ignoreTypeArgs"].castOrNull<Boolean>() ?: false
        if (ignoreTypeArgs) {
            classNames.forEach {
                ignoreTypeArgsClasses.add(packageName + "." + it)
            }
        }
    }

    class TypeInfo(
        val name: String? = null,
        val type: String,
        val typeArgs: List<TypeInfo>? = null,
        val isNullable: Boolean = false,
    ) {
        override fun toString(): String {
            return "TypeInfo(name=$name, type=$type,typeArgs=${typeArgs.toString()}, isNullable=$isNullable)"
        }
    }

    class FunctionInfo(
        val name: String,
        val parameters: List<TypeInfo>,
        val returnType: TypeInfo,
        val comment: String = "",
        val isConstructor: Boolean = false
    ) {
        override fun toString(): String {
            return "FunctionInfo(name='$name', parameters=${parameters.toString()}, returnType=${returnType.toString()}, comment = ${comment})"
        }
    }

    fun KSDeclaration.realQualifiedName(classTypeArgs: List<String>): String {
        val qualifiedName = this.qualifiedName?.asString()

        if (qualifiedName?.split('.')?.first() == "kotlin") {
            return qualifiedName
        }

        val simpleName = this.simpleName.asString()
        if (classTypeArgs.contains(simpleName)) {
            return simpleName
        }

        return realQualifiedName(this.simpleName, realClassName().first(), classTypeArgs)
    }

    fun realQualifiedName(simpleName: KSName? = null, className: String, classTypeArgs: List<String>? = null): String {
        val name = simpleName?.asString()
        if (name != null && classTypeArgs?.contains(name) == true) {
            return name
        }
        return "mlnkit.$className"
    }

    fun getClassNameSuffix(): String {
        return "__class_name"
    }

    fun KSDeclaration.realClassName(): List<String> {
        fun buildClassName(className: String): String {
            var name = className.removePrefix("_").removePrefix("_").removeSuffix("_udwrapper").classNameSuffix()
            return name
        }

        if (this !is KSClassDeclaration) return listOf("")
        val apiInfo = annotations.firstOrNull {
            it.shortName.asString() == "LuaApiUsed"
        }?.arguments?.associate { it.name?.asString() to it.value }
        var className = apiInfo?.get("name")?.castOrNull<String>()
        if (!className.isNullOrBlank()) return listOf(buildClassName(className))

        val luaClass = annotations.firstOrNull {
            it.shortName.asString() == "LuaClass"
        }?.arguments?.associate { it.name?.asString() to it.value }
        className = luaClass?.get("name")?.castOrNull<String>()
        if (!className.isNullOrBlank()) return listOf(buildClassName(className))

        val constantClass = annotations.firstOrNull {
            it.shortName.asString() == "ConstantClass"
        }?.arguments?.associate { it.name?.asString() to it.value }
        val alias = constantClass?.get("alias")?.castOrNull<String>()
        if (!alias.isNullOrBlank()) return listOf(buildClassName(alias))
        val originFile = File(containingFile?.filePath ?: "")
        //match file content
        if (originFile.exists()) {
            className = originFile.readLines().firstNotNullOfOrNull { line ->
                LUA_CLASS_NAME_PATTERN.matcher(line).takeIf { it.matches() }?.group(1)
            }
            if (className == null) {
                var classNames = originFile.readLines().firstNotNullOfOrNull { line ->
                    LUA_CLASS_NAME_ARRAY_PATTERN.matcher(line).takeIf { it.matches() }?.group(1)
                }?.replace("\\s".toRegex(), "")?.split(",") ?: listOf()
                classNames = classNames.map {
                    var name =
                        it.removePrefix("\"").removeSuffix("\"").removePrefix("_").removePrefix("_").classNameSuffix()
                    name
                }
                if (classNames.isNotEmpty()) return classNames
            }
        }
        if (!className.isNullOrBlank()) return listOf(buildClassName(className))

        return listOf(buildClassName(simpleName.asString()))
    }

    fun KSClassDeclaration.isSingleton(): Boolean {
        val luaClassInfo =
            annotations.firstOrNull { it.shortName.asString() == "LuaClass" }?.arguments?.associate { it.name?.asString() to it.value }
        return luaClassInfo?.get("isSingleton")?.castOrNull<Boolean>() ?: false
    }

    val ignoreTypeArgsClasses = mutableSetOf("mlnkit.List", "mlnkit.Map")
    val String.asMuaType: String
        get() {
            return when (this) {
                "kotlin.Int" -> "mua.Int"
                "kotlin.Long" -> "mua.Int"
                "kotlin.Float" -> "mua.Number"
                "kotlin.Double" -> "mua.Number"
                "kotlin.Number" -> "mua.Number"
                "kotlin.Boolean" -> "mua.Boolean"
                "kotlin.String" -> "mua.String"
                "kotlin.Any" -> "mua.Any"
                "kotlin.Unit" -> "mua.Unit"
                "kotlin.Function0" -> "mua.Function0"
                "kotlin.Function1" -> "mua.Function1"
                "kotlin.Function2" -> "mua.Function2"
                "kotlin.Function3" -> "mua.Function3"
                "kotlin.Function4" -> "mua.Function4"
                "kotlin.Function5" -> "mua.Function5"
                "kotlin.Function6" -> "mua.Function6"
                "kotlin.collections.MutableList" -> "mlnkit.List"
                "kotlin.collections.List" -> "mlnkit.List"
                "kotlin.Array" -> "mlnkit.List"
                "kotlin.collections.MutableMap" -> "mlnkit.Map"
                "kotlin.collections.Map" -> "mlnkit.Map"
                "mlnkit.LuaValue".classNameSuffix() -> "mua.Bridged"
                else -> this
            }
        }

    fun String.classNameSuffix(): String {
        return this + getClassNameSuffix()
    }

    fun String.removeClassNameSuffix(): String {
        return replace(getClassNameSuffix(), "")
    }

    @OptIn(KspExperimental::class)
    fun KSDeclaration.muaType(classTypeArgs: List<String>, resolver: Resolver): String {
        var type: String? = null
        if (qualifiedName != null) {
            type = resolver.mapJavaNameToKotlin(qualifiedName!!)?.asString()
        }
        return (type ?: realQualifiedName(classTypeArgs)).asMuaType
    }

    fun KSAnnotation.buildTypeInfo(
        classTypeArgs: List<String>,
        resolver: Resolver
    ): TypeInfo {
        val argMap = arguments.associate { it.name?.asString() to it.value }
        val name = argMap["name"].toString()
        var type = argMap["value"].castOrNull<KSType>()?.declaration?.muaType(classTypeArgs, resolver)
            ?: resolver.builtIns.anyType.declaration.qualifiedName!!.asString()
        var typeArgsNullable = argMap["typeArgsNullable"].castOrNull<List<Boolean>>() ?: listOf()
        var typeArgs: List<TypeInfo>? = argMap["typeArgs"].castOrNull<List<KSType>>()?.mapIndexed { index: Int, ksType: KSType ->
            TypeInfo(type = ksType.declaration.muaType(classTypeArgs, resolver), isNullable = typeArgsNullable.getOrElse(index) { false })
        }
        val isNullable = argMap["nullable"].toString().toBoolean()
        return TypeInfo(name, type, typeArgs, isNullable)
    }

    fun KSAnnotation.buildFuncInfo(
        defaultFuncName: String,
        classTypeArgs: List<String>,
        isConstructor: Boolean,
        resolver: Resolver
    ): FunctionInfo {
        val argMap = arguments.associate { it.name?.asString() to it.value }
        val funcName = argMap["name"].toString().takeIf { it.isNotBlank() } ?: defaultFuncName
        val parameters =
            argMap["params"].castOrNull<List<KSAnnotation>>()?.map { it.buildTypeInfo(classTypeArgs, resolver) }
        val returnType =
            argMap["returns"].castOrNull<KSAnnotation>()?.buildTypeInfo(classTypeArgs, resolver)
        val comment = argMap["comment"].castOrNull<String>() ?: ""
        return FunctionInfo(
            funcName,
            parameters ?: emptyList(),
            returnType ?: TypeInfo(type = resolver.builtIns.unitType.declaration.qualifiedName!!.asString().asMuaType),
            comment = comment,
            isConstructor = isConstructor,
        )
    }

    private fun KSTypeReference.buildTypeInfo(
        name: String?,
        nullable: Boolean,
        classTypeArgs: List<String>,
        resolver: Resolver,
        isConstructor: Boolean,
        ignoreTypeArgs: Boolean = false
    ): TypeInfo {
        val ksType = this.resolve()
        val name = name ?: ksType.declaration.simpleName.getShortName().asMuaType
        val type = ksType.declaration.muaType(classTypeArgs, resolver)
        val typeArgs = if (ignoreTypeArgs) {
            null
        } else if (!ignoreTypeArgsClasses.contains(type)) {
            buildTypeArgTypeInfo(ksType.arguments, classTypeArgs, resolver, isConstructor)
        } else {
            null
        }
        return TypeInfo(name, type, typeArgs, nullable && ksType.nullability != Nullability.NOT_NULL)
    }

    private fun buildTypeArgTypeInfo(
        arguments: List<KSTypeArgument>,
        classTypeArgs: List<String>,
        resolver: Resolver,
        isConstructor: Boolean,
        oneLevelTypeArgs: Boolean = false
    ): List<TypeInfo> {
        return arguments.map {
            val type = it.type?.resolve()
            if (type?.arguments?.isNotEmpty() == true && !isConstructor) {
                TypeInfo(
                    type = type.declaration.muaType(classTypeArgs, resolver),
                    typeArgs = if (!oneLevelTypeArgs) null else buildTypeArgTypeInfo(
                        type.arguments,
                        classTypeArgs,
                        resolver,
                        false
                    )
                )
            } else {
                TypeInfo(type = type?.declaration?.muaType(classTypeArgs, resolver) ?: "")
            }
        }
    }

    fun KSFunctionDeclaration.buildFuncInfo(
        defaultFuncName: String,
        classTypeArgs: List<String>,
        resolver: Resolver
    ): FunctionInfo {
        val parameters =
            this.parameters.map {
                val nullable = checkNullable(it.annotations)
                it.type.buildTypeInfo(it.name?.getShortName(), nullable, classTypeArgs, resolver, isConstructor())
            }
        val returnType = this.returnType?.buildTypeInfo(
            null,
            checkNullable(this.annotations),
            classTypeArgs,
            resolver,
            isConstructor()
        )
        return FunctionInfo(
            defaultFuncName,
            parameters,
            returnType ?: TypeInfo(
                type = resolver.builtIns.unitType.declaration.qualifiedName!!.asString().asMuaType,
            ),
            isConstructor = this.isConstructor()
        )
    }

    inner class LuaApiUsedBuilderVisitor(private val resolver: Resolver) : KSVisitorVoid() {
        lateinit var fileBuilder: FileSpec.Builder
        lateinit var classBuilder: TypeSpec.Builder
        lateinit var classNames: List<String>
        lateinit var currentClassName: String
        var typeArgs: List<String> = listOf()

        override fun visitClassDeclaration(classDeclaration: KSClassDeclaration, data: Unit) {
            val apiInfo = classDeclaration.annotations.first {
                it.shortName.asString() == "LuaApiUsed"
            }.arguments.associate { it.name?.asString() to it.value }
            if (apiInfo["ignore"].castOrNull<Boolean>() == true) {
                return
            }

            classNames = classDeclaration.realClassName()
            currentClassName = classNames.first()
            val ignoreTypeArgs = apiInfo["ignoreTypeArgs"].castOrNull<Boolean>() ?: false
            if (!ignoreTypeArgs) {
                typeArgs = classDeclaration.typeParameters.map { it.simpleName.asString() }
            }

            logger.info("process $currentClassName ${classDeclaration.qualifiedName?.asString()}")
            fileBuilder = FileSpec.builder(packageName, currentClassName)
            classBuilder = TypeSpec.classBuilder(currentClassName)
            typeArgs.forEach {
                classBuilder.addTypeVariable(TypeVariableName(it))
            }

            if (classDeclaration.isAbstract()) {
                classBuilder.addModifiers(KModifier.ABSTRACT)
            }
            addSuperinterface(
                classDeclaration,
                classBuilder,
                typeArgs,
                resolver,
                ignoreTypeArgs
            )

            classDeclaration.getDeclaredFunctions().filter {
                it.annotations.any { it.shortName.asString() == "LuaApiUsed" }
            }.forEach {
                it.accept(this, Unit)
            }
            if (!classDeclaration.isAbstract() && classBuilder.funSpecs.none { it.isConstructor }) {
                classBuilder.addFunction(
                    FunSpec.constructorBuilder()
                        .addStatement("\"$currentClassName()\"").addModifiers(KModifier.ACTUAL).build()
                )
            }

            fileBuilder.addType(classBuilder.build())
            classNames.forEach {
                val file = codeGenerator.createNewFile(
                    Dependencies(true, classDeclaration.containingFile!!),
                    packageName,
                    it.removeClassNameSuffix(),
                    "mua"
                )


                fileOutput(file, fileBuilder, currentClassName, it)
            }
        }

        override fun visitFunctionDeclaration(function: KSFunctionDeclaration, data: Unit) {
            val apiInfo = function.annotations.first {
                it.shortName.asString() == "LuaApiUsed"
            }.arguments.associate { it.name?.asString() to it.value }
            if (apiInfo["ignore"].castOrNull<Boolean>() == true) {
                return
            }
            val originFuncName =
                if (function.isConstructor()) currentClassName else function.simpleName.asString()
            val apiInfoValue = apiInfo["value"].castOrNull<List<KSAnnotation>>()
            val totalTypeArgs = function.typeParameters.map { it.simpleName.asString() } + typeArgs
            val funcInfos = if (apiInfoValue?.isNotEmpty() == true) {
                apiInfoValue.map {
                    it.buildFuncInfo(originFuncName, totalTypeArgs, function.isConstructor(), resolver)
                }
            } else {
                listOf(function.buildFuncInfo(originFuncName, totalTypeArgs, resolver))
            }

            funcInfos.forEach { functionInfo ->
                logger.info("define function $functionInfo")
                classBuilder.addFunction(
                    (if (function.isConstructor()) FunSpec.constructorBuilder() else FunSpec.builder(
                        functionInfo.name
                    )).also {
                        if (functionInfo.comment.isNotBlank()) {
                            it.addComment(functionInfo.comment)
                        }
                    }
                        .addParameters(functionInfo.parameters.mapIndexed { idx, param ->
                            val paramName =
                                param.name?.takeIf { it.isNotBlank() } ?: "param$idx"
                            ParameterSpec.builder(
                                paramName,
                                addType(param, totalTypeArgs),
                            ).build()
                        })
                        .addCode(
                            addCode(functionInfo)
                        ).also {
                            if (!function.isConstructor()) {
                                it.returns(
                                    addType(functionInfo.returnType, totalTypeArgs)
                                )
                            }
                        }
                        .addModifiers(KModifier.PUBLIC)
                        .addModifiers(KModifier.ACTUAL)
                        .build()
                )
            }
            if (funcInfos.isNullOrEmpty()) {
                classBuilder.addFunction(
                    if (function.isConstructor()) FunSpec.constructorBuilder()
                        .addStatement("\"$originFuncName()\"").build()
                    else FunSpec.builder(originFuncName)
                        .addStatement("\"${'$'}0:$originFuncName()\"").build()
                )
            }
        }
    }

    inner class LuaClassBuilderVisitor(private val resolver: Resolver) : KSVisitorVoid() {
        lateinit var fileBuilder: FileSpec.Builder
        lateinit var classBuilder: TypeSpec.Builder
        lateinit var classNames: List<String>
        lateinit var currentClassName: String
        lateinit var typeArgs: List<String>
        var isSingleton = false
        override fun visitClassDeclaration(classDeclaration: KSClassDeclaration, data: Unit) {
            classNames = classDeclaration.realClassName()
            typeArgs = classDeclaration.typeParameters.map { it.simpleName.asString() }
            currentClassName = classNames.first()
            isSingleton = classDeclaration.isSingleton()
            logger.info("process $currentClassName ${classDeclaration.qualifiedName?.asString()}")

            fileBuilder = FileSpec.builder(packageName, currentClassName)
            classBuilder = if (classDeclaration.isSingleton()) TypeSpec.objectBuilder(currentClassName) else TypeSpec.classBuilder(currentClassName)

            typeArgs.forEach {
                classBuilder.addTypeVariable(TypeVariableName(it))
            }

            if (classDeclaration.isAbstract()) {
                classBuilder.addModifiers(KModifier.ABSTRACT)
            }

            addSuperinterface(classDeclaration, classBuilder, typeArgs, resolver)

            classDeclaration.getDeclaredProperties().filter {
                it.annotations.any { it.shortName.asString() == "LuaBridge" }
            }.forEach {
                it.accept(this, Unit)
            }

            classDeclaration.getDeclaredFunctions().filter {
                it.annotations.any { it.shortName.asString() == "LuaBridge" }
            }.forEach {
                it.accept(this, Unit)
            }
            if (!isSingleton && classBuilder.funSpecs.none { it.isConstructor }) {
                classBuilder.addFunction(
                    FunSpec.constructorBuilder()
                        .addStatement("\"$currentClassName()\"").addModifiers(KModifier.ACTUAL).build()
                )
            }

            classNames.forEach {
                fileBuilder.addType(classBuilder.build())

                val file = codeGenerator.createNewFile(
                    Dependencies(true, classDeclaration.containingFile!!),
                    packageName,
                    it.removeClassNameSuffix(),
                    "mua"
                )

                fileOutput(file, fileBuilder, currentClassName, it)
            }
        }

        override fun visitPropertyDeclaration(property: KSPropertyDeclaration, data: Unit) {
            val name = property.simpleName.getShortName()
            val type = property.type.buildTypeInfo(name, checkNullable(property.annotations), typeArgs, resolver, false)
            val getFunctionInfo = FunctionInfo(name, listOf(), type)
            val setFunctionInfo = FunctionInfo(name, listOf(type), TypeInfo("Unit", "mua.Unit", null,false))
            val functionInfos = listOf(getFunctionInfo, setFunctionInfo)
            val totalTypeArgs = property.typeParameters.map { it.simpleName.asString() } + typeArgs
            functionInfos.forEach { functionInfo ->
                logger.info("define property $functionInfo")
                classBuilder.addFunction(FunSpec.builder(
                    functionInfo.name
                )
                    .addParameters(functionInfo.parameters.mapIndexed { idx, param ->
                        val paramName =
                            param.name?.takeIf { it.isNotBlank() } ?: "param$idx"
                        ParameterSpec.builder(
                            paramName,
                            addType(param, totalTypeArgs)
                        ).build()
                    })
                    .addCode(
                        addCode(functionInfo, currentClassName, isSingleton)
                    ).also {
                        it.returns(
                            addType(functionInfo.returnType, totalTypeArgs)
                        )
                    }
                    .addModifiers(KModifier.PUBLIC)
                    .addModifiers(KModifier.ACTUAL)
                    .build())
            }
        }
        override fun visitFunctionDeclaration(function: KSFunctionDeclaration, data: Unit) {
            val apiInfo = function.annotations.first {
                it.shortName.asString() == "LuaBridge"
            }.arguments.associate { it.name?.asString() to it.value }
            val originFuncName = apiInfo["alias"].toString().takeIf { it.isNotBlank() }
                ?: if (function.isConstructor()) currentClassName else apiInfo["alias"].toString()
                    .takeIf { it.isNotBlank() }
                    ?: function.simpleName.asString()

            val totalTypeArgs = function.typeParameters.map { it.simpleName.asString() } + typeArgs
            val functionType = apiInfo["type"].toString()
            val apiInfoValue = apiInfo["value"].castOrNull<List<KSAnnotation>>()
            val functionInfos = if (apiInfoValue?.isNotEmpty() == true) {
                apiInfoValue.map { it.buildFuncInfo(originFuncName, totalTypeArgs, function.isConstructor(), resolver) }
            } else {
                listOf(function.buildFuncInfo(originFuncName, totalTypeArgs, resolver))
            }
            functionInfos.forEach { functionInfo ->
                logger.info("define function $functionInfo")
                classBuilder.addFunction((if (function.isConstructor()) FunSpec.constructorBuilder() else FunSpec.builder(
                    functionInfo.name
                )).also {
                    if (functionInfo.comment.isNotBlank()) {
                        it.addComment(functionInfo.comment)
                    }
                }
                    .addParameters(functionInfo.parameters.filter { it.type != "mlnkit.Globals" }
                        .mapIndexed { idx, param ->
                            val paramName =
                                param.name?.takeIf { it.isNotBlank() } ?: "param$idx"
                            ParameterSpec.builder(
                                paramName,
                                addType(param, totalTypeArgs)
                            ).build()
                        })
                    .addCode(
                        addCode(functionInfo, currentClassName, isSingleton)
                    ).also {
                        if (!function.isConstructor()) {
                            if (functionType == "com.immomo.mls.annotation.BridgeType.SETTER") {
                                it.returns(ClassName.bestGuess(realQualifiedName(className = currentClassName)))
                            } else {
                                it.returns(
                                    addType(functionInfo.returnType, totalTypeArgs)
                                )
                            }
                        }
                    }
                    .addModifiers(KModifier.PUBLIC)
                    .addModifiers(KModifier.ACTUAL)
                    .build())
            }
        }
    }

    inner class LuaConstantClassBuilderVisitor(private val resolver: Resolver) : KSVisitorVoid() {
        lateinit var fileBuilder: FileSpec.Builder
        lateinit var classBuilder: TypeSpec.Builder
        lateinit var classNames: List<String>
        override fun visitClassDeclaration(classDeclaration: KSClassDeclaration, data: Unit) {
            classNames = classDeclaration.realClassName()
            classNames.forEach { className ->
                logger.info("process $className ${classDeclaration.qualifiedName?.asString()}")

                fileBuilder = FileSpec.builder(packageName, className)
                classBuilder = TypeSpec.objectBuilder(className)

                classBuilder.addSuperinterface(
                    ClassName("mua", "Bridged")
                )

                classDeclaration.getDeclaredProperties().filter {
                    it.annotations.any { it.shortName.asString() == "Constant" }
                }.forEach {
                    it.accept(this, Unit)
                }

                fileBuilder.addType(classBuilder.build())
//                fileBuilder.addFileComment("真实值详见客户端代码。")

                val file = codeGenerator.createNewFile(
                    Dependencies(true, classDeclaration.containingFile!!),
                    packageName,
                    className.replace(getClassNameSuffix(), ""),
                    "mua"
                )

                fileOutput(file, fileBuilder, className, className)
            }
        }

        override fun visitPropertyDeclaration(property: KSPropertyDeclaration, data: Unit) {
            val typeName = property.type.resolve().declaration.qualifiedName!!.asString()
            classBuilder.addProperty(
                PropertySpec.builder(
                    property.simpleName.getShortName(),
                    ClassName.bestGuess(typeName.asMuaType),
                    KModifier.PUBLIC,KModifier.ACTUAL
                ).build()
            )

        }

    }

    private fun addType(typeInfo: TypeInfo, classTypeArgs: List<String>): TypeName {
        return if (classTypeArgs.contains(typeInfo.type)) {
            TypeVariableName(typeInfo.type)
        } else {
            addClassParameterized(ClassName.bestGuess(typeInfo.type), typeInfo.typeArgs, classTypeArgs)
        }.copy(nullable = typeInfo.isNullable)
    }

    private fun addClassParameterized(
        className: ClassName,
        typeArgs: List<TypeInfo>?,
        classTypeArgs: List<String>
    ): TypeName {
        if (!typeArgs.isNullOrEmpty()) {
            return className.parameterizedBy(typeArgs.map {
                if (classTypeArgs.contains(it.type)) {
                    TypeVariableName(it.type)
                } else {
                    addClassParameterized(ClassName.bestGuess(it.type), it.typeArgs, classTypeArgs)
                }.copy(nullable = it.isNullable)
            })
        }
        return className
    }

    private fun addCode(functionInfo: FunctionInfo, className: String = "", isSingleton: Boolean = false): CodeBlock {
        val selfPrefix = if (functionInfo.isConstructor) "" else if (isSingleton) "$className:" else "$0:"
        return CodeBlock.of(
            """"$selfPrefix${functionInfo.name}(${
                List(functionInfo.parameters.size) { index -> "${'$'}${index.plus(1)}" }
                    .joinToString(separator = ", ")
            })"""".trimIndent()
        )
    }

    private fun addSuperinterface(
        classDeclaration: KSClassDeclaration,
        classBuilder: TypeSpec.Builder,
        typeArgs: List<String>,
        resolver: Resolver,
        ignoreTypeArgs: Boolean = false,
    ) {
        val superTypes =
            classDeclaration.superTypes.filter { it.resolve().declaration.annotations.any {
                val anno = it.shortName.asString()
                anno == "LuaApiUsed" || anno == "LuaClass" }
            }.map {
                it.buildTypeInfo(
                    null,
                    false,
                    typeArgs,
                    resolver,
                    false,
                    ignoreTypeArgs
                )
            }
        if (superTypes.count() == 0) {
            classBuilder.addSuperinterface(
                ClassName("mua", "Bridged")
            )
        }

        superTypes.forEach {
            if (it.name == "LuaUserdata"
                || it.name == "JavaUserdata" || it.name.isNullOrEmpty()
            ) {
                classBuilder.addSuperinterface(
                    ClassName("mua", "Bridged")
                )
            } else {
                classBuilder.addSuperinterface(
                    if (ignoreTypeArgs) {
                        ClassName.bestGuess(it.type)
                    } else {
                        addType(it, typeArgs)
                    }
                )
            }
        }
    }

    private fun fileOutput(
        file: OutputStream,
        fileBuilder: FileSpec.Builder,
        originClassName: String,
        finalClassName: String
    ) {
        OutputStreamWriter(file, StandardCharsets.UTF_8)
            .use {
                fileBuilder.build().writeTo(
                    object : Appendable {
                        override fun append(csq: CharSequence?): java.lang.Appendable {
                            var string = csq?.toString()
                            if (string == "actual") {
                                return it.append("translate")
                            }

                            if (string?.contains(getClassNameSuffix()) == true) {
                                if (string.contains(originClassName) && (string.indexOf(originClassName) == 0 || !string.get(
                                        string.indexOf(originClassName) - 1
                                    ).isLetter())
                                ) {
                                    string = string.replace(originClassName, finalClassName)
                                }
                                return it.append(string.removeClassNameSuffix())
                            }

                            string?.split(" ")?.forEach {word ->
                                if (word.startsWith("`") && word.contains("`(")) {
                                    return it.append(string.replace(word, word.replace("`", "")))
                                }
                            }
                            return it.append(csq)
                        }

                        override fun append(csq: CharSequence?, start: Int, end: Int): java.lang.Appendable {
                            return it.append(csq, start, end)
                        }

                        override fun append(c: Char): java.lang.Appendable {
                            return it.append(c)
                        }

                    }
                )
            }
    }

    private val nullAnnotationName = listOf("NotNull", "NonNull")
    private fun checkNullable(annotations: Sequence<KSAnnotation>): Boolean {
        return annotations.firstOrNull {
            nullAnnotationName.contains(it.shortName.asString())
        } == null
    }
}
