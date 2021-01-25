//
//  MLNUIObjectAnimation.m
//  MLN
//
//  Created by MOMO on 2020/6/8.
//

#import "MLNUIObjectAnimation.h"
#import "MLNUIKitHeader.h"
#import "NSObject+MLNUICore.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIAnimationConst.h"
#import "MLNUIBeforeWaitingTask.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIInteractiveBehavior.h"
#import "MLNUILabel.h"
#import <ArgoAnimation/ArgoAnimation.h>

@interface MLNUIObjectAnimation()

/**
 rawAnimation，懒加载动画对象，Start时确定类型，一旦start过，不可修改
 */
@property (nonatomic, strong) MLAObjectAnimation *valueAnimation;
@property (nonatomic, assign) MLNUIAnimationPropertyType propertyType;
@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, assign) MLNUIAnimationTimingFunction timingFunction;
@property (nonatomic, strong) NSDictionary *timingConfig;
//赋值给valueAnimation
@property (nonatomic, strong) id fromValue;
@property (nonatomic, strong) id toValue;
//来自函数传参
@property (nonatomic, strong) NSArray *from;
//来自函数传参
@property (nonatomic, strong) NSArray *to;
@property (nonatomic, strong) NSNumber *delay;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSNumber *repeatCount;
@property (nonatomic, strong) NSNumber *repeatForever;
@property (nonatomic, strong) NSNumber *autoReverses;
@property (nonatomic, strong) MLNUIBlock *startBlock;
@property (nonatomic, strong) MLNUIBlock *pauseBlock;
@property (nonatomic, strong) MLNUIBlock *resumeBlock;
@property (nonatomic, strong) MLNUIBlock *repeatBlock;
@property (nonatomic, strong) MLNUIBlock *finishBlock;
@property (nonatomic, assign) BOOL propertyChanged;

@property (nonatomic, strong) MLNUIBeforeWaitingTask *lazyTask;

@property (nonatomic, assign) CGFloat defaultAlpha;
@property (nonatomic, assign) CGPoint defaultOrigin;
@property (nonatomic, assign) BOOL animationPaused; // default is NO

@end

@implementation MLNUIObjectAnimation

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore property:(MLNUIAnimationPropertyType)propertyType target:(UIView *)target
{
    if (self = [super initWithMLNUILuaCore:luaCore]) {
        _propertyType = propertyType;
        _targetView = target;
        _defaultAlpha = -1;
    }
    return self;
}

#pragma mark - Bridge

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

