//
// Created by momo783 on 2020/5/15.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include "RunLoop.h"
#include <jni.h>
#include <string>
#include <android/log.h>
#include "ObjectAnimation.h"
#include "AnimatorEngine.h"

#define TAG    "[AnimatorJNI]"

#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,TAG,__VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR,TAG,__VA_ARGS__)

#include "Defines.h"

#ifdef ANIMATOR_PLATFORM_ANDROID

JavaVM *globalJVM;

extern "C"
JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    globalJVM = vm;
    return JNI_VERSION_1_4;
}

JNIEnv *GetJNIEnv() {
    if (globalJVM) {
        JNIEnv *env = nullptr;
        jint ret = globalJVM->GetEnv((void **) &env, JNI_VERSION_1_4);
        if (ret == JNI_OK) {
            return env;
        }
    }
    return nullptr;
}

extern "C" JNIEXPORT void JNICALL
Java_com_example_mlanimator_MainActivity_testCplusplusAnimation(JNIEnv *env, jobject thiz) {

    /**
     * 测试代码, 测试Android代码流程
     */
    using namespace ANIMATOR_NAMESPACE;

    ObjectAnimation *animation = new ObjectAnimation("xxxx");
    AMTFloat fromValues[2] = {0.f, 100.f};
    AMTFloat toValuest[2] = {10.f, 200.f};
    animation->FromToValues(fromValues, toValuest, 2);
    animation->Duration(1.5f);
    animation->ViaTimingFunction(animator::TimingFunction::Linear);

    AnimatorEngine::ShareAnimator()->AddAnimation(animation);
    LOGD("xxxx AddAnimation \n");

    AnimatorEngine::ShareAnimator()->animatorEngineLoopStart = [](AMTTimeInterval currentTime) {
        LOGD("xxxx animatorEngineLoopStart \n");
    };

    AnimatorEngine::ShareAnimator()->animatorEngineLoopEnd = [](AMTTimeInterval currentTime) {
        LOGD("xxxx animatorEngineLoopEnd \n");
    };

    AnimatorEngine::ShareAnimator()->updateAnimation = [](animator::Animation *animation) {
        ValueAnimation *valueAnimation = (ValueAnimation *) animation;
        const AMTFloat *values = valueAnimation->GetCurrentValue().data();
        LOGD("Animation %p current values 1:%f  2:%f \n", animation, values[0], values[1]);
    };

    AnimatorEngine::ShareAnimator()->animationFinish = [](animator::Animation *ani,
                                                          AMTBool finish) {
        LOGD("Animation %p finished \n", ani);
    };

}

extern "C"
JNIEXPORT void JNICALL
Java_com_immomo_mmui_anim_extra_Runloop_nativeRunLoop(JNIEnv *env, jobject thiz, jlong current_time) {
    if (animator::RunLoop::ShareLoop()->LoopCallback) {
        animator::RunLoop::ShareLoop()->LoopCallback(current_time / 1000.0);
    }
}


ANIMATOR_NAMESPACE_BEGIN


    void RunLoop::StartLoop() {
        JNIEnv *env = GetJNIEnv();
        jclass cls = env->FindClass("com/immomo/mmui/anim/extra/Runloop");
        jmethodID mid = env->GetStaticMethodID(cls, "startLoop", "()V");
        env->CallStaticVoidMethod(cls, mid);

        running = true;
    }

    void RunLoop::StopLoop() {
        JNIEnv *env = GetJNIEnv();
        jclass cls = env->FindClass("com/immomo/mmui/anim/extra/Runloop");
        jmethodID mid = env->GetStaticMethodID(cls, "stopLoop", "()V");
        env->CallStaticVoidMethod(cls, mid);

        running = false;
    }

    void RunLoop::DestoryShareLoop() {
        RunLoop::ShareLoop()->StopLoop();
    }

    AMTTimeInterval RunLoop::CurrentTime() {
        JNIEnv *env = GetJNIEnv();
        jclass cls = env->FindClass("com/immomo/mmui/anim/extra/Runloop");
        jmethodID mid = env->GetStaticMethodID(cls, "currentTime", "()J");
        jlong time = env->CallStaticLongMethod(cls, mid);
        return (time / 1000.0);
    }

ANIMATOR_NAMESPACE_END

#endif