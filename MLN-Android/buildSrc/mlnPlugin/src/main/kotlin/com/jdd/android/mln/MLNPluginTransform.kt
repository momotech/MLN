package com.jdd.android.mln


import com.android.build.api.transform.*
import com.android.build.gradle.internal.pipeline.TransformManager
import org.apache.commons.codec.digest.DigestUtils
import org.gradle.api.Project
import java.io.File

sealed class InspectMode {
    object INCREMENTAL : InspectMode() {
        override fun toString() = "InspectMode.INCREMENTAL"
    }

    class FUll(val needCopy: Boolean = true) : InspectMode() {
        override fun toString() = "InspectMode.FULL(needCopy=$needCopy)"
    }
}

class MLNPluginTransform(private val project: Project) : Transform() {
    override fun getName(): String = "MLNPluginTransform"

    override fun getInputTypes(): MutableSet<QualifiedContent.ContentType> =
        TransformManager.CONTENT_CLASS

    override fun getScopes(): MutableSet<in QualifiedContent.Scope> =
        TransformManager.SCOPE_FULL_PROJECT

    override fun isIncremental(): Boolean = true

    override fun transform(transformInvocation: TransformInvocation) {

        val inspectModes = if (transformInvocation.isIncremental) {
            arrayListOf(InspectMode.INCREMENTAL, InspectMode.FUll(needCopy = false))
        } else {
            transformInvocation.outputProvider.deleteAll()

            arrayListOf(InspectMode.FUll())
        }

        inspectModes.forEach { inspectMode ->
            project.logger.info("Starting $name, inspectMode=$inspectMode")
            val context = MLNPluginContext()

            transformInvocation.inputs.forEach { input ->
                input.directoryInputs.forEach { dirInput ->
                    val outputDir = transformInvocation.outputProvider.getContentLocation(
                        dirInput.name,
                        dirInput.contentTypes,
                        dirInput.scopes,
                        Format.DIRECTORY
                    )

                    context.handleDirInput(dirInput, outputDir, inspectMode)
                }

                input.jarInputs.forEach { jarInput ->
                    val outputJar = transformInvocation.outputProvider.getContentLocation(
                        jarInput.name.removeSuffix(".jar") + DigestUtils.md5Hex(jarInput.file.absolutePath),
                        jarInput.contentTypes,
                        jarInput.scopes,
                        Format.JAR
                    )

                    context.handleJarInput(jarInput, outputJar, inspectMode)
                }
            }

            if (!context.needInject()) {
                project.logger.info("No action needed.")
                return
            } else if (inspectMode is InspectMode.FUll) {
                context.inject()
                project.logger.info("End of $name.")
            }
        }
    }
}

private fun MLNPluginContext.handleDirInput(
    dirInput: DirectoryInput,
    outputDir: File,
    inspectMode: InspectMode
) {
    val inputFilePathLen = dirInput.file.path.length
    val copyAndInspectFunc = { inputFile: File, inputFileStatus: Status, needCopy: Boolean ->
        val outputFile = File(outputDir, inputFile.path.substring(inputFilePathLen))
        this.inspectFile(inputFile, inputFileStatus, outputFile)

        if (needCopy) {
            when (inputFileStatus) {
                Status.ADDED, Status.CHANGED -> {
                    if (inputFile.isDirectory) {
                        outputFile.mkdirs()
                    } else {
                        inputFile.copyTo(outputFile, overwrite = true)
                    }
                }
                Status.REMOVED -> {
                    outputFile.deleteRecursively()
                }
                else -> Unit
            }
        }

    }
    when (inspectMode) {
        is InspectMode.INCREMENTAL -> {
            dirInput.changedFiles.forEach { (inputFile, inputFileStatus) ->
                copyAndInspectFunc(inputFile, inputFileStatus, true)
            }
        }
        is InspectMode.FUll -> {
            dirInput.file.walkTopDown().forEach { inputFile ->
                copyAndInspectFunc(inputFile, Status.ADDED, inspectMode.needCopy)
            }
        }
    }
}

private fun MLNPluginContext.handleJarInput(
    jarInput: JarInput,
    outputJar: File,
    inspectMode: InspectMode
) {
    val copyAndInspectFunc = { inputJar: File, inputJarStatus: Status, needCopy: Boolean ->
        if (jarInput.scopes.contains(QualifiedContent.Scope.SUB_PROJECTS) || jarInput.scopes.contains(
                QualifiedContent.Scope.EXTERNAL_LIBRARIES
            )
        ) {
            this.inspectJar(inputJar, inputJarStatus, outputJar)
        }

        if (needCopy) {
            when (inputJarStatus) {
                Status.ADDED, Status.CHANGED -> {
                    inputJar.copyTo(outputJar, overwrite = true)
                }
                Status.REMOVED -> {
                    outputJar.deleteRecursively()
                }
                else -> Unit
            }
        }
    }
    when (inspectMode) {
        is InspectMode.INCREMENTAL -> {
            copyAndInspectFunc(jarInput.file, jarInput.status, true)
        }
        is InspectMode.FUll -> {
            copyAndInspectFunc(jarInput.file, Status.ADDED, inspectMode.needCopy)
        }
    }
}