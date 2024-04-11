//
//  MLNRotateAnimation.m
//  MLN
//
//  Created by MoMo on 2019/5/14.
//

#import "MLNRotateAnimation.h"
#import "MLNEntityExporterMacro.h"
#import "MLNBlock.h"
#import "NSDictionary+MLNSafety.h"

@interface MLNRotateAnimation()

@property (nonatomic, assign) CGFloat fromDegrees;
@property (nonatomic, assign) CGFloat toDegrees;

@property (nonatomic, assign) CGFloat fromXDegrees;
@property (nonatomic, assign) CGFloat toXDegrees;

@property (nonatomic, assign) CGFloat fromYDegrees;
@property (nonatomic, assign) CGFloat toYDegrees;

@end

@implementation MLNRotateAnimation

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
        [self setPivotXType:MLNAnimationValueTypeAbsolute];
        [self setPivotYType:MLNAnimationValueTypeAbsolute];
        [self setPivotX:pivotX];
        [self setPivotY:pivotY];
    }
    return self;    
}

- (instancetype)initWith:(CGFloat)fromDegress
               toDegress:(CGFloat)toDegress
              pivotXType:(MLNAnimationValueType)pivotXType
                  pivotX:(CGFloat)pivotX
              pivotYType:(MLNAnimationValueType)pivotYType
                  pivotY:(CGFloat)pivotY
{
    if (self = [self initWith:fromDegress toDegress:toDegress pivotX:pivotX pivotY:pivotY]) {
        [self setPivotXType:pivotXType];
        [self setPivotYType:pivotYType];
    }
    return self;
}

static int lua_animation_init(lua_State *L) {
    MLNRotateAnimation *animation = nil;
    NSUInteger argCount = lua_gettop(L);
    switch (argCount) {
        case 6: {
            CGFloat fromDegress          = lua_tonumber(L, 1);
            CGFloat toDegress            = lua_tonumber(L, 2);
            CGFloat pivotXType           = lua_tonumber(L, 3);
            CGFloat pivotX               = lua_tonumber(L, 4);
            CGFloat pivotYType           = lua_tonumber(L, 5);
            CGFloat pivotY               = lua_tonumber(L, 6);
            animation = [[MLNRotateAnimation alloc] initWith:fromDegress toDegress:toDegress pivotXType:pivotXType pivotX:pivotX pivotYType:pivotYType pivotY:pivotY];
        }
            break;
        case 4: {
            CGFloat fromDegress          = lua_tonumber(L, 1);
            CGFloat toDegress            = lua_tonumber(L, 2);
            CGFloat pivotX               = lua_tonumber(L, 3);
            CGFloat pivotY               = lua_tonumber(L, 4);
            animation = [[MLNRotateAnimation alloc] initWith:fromDegress toDegress:toDegress pivotX:pivotX pivotY:pivotY];
        }
            break;
        case 2: {
            CGFloat fromDegress          = lua_tonumber(L, 1);
            CGFloat toDegress            = lua_tonumber(L, 2);
            animation = [[MLNRotateAnimation alloc] initWith:fromDegress toDegress:toDegress];
        }
            break;
        case 0:
        {
            animation = [[MLNRotateAnimation alloc] init];
        }
            break;
        default: {
            mln_lua_error(L, @"number of arguments must be 0 or 4 or 6 or 8!");
            break;
        }
    }
    
    if (animation) {
        if ([MLN_LUA_CORE(L) pushNativeObject:animation error:NULL]) {
            return 1;
        };
    }
    
    return 0;
}

#pragma mark - copy
- (id)copyWithZone:(NSZone *)zone
{
    MLNRotateAnimation *copy = [super copyWithZone:zone];
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
    return kDefaultRotationAnimation;
}

- (void)setFromDegrees:(CGFloat)fromDegrees
{
    _fromDegrees = fromDegrees;
    CABasicAnimation *animation = [self animationForKey:kRotaionZ];
    fromDegrees = fromDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(fromDegrees)];
}

- (void)setToDegrees:(CGFloat)toDegrees
{
    _toDegrees = toDegrees;
    CABasicAnimation *animation = [self animationForKey:kRotaionZ];
    toDegrees = toDegrees / 360.0 * M_PI * 2;
    [animation setToValue:@(toDegrees)];
}

- (void)setFromXDegrees:(CGFloat)fromXDegrees
{
    _fromXDegrees = fromXDegrees;
    CABasicAnimation *animation = [self animationForKey:kRotaionX];
    fromXDegrees = fromXDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(fromXDegrees)];
}

- (void)setToXDegrees:(CGFloat)toXDegrees
{
    _toXDegrees = toXDegrees;
    CABasicAnimation *animation = [self animationForKey:kRotaionX];
    toXDegrees = toXDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(toXDegrees)];
}

- (void)setFromYDegrees:(CGFloat)fromYDegrees
{
    _fromYDegrees  = fromYDegrees;
    CABasicAnimation *animation = [self animationForKey:kRotaionY];
    fromYDegrees = fromYDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(fromYDegrees)];
}

- (void)setToYDegrees:(CGFloat)toYDegrees
{
    _toYDegrees  = toYDegrees;
    CABasicAnimation *animation = [self animationForKey:kRotaionY];
    toYDegrees = toYDegrees / 360.0 * M_PI * 2;
    [animation setFromValue:@(toYDegrees)];
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNRotateAnimation)
LUA_EXPORT_PROPERTY(setFromDegrees, "setFromDegrees:", "fromDegrees", MLNRotateAnimation)
LUA_EXPORT_PROPERTY(setToDegrees, "setToDegrees:", "toDegrees", MLNRotateAnimation)
LUA_EXPORT_PROPERTY(setFromXDegrees, "setFromXDegrees:", "fromXDegrees", MLNRotateAnimation)
LUA_EXPORT_PROPERTY(setToXDegrees, "setToXDegrees:", "toXDegrees", MLNRotateAnimation)
LUA_EXPORT_PROPERTY(setFromYDegrees, "setFromYDegrees:", "fromYDegrees", MLNRotateAnimation)
LUA_EXPORT_PROPERTY(setToYDegrees, "setToYDegrees:", "toYDegrees", MLNRotateAnimation)
LUA_EXPORT_END_WITH_CFUNC(MLNRotateAnimation, RotateAnimation, YES, "MLNCanvasAnimation", lua_animation_init)
@end
