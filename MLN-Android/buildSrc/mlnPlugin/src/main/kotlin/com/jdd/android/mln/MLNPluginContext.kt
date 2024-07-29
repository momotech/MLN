package com.jdd.android.mln


import com.android.build.api.transform.Status
import com.jdd.android.mln.MLNClassScanVisitor.Companion.APP_ASM_CONTEXT_CLASS_NAME
import org.objectweb.asm.ClassReader
import org.objectweb.asm.ClassWriter
import java.io.*
import java.util.jar.JarEntry
import java.util.jar.JarFile
import java.util.jar.JarOutputStream

/**
 * Holds all the parameters and internal states
 */
internal class MLNPluginContext() {
    private var appSource: AppSource? = null

    private val moduleConfigList = mutableListOf<ModuleConfig>()

    @Throws(Throwable::class)
    private fun InputStream.readClass(markAppAsmSource: () -> Unit) = use {
        val classReader = ClassReader(this)
        if (classReader.className == APP_ASM_CONTEXT_CLASS_NAME) {
            markAppAsmSource()
        } else {
            classReader.accept(
                MLNClassScanVisitor(classReader) { _, moduleConfig ->
                    if (moduleConfig != null) {
                        moduleConfigList.add(moduleConfig)
                    }
                }, 0
            )
        }
    }

    fun inspectFile(inputFile: File, inputFileStatus: Status, outputFile: File) =
        when (inputFileStatus) {
            Status.ADDED, Status.CHANGED -> {
                if (inputFile.isFile && inputFile.name.endsWith(".class")) inputFile else null
            }
            Status.REMOVED -> {
                if (outputFile.isFile && outputFile.name.endsWith(".class")) outputFile else null
            }
            else -> null
        }?.let { file ->
            FileInputStream(file).readClass {
                appSource = AppSource.FileSource(
                    file.absolutePath,
                    outputFilePath = outputFile.absolutePath
                )
            }
        }

    fun inspectJar(inputJar: File, inputJarStatus: Status, outputJar: File) =
        when (inputJarStatus) {
            Status.ADDED, Status.CHANGED -> inputJar
            Status.REMOVED -> outputJar
            else -> null
        }?.let { file ->
            val jarFile = JarFile(file)
            jarFile.entries().asSequence().filter { it.name.endsWith(".class") }
                .forEach { jarEntry ->
                    jarFile.getInputStream(jarEntry).readClass {
                        appSource = AppSource.JarSource(
                            jarEntry.name,
                            file.absolutePath,
                            outputJar.absolutePath
                        )
                    }
                }
        }

    /**
     * if any changes found in scan
     */
    fun needInject() =
        appSource != null //|| moduleConfigList.isNotEmpty()

    fun inject() = appSource?.apply {
        inject { inputStream ->

            val classReader = ClassReader(inputStream)
            val classWriter = ClassWriter(classReader, ClassWriter.COMPUTE_MAXS)
            classReader.accept(
                MLNClassInjectVisitor(
                    classWriter,
                    moduleConfigList
                ), 0
            )
            classWriter.toByteArray()
        }
    }
}

internal sealed class AppSource {
    abstract fun inject(block: (InputStream) -> ByteArray)

    class FileSource(
        private val sourceFilePath: String,
        private val outputFilePath: String
    ) : AppSource() {
        override fun inject(block: (InputStream) -> ByteArray) =
            FileInputStream(sourceFilePath).use { inputStream ->
                FileOutputStream(outputFilePath).use {
                    it.write(block(inputStream))
                }
            }
    }

    class JarSource(
        private val sourceEntryName: String,
        private val sourceJarPath: String,
        private val outputJarPath: String
    ) : AppSource() {
        override fun inject(block: (InputStream) -> ByteArray) {
            val jarFile = JarFile(sourceJarPath)

            val fileOutputStream = FileOutputStream(outputJarPath)
            val jarOutputStream = JarOutputStream(fileOutputStream)
            using(fileOutputStream, jarOutputStream) { _, _ ->
                jarFile.entries().asSequence().forEach { jarEntry ->
                    jarOutputStream.putNextEntry(
                        if (jarEntry.name == sourceEntryName) {
                            JarEntry(jarEntry.name)
                        } else {
                            JarEntry(jarEntry).apply { compressedSize = -1 }
                        }
                    )

                    jarFile.getInputStream(jarEntry).use { inputStream ->
                        if (jarEntry.name == sourceEntryName) {
                            jarOutputStream.write(block(inputStream))
                        } else {
                            inputStream.copyTo(jarOutputStream)
                        }
                    }

                    jarOutputStream.closeEntry()
                }
            }
        }
    }

    fun <T1 : Closeable?, T2 : Closeable?, R> using(a: T1, b: T2, block: (T1, T2) -> R) {
        a.use {
            b.use {
                block(a, b)
            }
        }
    }
}