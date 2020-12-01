//
// Created by momo783 on 2020/5/15.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#ifndef ANIMATION_RUNLOOP_H
#define ANIMATION_RUNLOOP_H

#include "Defines.h"
#include <functional>

ANIMATOR_NAMESPACE_BEGIN

    typedef std::function<void(AMTTimeInterval)> RunLoopCallback;

    class RunLoop {
        RunLoop();

        ~RunLoop();

    public:
        static RunLoop *ShareLoop();

        ANIMATOR_INLINE AMTBool IsRunning() const {
            return running;
        };

        AMTTimeInterval CurrentTime();

        void StartLoop();

        RunLoopCallback LoopCallback;

        void StopLoop();

        static void DestoryShareLoop();

    private:
        AMTBool running;

    };

ANIMATOR_NAMESPACE_END

#endif //ANIMATION_RUNLOOP_H
