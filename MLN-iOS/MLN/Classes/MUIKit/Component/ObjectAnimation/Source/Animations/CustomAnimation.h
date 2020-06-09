//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#ifndef ANIMATION_CUSTOMANIMATION_H
#define ANIMATION_CUSTOMANIMATION_H

#include "Defines.h"
#include "Animation.h"

ANIMATOR_NAMESPACE_BEGIN

class CustomAnimation;
typedef std::function<AMTBool (const AMTString&, const CustomAnimation&)> CustomAnimationTickCallback;

class CustomAnimation : public Animation {
public:
    explicit CustomAnimation(const AMTString &strName);

    CustomAnimation(const AMTString &strName, void *data);

    const CustomAnimation& OnSetp(CustomAnimationTickCallback callback);

    /**
     * 设置用户自定义绑定数据指针
     * @param data 数据指针
     */
    void SetUserData(void *data);

    /**
     * 获取用户绑定数据
     * @return 用户设置data数据
     */
    ANIMATOR_INLINE const void* GetUserData() {
        return userData;
    };

    static const char* ANIMATION_TYPENAME;ANIMATION_TYPE_DEF(ANIMATION_TYPENAME)

protected:
    /**
     * 覆写父类方法，实现属性动画的Tick
     * @param time 当前时间
     * @param timeInterval 和上次loop的时间间隔
     * @param timeProcess 和动画开始的时间间隔
     */
    void Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) override;

public:
    // 当前获取的系统时间
    AMTTimeInterval currentTime;

    // 上次回调到当前回调经过的时间
    AMTTimeInterval elapsedTime;

private:
    // 动画Tick回调
    CustomAnimationTickCallback tickCallback;

    // 用户自定义数据
    void* userData;
};

ANIMATOR_NAMESPACE_END


#endif //ANIMATION_CUSTOMANIMATION_H
