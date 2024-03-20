//
// Created by momo783 on 2020/5/15.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include "RunLoop.h"

ANIMATOR_NAMESPACE_BEGIN

static RunLoop* shareLoop = nullptr;

RunLoop::RunLoop()
: running(false),
  LoopCallback(nullptr) {

}

RunLoop::~RunLoop() {

}

RunLoop *RunLoop::ShareLoop() {
    if (shareLoop == nullptr) {
        shareLoop = new RunLoop();
    }
    return shareLoop;
}

ANIMATOR_NAMESPACE_END
