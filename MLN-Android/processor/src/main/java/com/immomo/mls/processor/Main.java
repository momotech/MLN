/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.processor;

import com.google.auto.service.AutoService;
import com.squareup.javapoet.ClassName;
import com.squareup.javapoet.JavaFile;
import com.immomo.mls.annotation.CreatedByApt;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import java.io.IOException;
import java.lang.annotation.Annotation;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.Filer;
import javax.annotation.processing.ProcessingEnvironment;
import javax.annotation.processing.Processor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedOptions;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.TypeElement;
import javax.tools.Diagnostic;

/**
 * Created by XiongFangyu on 2018/8/29.
 *
 * 入口文件
 */
@SupportedOptions({Options.SDK, Options.SKIP_PACKAGE})
@AutoService(Processor.class)
public class Main extends AbstractProcessor implements Logger{

    private static final Class<? extends Annotation>[] SUPPORT_TYPE = new Class[] {
            CreatedByApt.class,
            LuaClass.class,
            LuaBridge.class,
    };

    private Set<ClassName> skip;
    private Options options;
    private boolean hasError = false;

    @Override
    public synchronized void init(ProcessingEnvironment env) {
        super.init(env);
        skip = new HashSet<>();
        options = new Options(env.getOptions());
    }

    @Override
    public SourceVersion getSupportedSourceVersion() {
        return SourceVersion.latestSupported();
    }

    @Override
    public Set<String> getSupportedAnnotationTypes() {
        Set<String> set = new HashSet<>();
        for (int i = 0, l = SUPPORT_TYPE.length; i < l; i ++) {
            set.add(SUPPORT_TYPE[i].getCanonicalName());
        }
        return set;
    }

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        skip.addAll(getNeedSkipClass(roundEnv));
        final Filer filer = processingEnv.getFiler();
        Map<TypeElement, Generator> map = PreProcess.process(skip, annotations, roundEnv, options, this);
        if (map != null) {
            for (Map.Entry<TypeElement, Generator> entry : map.entrySet()) {
                TypeElement typeElement = entry.getKey();
                Generator generator = entry.getValue();
                JavaFile file = generator.generateFile();
                if (file == null)
                    continue;
                try {
                    file.writeTo(filer);
                } catch (IOException e) {
                    error(typeElement, "Unable to generate code for typeElement %s: %s", typeElement, e.getMessage());
                }
            }
        }
        if (hasError) {
            throw new RuntimeException("error occur when process, see log before");
        }
        return false;
    }

    private Set<ClassName> getNeedSkipClass(RoundEnvironment roundEnv) {
        Set<? extends Element> skip = roundEnv.getElementsAnnotatedWith(CreatedByApt.class);
        Set<ClassName> ret = new HashSet<>(skip.size());
        for (Element e : skip) {
            TypeElement te = (TypeElement) e;
            ClassName cn = ClassName.get(te);
            String name = cn.simpleName();
            name = name.substring(0, name.lastIndexOf("_"));
            ret.add(ClassName.get(cn.packageName(), name));
        }
        return ret;
    }

    //<editor-fold desc="LOG">
    public void error(Element element, String message, Object... args) {
        log(Diagnostic.Kind.ERROR, element, message, args);
        hasError = true;
    }

    public void note(Element element, String message, Object... args) {
        log(Diagnostic.Kind.NOTE, element, message, args);
    }

    public void log(Diagnostic.Kind kind, Element element, String message, Object[] args) {
        if (args.length > 0) {
            message = String.format(message, args);
        }

        processingEnv.getMessager().printMessage(kind, message, element);
    }
    //</editor-fold>
}