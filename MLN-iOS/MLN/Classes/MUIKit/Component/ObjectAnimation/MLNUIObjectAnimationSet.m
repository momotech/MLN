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
#import "MLNUIBeforeWaitingTask.h"
//#import "MLAValueAnimation+Interactive.h"
#import <ArgoAnimation/MLAValueAnimation+Interactive.h>

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
@property (nonatomic, strong) NSNumber *repeatCount;
@property (nonatomic, strong) NSNumber *repeatForever;
@property (nonatomic, strong) NSNumber *autoReverses;
@property (nonatomic, strong) MLNUIBlock *startBlock;
@property (nonatomic, strong) MLNUIBlock *pauseBlock;
@property (nonatomic, strong) MLNUIBlock *resumeBlock;
@property (nonatomic, strong) MLNUIBlock *repeatBlock;
@property (nonatomic, strong) MLNUIBlock *finishBlock;
@property (nonatomic, assign) MLNUIObjectAnimationSetType runType;
@property (nonatomic, strong) NSArray *animations;
@property (nonatomic, strong) NSMutableArray<MLAValueAnimation *> *rawAnimations;
@property (nonatomic, assign) BOOL propertyChanged;
@property (nonatomic, assign) BOOL animationPaused; // default is NO;

@property (nonatomic, strong) MLNUIBeforeWaitingTask *lazyTask;

@end

@implementation MLNUIObjectAnimationSet

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore
{
    if (self = [super initWithMLNUILuaCore:luaCore]) {
    }
    return self;;
}

- (void)setDelay:(NSNumber *)delay
{
    _delay = delay;
    _propertyChanged = YES;
}

- (void)setRepeatCount:(NSNumber *)repeatCount
{
    _repeatCount = repeatCount;
    _propertyChanged = YES;
}

- (void)setRepeatForever:(NSNumber *)repeatForever
{
    _repeatForever = repeatForever;
    _propertyChanged = YES;
}

- (void)setAutoReverses:(NSNumber *)autoReverses
{
    _autoReverses = autoReverses;
    _propertyChanged = YES;
}

static inline CGFloat MIN_MAX(CGFloat value, CGFloat min, CGFloat max) {
    if (value < min) value = min;
    if (value > max) value = max;
    return value;
}

// progress [0, 1]
- (void)luaui_updateAnimations:(CGFloat)progress {
    switch (self.runType) {
        case MLNUIObjectAnimationSetTypeTogether: {
            for (MLAValueAnimation *anim in self.rawAnimations) {
                [anim updateWithFactor:progress isBegan:NO];
            }
        }
            break;
            
        case MLNUIObjectAnimationSetTypeSequentially: {
            static NSInteger index = 0;
            CGFloat section = 1.0 / self.rawAnimations.count;  // 所有动画平分progress
            CGFloat progressOfEachAnimation = progress - index * section;
            CGFloat validProgress = MIN_MAX(progressOfEachAnimation * self.rawAnimations.count, 0, 1);
            
            MLAValueAnimation *anim = self.rawAnimations[MIN(index, self.rawAnimations.count-1)];
            [anim updateWithFactor:validProgress isBegan:NO];
            
            if (progressOfEachAnimation >= section) { // 当前动画的进度超过其所分配的范围，则表示当前动画执行完毕，需执行下一个动画
                index++;
            }
            if (progressOfEachAnimation <= 0) { // 当前动画的进度为负数，则表示当前动画执行完毕，需执行上一个动画
                index--;
            }
            if (progress >= 1.0) { // 所有动画执行完则index复位
                index = 0;
            }
        }
            break;
            
        default:
            break;
    }
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
            [strongSelf.repeatBlock addObjArgument:animation.bridgeAnimation];
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
        self.valueAnimation.repeatCount = _repeatCount;
    }
    if (_repeatForever != nil) {
        self.valueAnimation.repeatForever = _repeatForever;
    }
    if (_delay != nil) {
        self.valueAnimation.beginTime = _delay;
    }
    if (_autoReverses != nil) {
        _valueAnimation.autoReverses = _autoReverses;
    }
    
    switch (_runType) {
        case MLNUIObjectAnimationSetTypeTogether:
        {
            [self.valueAnimation runTogether:self.rawAnimations];
        }
            break;
        default:
        {
            [self.valueAnimation runSequentially:self.rawAnimations];
        }
            break;
    }
    
    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) pushLazyTask:self.lazyTask];
}

