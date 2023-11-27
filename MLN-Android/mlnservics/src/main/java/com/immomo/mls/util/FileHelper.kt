package com.immomo.mls.util

import java.io.File

/**
 * CREATED BY liu.chong
 * AT 9/3/2023
 */
object FileHelper {
    fun deleteRecursively(file: File) {
        file.deleteRecursively()
    }
}