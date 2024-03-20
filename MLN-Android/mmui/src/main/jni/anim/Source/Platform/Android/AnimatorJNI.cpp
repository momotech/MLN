//
// Created by momo783 on 2020/5/28.
//
#include <jni.h>
#include <Animations/ObjectAnimation.h>
#include <Animations/SpringAnimation.h>
#include <Animations/MultiAnimation.h>
#include "AnimatorEngine.h"
#include <vector>
#include <android/log.h>

#define TAG    "[AnimatorJNI]"

#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, TAG, __VA_ARGS__)

#define _CALL(r) extern "C" JNIEXPORT r JNICALL
#define _METHOD(m) Java_com_immomo_mmui_anim_Animator_ ## m
#define _PARAM JNIEnv *env, jobject thiz

extern JNIEnv *GetJNIEnv();

using namespace ANIMATOR_NAMESPACE;

static jclass Animator_class = nullptr;
static jmethodID Animator_onUpdateAnimation = nullptr;
static jmethodID Animator_onAnimationFinish = nullptr;
static jmethodID Animator_onAnimationRepeat = nullptr;
static jmethodID Animator_onAnimationPause = nullptr;
static jmethodID Animator_onAnimationRelRunStart = nullptr;

_CALL(void) _METHOD(nativeInitCreateAnimator)(_PARAM) {
    Animator_class = env->FindClass("com/immomo/mmui/anim/Animator");
    Animator_class = static_cast<jclass>(env->NewGlobalRef(Animator_class));
    Animator_onUpdateAnimation = env->GetStaticMethodID(Animator_class, "onUpdateAnimation", "(J)V");
    Animator_onAnimationFinish = env->GetStaticMethodID(Animator_class, "onAnimationFinish", "(JZ)V");
    Animator_onAnimationRepeat = env->GetStaticMethodID(Animator_class, "onAnimationRepeat", "(JJI)V");
    Animator_onAnimationPause = env->GetStaticMethodID(Animator_class, "onAnimationPause", "(JZ)V");
    Animator_onAnimationRelRunStart = env->GetStaticMethodID(Animator_class, "onAnimationRelRunStart", "(J)V");

    AnimatorEngine::ShareAnimator()->updateAnimation = [](Animation *animation) {
        JNIEnv *env = GetJNIEnv();
        env->CallStaticVoidMethod(Animator_class,
                Animator_onUpdateAnimation,
                reinterpret_cast<jlong>(animation));
    };
    AnimatorEngine::ShareAnimator()->animationFinish = [](Animation *animation, AMTBool finish) {
        JNIEnv *env = GetJNIEnv();
        env->CallStaticVoidMethod(Animator_class,
                Animator_onAnimationFinish,
                reinterpret_cast<jlong>(animation),
                finish);
    };
    AnimatorEngine::ShareAnimator()->animationRepeat = [](Animation *caller, Animation *executor, AMTInt count) {
        JNIEnv *env = GetJNIEnv();
        env->CallStaticVoidMethod(Animator_class,
                Animator_onAnimationRepeat,
                reinterpret_cast<jlong>(caller),
                reinterpret_cast<jlong>(executor),
                count);
    };
    AnimatorEngine::ShareAnimator()->animationPause = [](Animation *animation, AMTBool pause) {
        JNIEnv *env = GetJNIEnv();
        env->CallStaticVoidMethod(Animator_class,
                Animator_onAnimationPause,
                reinterpret_cast<jlong>(animation),
                pause);
    };
    AnimatorEngine::ShareAnimator()->animationStart = [](Animation *animation) {
        JNIEnv *env = GetJNIEnv();
        env->CallStaticVoidMethod(Animator_class,
                Animator_onAnimationRelRunStart,
                reinterpret_cast<jlong>(animation));
    };
}


_CALL(void) _METHOD(nativeRemoveAnimation)(_PARAM, jlong ani_pointer) {
    MultiAnimation *animation = reinterpret_cast<MultiAnimation *>(ani_pointer);
    animator::AnimatorEngine::ShareAnimator()->RemoveAnimation(animation);
}

_CALL(void) _METHOD(nativeAddAnimation)(_PARAM, jlong animator_pointer) {
    animator::Animation *animation = reinterpret_cast< animator::Animation *>(animator_pointer);
    animator::AnimatorEngine::ShareAnimator()->AddAnimation(animation);
}

_CALL(jlong) _METHOD(nativeCreateAnimation)(_PARAM, jstring animation_name, jstring animation_key) {
    const char *name = env->GetStringUTFChars(animation_name, JNI_FALSE);
    const char *key = env->GetStringUTFChars(animation_key, JNI_FALSE);

    Animation *pointer = NULL;
    if (strcmp(name, "ObjectAnimation") == 0) {
        pointer = new ObjectAnimation(key);
    } else if (strcmp(name, "SpringAnimation") == 0) {
        pointer = new SpringAnimation(key);
    } else if (strcmp(name, "MultiAnimation") == 0) {
        pointer = new MultiAnimation(key);
    }

    env->ReleaseStringUTFChars(animation_name, name);
    env->ReleaseStringUTFChars(animation_key, key);

    return reinterpret_cast<jlong>(pointer);
}