- (void)mlnui_pause {
    self.animationPaused = YES;
    [_valueAnimation pause];
}

- (void)mlnui_resume {
    self.animationPaused = NO;
    [_valueAnimation resume];
}

- (void)mlnui_stop {
    [_valueAnimation finish];
    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) popLazyTask:self.lazyTask];
}

- (void)mlnui_playTogether:(NSArray *)animations
{
    _animations = animations;
    _runType = MLNUIObjectAnimationSetTypeTogether;
    [self flushRawAnimations:animations];
}

- (void)mlnui_playSequentially:(NSArray *)animations
{
    _animations = animations;
    _runType = MLNUIObjectAnimationSetTypeSequentially;
    [self flushRawAnimations:animations];
}

- (MLAMultiAnimation *)valueAnimation
{
    if (!_valueAnimation) {
        if (@available(iOS 9.0, *)) {
            _valueAnimation = [[MLAMultiAnimation alloc] init];
        } else {
            // Fallback on earlier versions
        }
    }
    
    if (self.animationPaused) {
        [_valueAnimation pause];
    }
    //当修改过属性后，需要进行同步
    if (_propertyChanged) {
        if (_repeatCount != nil) {
            _valueAnimation.repeatCount = _repeatCount;
        }
        if (_repeatForever != nil) {
            _valueAnimation.repeatForever = _repeatForever;
        }
        if (_delay != nil) {
            _valueAnimation.beginTime = _delay;
        }
        if (_autoReverses != nil) {
            _valueAnimation.autoReverses = _autoReverses;
        }
        _propertyChanged = NO;
    }
    return _valueAnimation;
}

#pragma mark - private

- (MLNUIBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNUIBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            [sself.valueAnimation start];
        }];
    }
    return _lazyTask;
}

- (NSMutableArray<MLAValueAnimation *> *)rawAnimations {
    if (!_rawAnimations) {
        _rawAnimations = [NSMutableArray array];
    }
    return _rawAnimations;
}

- (void)flushRawAnimations:(NSArray<MLNUIObjectAnimation *> *)objectAnimations {
    if (self.rawAnimations.count) {
        [self.rawAnimations removeAllObjects];
    }
    for (MLNUIObjectAnimation *animation in _animations) {
        [self.rawAnimations addObject:[animation mlnui_rawAnimation]];
    }
}

#pragma mark - Export To Lua
LUAUI_EXPORT_BEGIN(MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(delay, "setDelay:", "delay", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(repeatCount, "setRepeatCount:", "repeatCount", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(repeatForever, "setRepeatForever:", "repeatForever", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(autoReverses, "setAutoReverses:", "autoReverses", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(startBlock, "setStartBlock:", "startBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(pauseBlock, "setPauseBlock:", "pauseBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(resumeBlock, "setResumeBlock:", "resumeBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(repeatBlock, "setRepeatBlock:", "repeatBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_PROPERTY(finishBlock, "setFinishBlock:", "finishBlock", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(together, "mlnui_playTogether:", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(sequentially, "mlnui_playSequentially:", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(start, "mlnui_start:", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(pause, "mlnui_pause", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(resume, "mlnui_resume", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(stop, "mlnui_stop", MLNUIObjectAnimationSet)
LUAUI_EXPORT_METHOD(update, "luaui_updateAnimations:", MLNUIObjectAnimationSet)
LUAUI_EXPORT_END(MLNUIObjectAnimationSet, AnimatorSet, NO, NULL, NULL)

@end
