//
// Created by momo783 on 2020/5/22.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#ifndef MLANIMATOR_MULTIANIMATION_H
#define MLANIMATOR_MULTIANIMATION_H

#include "Defines.h"
#include "Animation.h"
#include <vector>

ANIMATOR_NAMESPACE_BEGIN

typedef std::vector<Animation*> MultiAnimationList;

class MultiAnimation : public Animation {
public:
    enum RunningType {
        Together,
        Sequentially
    };
public:
    explicit MultiAnimation(const AMTString &strName);

    ~MultiAnimation() override;

    void RunTogether(MultiAnimationList list);

    void RunSequentially(MultiAnimationList list);

    ANIMATOR_INLINE const MultiAnimationList& GetRunningAnimationList() const {
        return runningAnimationList;
    }

    void Pause(AMTBool pause) override;

    void SetRepeatForever(AMTBool forever) override;

    void SetRepeatCount(AMTInt count) override;

    void SetAutoreverses(AMTBool reverse) override;

    void SetBeginTime(AMTTimeInterval beginTime) override;

    static const char* ANIMATION_TYPENAME;ANIMATION_TYPE_DEF(ANIMATION_TYPENAME);

protected:
    void Reset() override;

    void RepeatReset() override;

    void Start(AMTTimeInterval time) override;

    void Repeat() override;

    void Stop() override;

    void Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) override;

    void ResetSubAnimation();

    void StartAddRunningAnimation(AMTTimeInterval time);

private:
    // 动画组合列表
    MultiAnimationList animationList;

    // 执行类型
    RunningType runningType;

    // 正在执行的东湖列表
    MultiAnimationList runningAnimationList;

    // 完成的动画组合列表
    MultiAnimationList finishAnimationList;

    AMTBool didSetAutoReverse;
    AMTBool didSetRepeatCount;
    AMTBool didSetRepeatForever;
    AMTBool didSetBeginTime;

    void ClearSubAnimationSettingsIfNeeded();

};

ANIMATOR_NAMESPACE_END


#endif //MLANIMATOR_MULTIANIMATION_H
