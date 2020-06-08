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

@interface MLNUIObjectAnimation()

/**
 rawAnimation，懒加载动画对象，Start时确定类型，一旦start过，不可修改
 */
@property (nonatomic, strong) MLAObjectAnimation *valueAnimation;

@property (nonatomic, copy) NSString *propertyType;
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
@property (nonatomic, copy) MLNUIBlock *startBlock;
@property (nonatomic, copy) MLNUIBlock *pauseBlock;
@property (nonatomic, copy) MLNUIBlock *resumeBlock;
@property (nonatomic, copy) MLNUIBlock *repeatBlock;
@property (nonatomic, copy) MLNUIBlock *finishBlock;
@property (nonatomic, assign) BOOL propertyChanged;

@end

@implementation MLNUIObjectAnimation

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore property:(NSString *)propertyType target:(UIView *)target
{
    if (self = [super initWithMLNUILuaCore:luaCore]) {
        _propertyType = propertyType;
        _targetView = target;
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

- (NSString *)mlnui_getProperty
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
                _valueAnimation = (MLAObjectAnimation *)[[MLASpringAnimation alloc] initWithValueName:_propertyType tartget:_targetView];
                [self mlnui_setupConfig:(MLASpringAnimation *)_valueAnimation config:_timingConfig];
            }
                break;
            default:
            {
                _valueAnimation = [[MLAObjectAnimation alloc] initWithValueName:_propertyType tartget:_targetView];
            }
                break;
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
                [strongSelf.repeatBlock addObjArgument:strongSelf];
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
        if (_duration != nil) {
            _valueAnimation.duration = [_duration floatValue];
        }
        if (_repeatCount != nil) {
            _valueAnimation.repeatCount = [_repeatCount floatValue];
        }
        if (_repeatForever != nil) {
            _valueAnimation.repeatForever = [_repeatForever boolValue];
        }
        if (_autoReverses != nil) {
            _valueAnimation.autoReverses = [_autoReverses boolValue];
        }
        if (_fromValue != nil) {
            _valueAnimation.fromValue = _fromValue;
        }
        if (_toValue != nil) {
            _valueAnimation.toValue = _toValue;
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
            default:
                break;
        }
        _propertyChanged = NO;
    }
    return _valueAnimation;
}

#pragma mark - private
- (void)mlnui_setupConfig:(MLASpringAnimation *)springAnimation config:(NSDictionary *)config
{
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
    if (velocity != nil)
    {
        springAnimation.velocity = [self mlnui_getValueWithParams:velocity];
    }
}

/**
 根据动画属性类型去读取可变参数
 */
- (id)mlnui_getValueWithParams:(NSObject *)velocity
{
    if (_propertyType == nil) {
        return nil;
    }
    
    if ([_propertyType isEqualToString:kMUIAnimPropertyAlpha]
        || [_propertyType isEqualToString:kMUIAnimPropertyOriginX]
        || [_propertyType isEqualToString:kMUIAnimPropertyOriginY]
        || [_propertyType isEqualToString:kMUIAnimPropertyCenterX]
        || [_propertyType isEqualToString:kMUIAnimPropertyCenterY]
        || [_propertyType isEqualToString:kMUIAnimPropertyScaleX]
        || [_propertyType isEqualToString:kMUIAnimPropertyScaleY]
        || [_propertyType isEqualToString:kMUIAnimPropertyRotationX]
        || [_propertyType isEqualToString:kMUIAnimPropertyRotationY]
        || [_propertyType isEqualToString:kMUIAnimPropertyRotation])
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
    else if ([_propertyType isEqualToString:kMUIAnimPropertyColor])
    {
        if ([velocity isKindOfClass:[UIColor class]])
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
    else if ([_propertyType isEqualToString:kMUIAnimPropertyOrigin]
               || [_propertyType isEqualToString:kMUIAnimPropertyCenter]
               || [_propertyType isEqualToString:kMUIAnimPropertySize]
               || [_propertyType isEqualToString:kMUIAnimPropertyScale])
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
    else if ([_propertyType isEqualToString:kMUIAnimPropertyFrame])
    {
        NSArray *rect = (NSArray *)velocity;
        if ([rect isKindOfClass:[NSArray class]] && rect.count == 4)
        {
            NSNumber *x = rect[0];
            NSNumber *y = rect[1];
            NSNumber *w = rect[2];
            NSNumber *h = rect[3];
            if ([x isKindOfClass:[NSNumber class]]
                && [y isKindOfClass:[NSNumber class]]
                && [w isKindOfClass:[NSNumber class]]
                && [h isKindOfClass:[NSNumber class]])
            {
                return @(CGRectMake([x floatValue], [y floatValue], [w floatValue], [h floatValue]));
            }
         }
    }
    return nil;
}

#pragma mark - Export To Lua
LUAUI_EXPORT_BEGIN(MLNUIObjectAnimation)
LUAUI_EXPORT_PROPERTY(duration, "setDuration:", "duration", MLNUIObjectAnimation)
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
LUAUI_EXPORT_END(MLNUIObjectAnimation, ObjectAnimation, NO, NULL, "initWithMLNUILuaCore:property:target:")

@end