_CALL(void) _METHOD(nativeReleaseAnimation) (_PARAM, jlong p) {
    MultiAnimation *animation = reinterpret_cast<MultiAnimation *>(p);
    delete(animation);
}

_CALL(jlongArray) _METHOD(nativeGetMultiAnimationRunningList)(_PARAM, jlong animator_pointer) {
    animator::MultiAnimation *multiAnimation = reinterpret_cast< animator::MultiAnimation *>(animator_pointer);
    MultiAnimationList &animationList = const_cast<MultiAnimationList &>(multiAnimation->GetRunningAnimationList());
    int size = animationList.size();

    jlongArray result = env->NewLongArray(size);
    jlong *valuesBuffer = (jlong *) calloc((size_t) size, sizeof(jlong));

    for (int i = 0; i < size; ++i) {
        jlong pointer = reinterpret_cast<jlong>(animationList[i]);
        valuesBuffer[i] = pointer;
    }
    env->SetLongArrayRegion(result, 0, size, valuesBuffer);
    free(valuesBuffer);

    return result;
}

_CALL(jfloatArray) _METHOD(nativeGetCurrentValues)(_PARAM, jlong animator_pointer) {
    ValueAnimation *valueAnimation = (ValueAnimation *) animator_pointer;

    int size = valueAnimation->GetCurrentValue().size();
    const AMTFloat *values = valueAnimation->GetCurrentValue().data();

    jfloatArray result = env->NewFloatArray(size);
    jfloat *valuesBuffer = (jfloat *) calloc((size_t) size, sizeof(jfloat));
    for (int i = 0; i < size; ++i) {
        valuesBuffer[i] = (float) values[i];
    }
    env->SetFloatArrayRegion(result, 0, size, valuesBuffer);
    free(valuesBuffer);

    return result;
}

_CALL(void) _METHOD(nativeSetObjectAnimationParams)(_PARAM,
                                                              jlong ani_point,
                                                              jfloatArray f,
                                                              jfloatArray t,
                                                              jfloatArray f_params,
                                                              jboolean repeat_forever,
                                                              jboolean auto_reverse,
                                                              jint timing_function) {

    if (!ani_point) {
        return;
    }

    ObjectAnimation *animation = reinterpret_cast<ObjectAnimation *>(ani_point);
    int size = env->GetArrayLength(f);

    jfloat *fParams = env->GetFloatArrayElements(f_params, JNI_FALSE);
    jfloat *fromValues = env->GetFloatArrayElements(f, JNI_FALSE);
    jfloat *toValues = env->GetFloatArrayElements(t, JNI_FALSE);

    AMTFloat *resultFromBuffer = (AMTFloat *) calloc((size_t) size, sizeof(AMTFloat));
    AMTFloat *resultToBuffer = (AMTFloat *) calloc((size_t) size, sizeof(AMTFloat));
    for (int i = 0; i < size; ++i) {
        resultFromBuffer[i] = (AMTFloat) fromValues[i];
        resultToBuffer[i] = (AMTFloat) toValues[i];
    }

    animation->FromToValues(resultFromBuffer, resultToBuffer, size);
    animation->Duration(fParams[1]);
    animation->SetRepeatCount((AMTInt) (fParams[2]));
    animation->threshold = fParams[3];
    animation->SetRepeatForever(repeat_forever);
    animation->SetAutoreverses(auto_reverse);
    animation->SetBeginTime((AMTTimeInterval) fParams[0]);

    animation->ViaTimingFunction(animator::TimingFunction(timing_function));

    env->ReleaseFloatArrayElements(f_params, fParams, 0);
    env->ReleaseFloatArrayElements(f, fromValues, 0);
    env->ReleaseFloatArrayElements(t, toValues, 0);

    free(resultFromBuffer);
    free(resultToBuffer);
}

_CALL(void) _METHOD(nativeSetMultiAnimationParams)(_PARAM,
                                                             jlong ani_pointer,
                                                             jlongArray sub_ani_pointers,
                                                             jboolean is_run_together) {
    if (!ani_pointer) {
        return;
    }

    MultiAnimation *animation = reinterpret_cast<MultiAnimation *>(ani_pointer);
    MultiAnimationList multiAnimationList;

    int arrLen = env->GetArrayLength(sub_ani_pointers);
    jlong *carr = env->GetLongArrayElements(sub_ani_pointers, JNI_FALSE);
    for (int i = 0; i < arrLen; i++) {
        Animation *aniTemp = reinterpret_cast<Animation *>(carr[i]);
        if (aniTemp) {
            multiAnimationList.push_back(aniTemp);
        }
    }
    env->ReleaseLongArrayElements(sub_ani_pointers, carr, 0);

    if (is_run_together) {
        animation->RunTogether(multiAnimationList);
    } else {
        animation->RunSequentially(multiAnimationList);
    }

}

