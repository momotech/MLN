package com.immomo.mls.processor

import com.immomo.mls.annotation.MLN
import javax.annotation.processing.Filer
import javax.annotation.processing.ProcessingEnvironment
import javax.annotation.processing.RoundEnvironment
import javax.lang.model.element.TypeElement

object LuaRegisterProcessor {
    fun process(
        env: ProcessingEnvironment,
        roundEnv: RoundEnvironment,
        filer: Filer,
        logger: Logger
    ) {
        val set = roundEnv.getElementsAnnotatedWith(
            MLN::class.java
        )
        val filterIsInstance = set.filterIsInstance(TypeElement::class.java)
        val firstTypeElement = filterIsInstance.firstOrNull()
//        try {

            if (firstTypeElement != null) {
                val luaRegisterGenerator =
                    LuaRegisterGenerator.Builder(logger, firstTypeElement, null)
                        .build()
                filterIsInstance.forEach { it ->
                    luaRegisterGenerator.addStatement(env,it)
                }
                luaRegisterGenerator.build().writeTo(filer)
            }

//        } catch (e: IOException) {
//            e.printStackTrace()
//        }
    }
}