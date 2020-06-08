//
//  MLNUIObjectAnimationSet.m
//  MLN
//
//  Created by MOMO on 2020/6/8.
//

#import "MLNUIObjectAnimationSet.h"
#import "MLNUIKitHeader.h"
#import "NSObject+MLNUICore.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIAnimationConst.h"
#import "MLNUIObjectAnimation.h"

typedef NS_ENUM(NSUInteger, MLNUIObjectAnimationSetType) {
    MLNUIObjectAnimationSetTypeTogether,
    MLNUIObjectAnimationSetTypeSequentially
};

@interface MLNUIObjectAnimationSet()
/**
 rawAnimation，懒加载动画对象，Start时确定类型，一旦start过，不可修改
 */
@property (nonatomic, strong) MLAMultiAnimation *valueAnimation;

@property (nonatomic, strong) NSNumber *delay;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSNumber *repeatCount;
@property (nonatomic, strong) NSNumber *repeatForever;
@property (nonatomic, strong) NSNumber *autoReverses;
@property (nonatomic, copy) MLNUIBlock *startBlock;
@property (nonatomic, copy) MLNUIBlock *pauseBlock;
@property (nonatomic, copy) MLNUIBlock *resumeBlock;
@property (nonatomic, copy) MLNUIBlock *repeatBlock;
@property (nonatomic, copy) MLNUIBlock *finishBlock;
@property (nonatomic, assign) MLNUIObjectAnimationSetType runType;
@property (nonatomic, strong) NSArray *animations;

@end

@implementation MLNUIObjectAnimationSet

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore
{
    if (self = [super initWithMLNUILuaCore:luaCore]) {
    }
    return self;;
}

- (void)mlnui_start:(MLNUIBlock *)finishBlcok
{
    if (finishBlcok != nil) {
        _finishBlock = finishBlcok;
    }
    
    __weak typeof(self) weakSelf = self;
    self.valueAnimation.startBlock = ^(MLAAnimation *animation) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.startBlock) {
            [strongSelf.startBlock addObjArgument:strongSelf];
            [strongSelf.startBlock callIfCan];
        }
    };
    
    self.valueAnimation.pauseBlock = ^(MLAAnimation *animation) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.pauseBlock) {
            [strongSelf.pauseBlock addObjArgument:strongSelf];
            [strongSelf.pauseBlock callIfCan];
        }
    };
    
    self.valueAnimation.resumeBlock = ^(MLAAnimation *animation) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.resumeBlock) {
            [strongSelf.resumeBlock addObjArgument:strongSelf];
            [strongSelf.resumeBlock callIfCan];
        }
    };
    
    self.valueAnimation.repeatBlock = ^(MLAAnimation *animation, NSUInteger count) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.repeatBlock) {
            [strongSelf.repeatBlock addObjArgument:strongSelf];
            [strongSelf.repeatBlock addUIntegerArgument:count];
            [strongSelf.repeatBlock callIfCan];
        }
    };
    
    self.valueAnimation.finishBlock = ^(MLAAnimation *animation, BOOL finish) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.finishBlock) {
            [strongSelf.finishBlock addObjArgument:strongSelf];
            [strongSelf.finishBlock addBOOLArgument:finish];
            [strongSelf.finishBlock callIfCan];
        }
    };
    
    if (_repeatCount != nil) {
        self.valueAnimation.repeatCount = [_repeatCount floatValue];
    }
    if (_repeatForever != nil) {
        self.valueAnimation.repeatForever = [_repeatForever boolValue];
    }
    if (_autoReverses != nil) {
        self.valueAnimation.autoReverses = [_autoReverses boolValue];
    }
    
    NSMutableArray *rawAnimations = [NSMutableArray array];
    if (_animations != nil) {
        for (MLNUIObjectAnimation *animation in _animations) {
            [rawAnimations addObject:[animation mlnui_rawAnimation]];
        }
    }
    
    switch (_runType) {
        case MLNUIObjectAnimationSetTypeTogether:
        {
            [self.valueAnimation runTogether:rawAnimations];
        }
            break;
        default:
        {
            [self.valueAnimation runSequentially:rawAnimations];
        }
            break;
    }
    
    [self.valueAnimation start];
    
}

- (void)mlnui_pause {
    [_valueAnimation pause];
}

- (void)mlnui_resume {
    [_valueAnimation resume];
}

- (void)mlnui_stop {
    [_valueAnimation finish];
}

- (void)mlnui_platTogether:(NSArray *)animations
{
    _animations = animations;
    _runType = MLNUIObjectAnimationSetTypeTogether;
}

- (void)mlnui_playSequentially:(NSArray *)animations
{
    _animations = animations;
    _runType = MLNUIObjectAnimationSetTypeSequentially;
}


- (MLAMultiAnimation *)valueAnimation
{
    if (!_valueAnimation) {
        _valueAnimation = [[MLAMultiAnimation alloc] initWithMLNUILuaCore:self.mlnui_luaCore];
    }
    return _valueAnimation;
}

#pragma mark - private


#pragma mark - Export To Lua
LUAUI_EXPORT_BEGIN(MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(duration, "setDuration:", "duration", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(repeatCount, "setRepeatCount:", "repeatCount", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(repeatForever, "setRepeatForever:", "repeatForever", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(autoReverses, "setAutoReverses:", "autoReverses", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(startBlock, "setStartBlock:", "startBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(pauseBlock, "setPauseBlock:", "pauseBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(resumeBlock, "setResumeBlock:", "resumeBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(repeatBlock, "setRepeatBlock:", "repeatBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(finishBlock, "setFinishBlock:", "finishBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(start, "mlnui_start:", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(pause, "mlnui_pause", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(resume, "mlnui_resume", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(stop, "mlnui_stop", MLNUIObjectAnimationSet)
LUAUI_EXPORT_END(MLNUIObjectAnimationSet, AnimationSet, NO, NULL, NULL)

@end