- (void)setDuration:(NSNumber *)duration
{
    _duration = duration;
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

- (MLNUIAnimationPropertyType)mlnui_getProperty
{
    return _propertyType;
}

- (UIView *)mlnui_getTarget
{
    return _targetView;
}

- (void)mlnui_timing:(MLNUIAnimationTimingFunction)timingFunction timingConfig:(NSDictionary *)timingConfig
{
    _timingFunction = timingFunction;
    _timingConfig = timingConfig;
    _propertyChanged = YES;
}

- (void)mlnui_start:(MLNUIBlock *)finishBlcok
{
    if (finishBlcok != nil) {
        _finishBlock = finishBlcok;
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

- (void)mlnui_setFrom:(NSObject *)value1 value2:(NSObject *)value2 value3:(NSObject *)value3 value4:(NSObject *)value4
{
    NSMutableArray *fromArray = [NSMutableArray array];
    if (value1 != nil) {
        [fromArray addObject:value1];
    }
    if (value2 != nil) {
        [fromArray addObject:value2];
    }
    if (value3 != nil) {
        [fromArray addObject:value3];
    }
    if (value4 != nil) {
        [fromArray addObject:value4];
    }
    _from = [fromArray copy];
    _fromValue = [self mlnui_getValueWithParams:_from];
    _propertyChanged = YES;
}

- (void)mlnui_setTo:(NSObject *)value1 value2:(NSObject *)value2 value3:(NSObject *)value3 value4:(NSObject *)value4
{
    NSMutableArray *fromArray = [NSMutableArray array];
    if (value1 != nil) {
        [fromArray addObject:value1];
    }
    if (value2 != nil) {
        [fromArray addObject:value2];
    }
    if (value3 != nil) {
        [fromArray addObject:value3];
    }
    if (value4 != nil) {
        [fromArray addObject:value4];
    }
    _to = [fromArray copy];
    _toValue = [self mlnui_getValueWithParams:_to];
    _propertyChanged = YES;
}

// progress [0, 1]
- (void)luaui_updateAnimation:(CGFloat)progress {
    [self.mlnui_rawAnimation updateWithFactor:progress isBegan:NO];
}

#pragma mark -

- (MLAValueAnimation *)mlnui_rawAnimation
{
    return self.valueAnimation;
}

- (MLAValueAnimation *)valueAnimation
{
    if (!_valueAnimation) {
        switch (_timingFunction) {
            case MLNUIAnimationTimingFunctionSpring:
            {
                _valueAnimation = (MLAObjectAnimation *)[[MLASpringAnimation alloc] initWithValueName:[self propertyTypeStringValue] tartget:_targetView];
            }
                break;
            default:
            {
                _valueAnimation = [[MLAObjectAnimation alloc] initWithValueName:[self propertyTypeStringValue] tartget:_targetView];
            }
                break;
        }
        _valueAnimation.bridgeAnimation = self;
        
        if (self.animationPaused) {
            [_valueAnimation pause];
        }
        
        __weak typeof(self) weakSelf = self;
        _valueAnimation.startBlock = ^(MLAAnimation *animation) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.startBlock) {
                [strongSelf.startBlock addObjArgument:strongSelf];
                [strongSelf.startBlock callIfCan];
            }
        };
        
        _valueAnimation.pauseBlock = ^(MLAAnimation *animation) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.pauseBlock) {
                [strongSelf.pauseBlock addObjArgument:strongSelf];
                [strongSelf.pauseBlock callIfCan];
            }
        };
        
        _valueAnimation.resumeBlock = ^(MLAAnimation *animation) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.resumeBlock) {
                [strongSelf.resumeBlock addObjArgument:strongSelf];
                [strongSelf.resumeBlock callIfCan];
            }
        };
        
        _valueAnimation.repeatBlock = ^(MLAAnimation *animation, NSUInteger count) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.repeatBlock) {
                [strongSelf.repeatBlock addObjArgument:animation.bridgeAnimation];
                [strongSelf.repeatBlock addUIntegerArgument:count];
                [strongSelf.repeatBlock callIfCan];
            }
        };
        
        _valueAnimation.finishBlock = ^(MLAAnimation *animation, BOOL finish) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.finishBlock) {
                [strongSelf.finishBlock addObjArgument:strongSelf];
                [strongSelf.finishBlock addBOOLArgument:finish];
                [strongSelf.finishBlock callIfCan];
            }
        };
    }
    //当修改过属性后，需要进行同步
    if (_propertyChanged) {
        if (_duration != nil && _timingFunction != MLNUIAnimationTimingFunctionSpring) {
            _valueAnimation.duration = [_duration floatValue];
        }
        if (_repeatCount != nil) {
            _valueAnimation.repeatCount = _repeatCount;
        }
        if (_repeatForever != nil) {
            _valueAnimation.repeatForever = _repeatForever;
        }
        if (_autoReverses != nil) {
            _valueAnimation.autoReverses = _autoReverses;
        }
        if (_fromValue != nil) {
            _valueAnimation.fromValue = _fromValue;
        }
        if (_toValue != nil) {
            _valueAnimation.toValue = _toValue;
        }
        if (_delay != nil) {
            _valueAnimation.beginTime = _delay;
        }
        switch (_timingFunction) {
            case MLNUIAnimationTimingFunctionDefault:
                _valueAnimation.timingFunction = MLATimingFunctionDefault;
                break;
            case MLNUIAnimationTimingFunctionLinear:
                _valueAnimation.timingFunction = MLATimingFunctionLinear;
                break;
            case MLNUIAnimationTimingFunctionEaseIn:
                _valueAnimation.timingFunction = MLATimingFunctionEaseIn;
                break;
            case MLNUIAnimationTimingFunctionEaseOut:
                _valueAnimation.timingFunction = MLATimingFunctionEaseOut;
                break;
            case MLNUIAnimationTimingFunctionEaseInEaseOut:
                _valueAnimation.timingFunction = MLATimingFunctionEaseInEaseOut;
                break;
            case MLNUIAnimationTimingFunctionSpring:
            {
                [self mlnui_setupConfig:(MLASpringAnimation *)_valueAnimation config:_timingConfig];
            }
                break;
            default:
                _valueAnimation.timingFunction = MLATimingFunctionDefault;
                break;
        }
        _propertyChanged = NO;
    }
//    if (_valueAnimation.fromValue == nil) {
//        _valueAnimation.fromValue = [self mlnui_getDefaultValue];
//    }
//    if (_valueAnimation.toValue == nil) {
//        _valueAnimation.toValue = [self mlnui_getDefaultValue];
//    }
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

