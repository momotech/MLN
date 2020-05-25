//
//  MLNUIRotateAnimation.m
//  MLNUI
//
//  Created by MoMo on 2019/5/14.
//

#import "MLNUIRotateAnimation.h"
#import "MLNUIEntityExporterMacro.h"
#import "MLNUIBlock.h"
#import "NSDictionary+MLNUISafety.h"

@interface MLNUIRotateAnimation()

@property (nonatomic, assign) CGFloat fromDegrees;
@property (nonatomic, assign) CGFloat toDegrees;

@property (nonatomic, assign) CGFloat fromXDegrees;
@property (nonatomic, assign) CGFloat toXDegrees;

@property (nonatomic, assign) CGFloat fromYDegrees;
@property (nonatomic, assign) CGFloat toYDegrees;

@end

@implementation MLNUIRotateAnimation

- (instancetype)initWith:(CGFloat)fromDegress
               toDegress:(CGFloat)toDegress
{
    if (self = [super init]) {
        [self setFromDegrees:fromDegress];
        [self setToDegrees:toDegress];
    }
    return self;
}

- (instancetype)initWith:(CGFloat)fromDegress
               toDegress:(CGFloat)toDegress
                  pivotX:(CGFloat)pivotX
                  pivotY:(CGFloat)pivotY
{
    if (self = [self initWith:fromDegress toDegress:toDegress]) {
        [self setPivotXType:MLNUIAnimationValueTypeAbsolute];
        [self setPivotYType:MLNUIAnimationValueTypeAbsolute];
        [self setPivotX:pivotX];
        [self setPivotY:pivotY];
    }
    return self;    
}

- (instancetype)initWith:(CGFloat)fromDegress
               toDegress:(CGFloat)toDegress
              pivotXType:(MLNUIAnimationValueType)pivotXType
                  pivotX:(CGFloat)pivotX
              pivotYType:(MLNUIAnimationValueType)pivotYType
                  pivotY:(CGFloat)pivotY
{
    if (self = [self initWith:fromDegress toDegress:toDegress pivotX:pivotX pivotY:pivotY]) {
        [self setPivotXType:pivotXType];
        [self setPivotYType:pivotYType];
    }
    return self;
}

static int lua_animation_init(lua_State *L) {
    MLNUIRotateAnimation *animation = nil;
    NSUInteger argCount = lua_gettop(L);
    switch (argCount) {
        case 6: {
            CGFloat fromDegress          = lua_tonumber(L, 1);
            CGFloat toDegress            = lua_tonumber(L, 2);
            CGFloat pivotXType           = lua_tonumber(L, 3);
            CGFloat pivotX               = lua_tonumber(L, 4);
            CGFloat pivotYType           = lua_tonumber(L, 5);
            CGFloat pivotY               = lua_tonumber(L, 6);
            animation = [[MLNUIRotateAnimation alloc] initWith:fromDegress toDegress:toDegress pivotXType:pivotXType pivotX:pivotX pivotYType:pivotYType pivotY:pivotY];
        }
            break;
        case 4: {
            CGFloat fromDegress          = lua_tonumber(L, 1);
            CGFloat toDegress            = lua_tonumber(L, 2);
            CGFloat pivotX               = lua_tonumber(L, 3);
            CGFloat pivotY               = lua_tonumber(L, 4);
            animation = [[MLNUIRotateAnimation alloc] initWith:fromDegress toDegress:toDegress pivotX:pivotX pivotY:pivotY];
        }
            break;
        case 2: {
            CGFloat fromDegress          = lua_tonumber(L, 1);
            CGFloat toDegress            = lua_tonumber(L, 2);
            animation = [[MLNUIRotateAnimation alloc] initWith:fromDegress toDegress:toDegress];
        }
            break;
        case 0:
        {
            animation = [[MLNUIRotateAnimation alloc] init];
        }
            break;
        default: {
            mln_lua_error(L, @"number of arguments must be 0 or 4 or 6 or 8!");
            break;
        }
    }
    
    if (animation) {
        if ([MLNUI_LUA_CORE(L) pushNativeObject:animation error:NULL]) {
            return 1;
        };
    }
    
    return 0;
}

#pragma mark - copy
- (id)copyWithZone:(NSZone *)zone
{
    MLNUIRotateAnimation *copy = [super copyWithZone:zone];
    copy.fromDegrees = _fromDegrees;
    copy.toDegrees = _toDegrees;
    copy.fromXDegrees = _fromXDegrees;
    copy.toXDegrees = _toXDegrees;
    copy.fromYDegrees = _fromYDegrees;
    copy.toYDegrees = _toYDegrees;
    return copy;
}

#pragma mark - getter & setter
- (NSString *)animationKey
{
    return kMUIDefaultRotationAnimation;
}

- (void)setFromDegrees:(CGFloat)fromDegrees
{
    _fromDegrees = fromDegrees;
    CABasicAnimation *animation = [self animationForKey:kMUIRotaionZ];
    fromDegrees = fromDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(fromDegrees)];
}

- (void)setToDegrees:(CGFloat)toDegrees
{
    _toDegrees = toDegrees;
    CABasicAnimation *animation = [self animationForKey:kMUIRotaionZ];
    toDegrees = toDegrees / 360.0 * M_PI * 2;
    [animation setToValue:@(toDegrees)];
}

- (void)setFromXDegrees:(CGFloat)fromXDegrees
{
    _fromXDegrees = fromXDegrees;
    CABasicAnimation *animation = [self animationForKey:kMUIRotaionX];
    fromXDegrees = fromXDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(fromXDegrees)];
}

- (void)setToXDegrees:(CGFloat)toXDegrees
{
    _toXDegrees = toXDegrees;
    CABasicAnimation *animation = [self animationForKey:kMUIRotaionX];
    toXDegrees = toXDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(toXDegrees)];
}

- (void)setFromYDegrees:(CGFloat)fromYDegrees
{
    _fromYDegrees  = fromYDegrees;
    CABasicAnimation *animation = [self animationForKey:kMUIRotaionY];
    fromYDegrees = fromYDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(fromYDegrees)];
}

- (void)setToYDegrees:(CGFloat)toYDegrees
{
    _toYDegrees  = toYDegrees;
    CABasicAnimation *animation = [self animationForKey:kMUIRotaionY];
    toYDegrees = toYDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(toYDegrees)];
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNUIRotateAnimation)
LUA_EXPORT_PROPERTY(setFromDegrees, "setFromDegrees:", "fromDegrees", MLNUIRotateAnimation)
LUA_EXPORT_PROPERTY(setToDegrees, "setToDegrees:", "toDegrees", MLNUIRotateAnimation)
LUA_EXPORT_PROPERTY(setFromXDegrees, "setFromXDegrees:", "fromXDegrees", MLNUIRotateAnimation)
LUA_EXPORT_PROPERTY(setToXDegrees, "setToXDegrees:", "toXDegrees", MLNUIRotateAnimation)
LUA_EXPORT_PROPERTY(setFromYDegrees, "setFromYDegrees:", "fromYDegrees", MLNUIRotateAnimation)
LUA_EXPORT_PROPERTY(setToYDegrees, "setToYDegrees:", "toYDegrees", MLNUIRotateAnimation)
LUA_EXPORT_END_WITH_CFUNC(MLNUIRotateAnimation, RotateAnimation, YES, "MLNUICanvasAnimation", lua_animation_init)
@end