_CALL(void) _METHOD(nativeSetMultiAnimationBeginTime)(_PARAM,
                                                                 jlong ani_pointer,
                                                                 jfloat begin_time){
    if (!ani_pointer) {
        return;
    }
    MultiAnimation *animation = reinterpret_cast<MultiAnimation *>(ani_pointer);
    animation->SetBeginTime(begin_time);
}

_CALL(void) _METHOD(nativeSetMultiAnimationRepeatCount)(_PARAM,
                                                                    jlong ani_pointer,
                                                                    jfloat repeat_count){
    if (!ani_pointer) {
        return;
    }
    MultiAnimation *animation = reinterpret_cast<MultiAnimation *>(ani_pointer);
    animation->SetRepeatCount((AMTInt) repeat_count);
}

_CALL(void) _METHOD(nativeSetMultiAnimationRepeatForever)(_PARAM,
                                                                    jlong ani_pointer,
                                                                    jboolean repeat_forever){
    if (!ani_pointer) {
        return;
    }
    MultiAnimation *animation = reinterpret_cast<MultiAnimation *>(ani_pointer);
    animation->SetRepeatForever(repeat_forever);
}

_CALL(void) _METHOD(nativeSetMultiAnimationAutoReverse)(_PARAM,
                                                                    jlong ani_pointer,
                                                                    jboolean auto_reverse){
    if (!ani_pointer) {
        return;
    }
    MultiAnimation *animation = reinterpret_cast<MultiAnimation *>(ani_pointer);
    animation->SetAutoreverses(auto_reverse);
}

_CALL(void) _METHOD(nativeSetSpringAnimationParams)(_PARAM,
                                                              jlong ani_point,
                                                              jfloatArray f,
                                                              jfloatArray t,
                                                              jfloatArray current_velocity,
                                                              jfloatArray f_params,
                                                              jboolean repeat_forever,
                                                              jboolean auto_reverse) {
    if (!ani_point) {
        return;
    }

    SpringAnimation *animation = reinterpret_cast<SpringAnimation *>(ani_point);
    int size = env->GetArrayLength(f);
    jfloat *fParams = env->GetFloatArrayElements(f_params, JNI_FALSE);
    jfloat *fromValues = env->GetFloatArrayElements(f, JNI_FALSE);
    jfloat *toValues = env->GetFloatArrayElements(t, JNI_FALSE);
    jfloat *velocitys = env->GetFloatArrayElements(current_velocity, JNI_FALSE);

    AMTFloat *resultFromBuffer = (AMTFloat *) calloc((size_t) size, sizeof(AMTFloat));
    AMTFloat *resultToBuffer = (AMTFloat *) calloc((size_t) size, sizeof(AMTFloat));
    AMTFloat *amtVelocitys = (AMTFloat *) calloc((size_t) size, sizeof(AMTFloat));
    for (int i = 0; i < size; ++i) {
        resultFromBuffer[i] = (AMTFloat) fromValues[i];
        resultToBuffer[i] = (AMTFloat) toValues[i];
        amtVelocitys[i] = (AMTFloat) velocitys[i];
    }

    animation->FromToValues(resultFromBuffer, resultToBuffer, size);
    animation->SetAutoreverses(auto_reverse);
    animation->SetSpringSpeed(fParams[0]);
    animation->SetSpringBounciness(fParams[1]);

    animation->SetVelocity(amtVelocitys);

    if (fParams[2] > 0) {
        animation->SetDynamicsTension(fParams[2]);
    }
    if (fParams[3] > 0) {
        animation->SetDynamicsFriction(fParams[3]);
    }
    if (fParams[4] > 0) {
        animation->SetDynamicsMass(fParams[4]);
    }

    animation->SetBeginTime((AMTTimeInterval) fParams[5]);
    animation->SetRepeatCount(static_cast<AMTInt>(fParams[6]));
    animation->threshold = fParams[7];
    animation->SetRepeatForever(repeat_forever);

    env->ReleaseFloatArrayElements(f_params, fParams, 0);
    env->ReleaseFloatArrayElements(f, fromValues, 0);
    env->ReleaseFloatArrayElements(t, toValues, 0);
    env->ReleaseFloatArrayElements(current_velocity, velocitys, 0);

    free(resultFromBuffer);
    free(resultToBuffer);
    free(amtVelocitys);
}


_CALL(void) _METHOD(nativeAnimatorRelease)(_PARAM) {
    AnimatorEngine::ShareAnimator()->RemoveAllAnimations();
}

_CALL(void) _METHOD(nativePause)(_PARAM, jlong animator_pointer,
                                           jboolean b) {
    animator::Animation *animation = reinterpret_cast< animator::Animation *>(animator_pointer);
    animation->Pause(b);
}