- (void)mlnui_setupConfig:(MLASpringAnimation *)springAnimation config:(NSDictionary *)config
{
    springAnimation.velocity = @(1.0);
    if (config == nil) {
        return;
    }
    
    NSNumber *bounciness = [config objectForKey:kMUITimingConfigBounciness];
    if (bounciness != nil)
    {
        springAnimation.springBounciness = [bounciness floatValue];
    }
    
    NSNumber *speed = [config objectForKey:kMUITimingConfigSpeed];
    if (speed != nil)
    {
        springAnimation.springSpeed = [speed floatValue];
    }
    
    NSNumber *tension = [config objectForKey:kMUITimingConfigTension];
    if (tension != nil)
    {
        springAnimation.dynamicsTension = [tension floatValue];
    }
    
    NSNumber *friction = [config objectForKey:kMUITimingConfigFriction];
    if (friction != nil)
    {
        springAnimation.dynamicsFriction = [friction floatValue];
    }
    
    NSNumber *mass = [config objectForKey:kMUITimingConfigMass];
    if (mass != nil)
    {
        springAnimation.dynamicsMass = [mass floatValue];
    }
    
    NSObject *velocity = [config objectForKey:kMUITimingConfigVelocity];
    if ([velocity isKindOfClass:[NSArray class]]) { // 最多只有两个值
        NSArray *array = (NSArray *)velocity;
        if (array.count == 1) {
            springAnimation.velocity = array[0];
        } else if (array.count == 2) {
            springAnimation.velocity = @((CGPoint){[array[0] floatValue], [array[1] floatValue]});
        }
    }
}

- (id)mlnui_getDefaultValue
{
    if (CGPointEqualToPoint(CGPointZero, _defaultOrigin)) {
        _defaultOrigin = self.targetView.akAnimationFrame.origin;
    }
    if (_defaultAlpha <= 0) {
        _defaultAlpha = self.targetView.alpha;
    }
    switch (_propertyType) {
        case MLNUIAnimationPropertyTypeAlpha:
            return @(_defaultAlpha);
        case MLNUIAnimationPropertyTypePositionX:
            return @(_defaultOrigin.x);
        case MLNUIAnimationPropertyTypePositionY:
            return @(_defaultOrigin.y);
        case MLNUIAnimationPropertyTypeScaleX:
            return @(1.0);
        case MLNUIAnimationPropertyTypeScaleY:
            return @(1.0);
        case MLNUIAnimationPropertyTypeRotation:
            return @(0);
        case MLNUIAnimationPropertyTypeRotationX:
            return @(0);
        case MLNUIAnimationPropertyTypeRotationY:
            return @(0);
        case MLNUIAnimationPropertyTypeColor:
            return self.targetView.backgroundColor;
        case MLNUIAnimationPropertyTypePosition: {
            return [NSValue valueWithCGPoint:_targetView.akLayoutFrame.origin];
        }
        case MLNUIAnimationPropertyTypeScale:
            return @(CGPointMake(1.0, 1.0));
        case MLNUIAnimationPropertyTypeContentOffset:
            return @(CGPointMake(0.0, 0.0));
        case MLNUIAnimationPropertyTypeTextColor:
            return [UIColor whiteColor];
        default:
            break;
    }
    return nil;
}

/**
 根据动画属性类型去读取可变参数
 */
- (id)mlnui_getValueWithParams:(NSObject *)velocity
{
    switch (_propertyType) {
        case MLNUIAnimationPropertyTypeAlpha:
        case MLNUIAnimationPropertyTypePositionX:
        case MLNUIAnimationPropertyTypePositionY:
        case MLNUIAnimationPropertyTypeScaleX:
        case MLNUIAnimationPropertyTypeScaleY:
        {
            if ([velocity isKindOfClass:[NSNumber class]])
            {
                return velocity;
            }
            else if ([velocity isKindOfClass:[NSArray class]])
            {
                NSArray *value = (NSArray *)velocity;
                if (value.count == 1) {
                    return value[0];
                }
            }
        }
        break;
            
        case MLNUIAnimationPropertyTypeRotation:
        case MLNUIAnimationPropertyTypeRotationX:
        case MLNUIAnimationPropertyTypeRotationY:
        {
            CGFloat angle = 0;
            
            if ([velocity isKindOfClass:[NSNumber class]])
            {
                angle = [(NSNumber *)velocity floatValue];
            }
            else if ([velocity isKindOfClass:[NSArray class]])
            {
                NSArray *value = (NSArray *)velocity;
                if (value != nil && value.count == 1 && [value[0] isKindOfClass:[NSNumber class]]) {
                    angle = [(NSNumber *)value[0] floatValue];
                }
            }
            return @(angle / 360.0 * M_PI * 2);
        }
            break;
        case MLNUIAnimationPropertyTypeTextColor:
        case MLNUIAnimationPropertyTypeColor: {
            if ([velocity isKindOfClass:[UIColor class]]) {
                return velocity;
            }
            if ([velocity isKindOfClass:[NSArray class]]) {
                NSArray *value = (NSArray *)velocity;
                if (value.count == 3) {
                    return [UIColor colorWithRed:[value[0] floatValue]/255.0 green:[value[1] floatValue]/255.0 blue:[value[2] floatValue]/255.0 alpha:1.0];
                }
                if (value.count == 4) {
                    return [UIColor colorWithRed:[value[0] floatValue]/255.0 green:[value[1] floatValue]/255.0 blue:[value[2] floatValue]/255.0 alpha:[value[3] floatValue]];
                }
            }
        }
            break;
        case MLNUIAnimationPropertyTypePosition:
        case MLNUIAnimationPropertyTypeScale:
        case MLNUIAnimationPropertyTypeContentOffset:
        {
            NSArray *point = (NSArray *)velocity;
            if ([point isKindOfClass:[NSArray class]] && point.count == 2)
            {
                NSNumber *x = point[0];
                NSNumber *y = point[1];
                if ([x isKindOfClass:[NSNumber class]] && [y isKindOfClass:[NSNumber class]]) {
                    return @(CGPointMake([x floatValue], [y floatValue]));
                }
            }
        }
            break;

        default:
            break;
    }
    return nil;
}

- (NSString *)propertyTypeStringValue
{
    switch (_propertyType) {
        case MLNUIAnimationPropertyTypeAlpha:
            return kMLAViewAlpha;
            break;
        case MLNUIAnimationPropertyTypeColor:
            return kMLAViewColor;
            break;
        case MLNUIAnimationPropertyTypePosition:
            return kMLAViewPosition;
            break;
        case MLNUIAnimationPropertyTypePositionX:
            return kMLAViewPositionX;
            break;
        case MLNUIAnimationPropertyTypePositionY:
            return kMLAViewPositionY;
            break;
        case MLNUIAnimationPropertyTypeScale:
            return kMLAViewScale;
            break;
        case MLNUIAnimationPropertyTypeScaleX:
            return kMLAViewScaleX;
            break;
        case MLNUIAnimationPropertyTypeScaleY:
            return kMLAViewScaleY;
            break;
        case MLNUIAnimationPropertyTypeRotation:
            return kMLAViewRotation;
            break;
        case MLNUIAnimationPropertyTypeRotationX:
            return kMLAViewRotationX;
            break;
        case MLNUIAnimationPropertyTypeRotationY:
            return kMLAViewRotationY;
            break;
        case MLNUIAnimationPropertyTypeContentOffset: {
            UIScrollView *contentView = (UIScrollView *)_targetView.mlnui_contentView;
            if (!contentView || ![contentView isKindOfClass:[UIScrollView class]]) {
                MLNUIKitLuaAssert(NO, @"The ContentOffset animation type is only valid for ScrollView、TableView、ViewPager and CollectionView.");
            }
            return kMLAViewContentOffset;
        }
        case MLNUIAnimationPropertyTypeTextColor: {
            if (![_targetView isKindOfClass:[MLNUILabel class]]) {
                MLNUIKitLuaAssert(NO, @"The TextColor animation type is only valid for Label.");
            }
            return kMLAViewTextColor;
        }
        default:
            break;
    }
    return kMLAViewAlpha;
}

- (void)mlnui_AddInteractiveBehavior:(MLNUIInteractiveBehavior *)behavior {
    if (!behavior) return;
    [self.valueAnimation addInteractiveBehavior:behavior];
}

#pragma mark - Export To Lua
LUAUI_EXPORT_BEGIN(MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(duration, "setDuration:", "duration", MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(delay, "setDelay:", "delay", MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(repeatCount, "setRepeatCount:", "repeatCount", MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(repeatForever, "setRepeatForever:", "repeatForever", MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(autoReverses, "setAutoReverses:", "autoReverses", MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(startBlock, "setStartBlock:", "startBlock", MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(pauseBlock, "setPauseBlock:", "pauseBlock", MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(resumeBlock, "setResumeBlock:", "resumeBlock", MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(repeatBlock, "setRepeatBlock:", "repeatBlock", MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(finishBlock, "setFinishBlock:", "finishBlock", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(from, "mlnui_setFrom:value2:value3:value4:", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(to, "mlnui_setTo:value2:value3:value4:", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(timing, "mlnui_timing:timingConfig:", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(property, "mlnui_getProperty", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(target, "mlnui_getTarget", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(start, "mlnui_start:", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(pause, "mlnui_pause", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(resume, "mlnui_resume", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(stop, "mlnui_stop", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(update, "luaui_updateAnimation:", MLNUIObjectAnimation)
LUAUI_EXPORT_METHOD(addInteractiveBehavior, "mlnui_AddInteractiveBehavior:", MLNUIObjectAnimation)
LUAUI_EXPORT_END(MLNUIObjectAnimation, ObjectAnimation, NO, NULL, "initWithMLNUILuaCore:property:target:")

@end
