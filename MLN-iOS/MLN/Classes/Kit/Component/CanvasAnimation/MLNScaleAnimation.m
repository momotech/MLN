//
//  MLNScaleAnimation.m
//  MLN
//
//  Created by MoMo on 2019/5/13.
//

#import "MLNScaleAnimation.h"
#import "MLNEntityExporterMacro.h"
#import "MLNBlock.h"
#import "NSDictionary+MLNSafety.h"

@interface MLNScaleAnimation()

@property (nonatomic, assign) CGFloat fromX;
@property (nonatomic, assign) CGFloat toX;
@property (nonatomic, assign) CGFloat fromY;
@property (nonatomic, assign) CGFloat toY;

@end

@implementation MLNScaleAnimation

- (instancetype)initWith:(CGFloat)fromX
                     toX:(CGFloat)toX
                   fromY:(CGFloat)fromY
                     toY:(CGFloat)toY
{
    if (self = [super init]) {
        [self setFromX:fromX];
        [self setToX:toX];
        [self setFromY:fromY];
        [self setToY:toY];
    }
    return self;
}

- (instancetype)initWith:(CGFloat)fromX
                     toX:(CGFloat)toX
                   fromY:(CGFloat)fromY
                     toY:(CGFloat)toY
             pivotXValue:(CGFloat)pivotX
             pivotYValue:(CGFloat)pivotY
{
    if (self = [self initWith:fromX toX:toX fromY:fromY toY:toY]) {
        [self setPivotXType:MLNAnimationValueTypeAbsolute];
        [self setPivotX:pivotX];
        [self setPivotYType:MLNAnimationValueTypeAbsolute];
        [self setPivotY:pivotY];
    }
    return self;
}

- (instancetype)initWith:(CGFloat)fromX
                     toX:(CGFloat)toX
                   fromY:(CGFloat)fromY
                     toY:(CGFloat)toY
              pivotXType:(MLNAnimationValueType)pivotXType
             pivotXValue:(CGFloat)pivotX
              pivotYType:(MLNAnimationValueType)pivotYType
             pivotYValue:(CGFloat)pivotY
{
    if (self = [self initWith:fromX toX:toX fromY:fromY toY:toY pivotXValue:pivotX pivotYValue:pivotY]) {
        [self setPivotXType:pivotXType];
        [self setPivotYType:pivotYType];
    }
    return self;
}

static int lua_animation_init(lua_State *L) {
    MLNScaleAnimation *animation = nil;
    NSUInteger argCount = lua_gettop(L);
    switch (argCount) {
        case 8: {
            CGFloat fromX          = lua_tonumber(L, 1);
            CGFloat toX            = lua_tonumber(L, 2);
            CGFloat fromY          = lua_tonumber(L, 3);
            CGFloat toY            = lua_tonumber(L, 4);
            CGFloat pivotXType     = lua_tonumber(L, 5);
            CGFloat pivotX         = lua_tonumber(L, 6);
            CGFloat pivotYType     = lua_tonumber(L, 7);
            CGFloat pivotY         = lua_tonumber(L, 8);
            animation = [[MLNScaleAnimation alloc] initWith:fromX toX:toX fromY:fromY toY:toY pivotXType:pivotXType pivotXValue:pivotX pivotYType:pivotYType pivotYValue:pivotY];
        }
            break;
        case 6: {
            CGFloat fromX          = lua_tonumber(L, 1);
            CGFloat toX            = lua_tonumber(L, 2);
            CGFloat fromY          = lua_tonumber(L, 3);
            CGFloat toY            = lua_tonumber(L, 4);
            CGFloat pivotX         = lua_tonumber(L, 5);
            CGFloat pivotY         = lua_tonumber(L, 6);
            animation = [[MLNScaleAnimation alloc] initWith:fromX toX:toX fromY:fromY toY:toY pivotXValue:pivotX pivotYValue:pivotY];
        }
            break;
        case 4: {
            CGFloat fromX          = lua_tonumber(L, 1);
            CGFloat toX            = lua_tonumber(L, 2);
            CGFloat fromY          = lua_tonumber(L, 3);
            CGFloat toY            = lua_tonumber(L, 4);
            animation = [[MLNScaleAnimation alloc] initWith:fromX toX:toX fromY:fromY toY:toY];
        }
            break;
        case 0:
        {
            animation = [[MLNScaleAnimation alloc] init];
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
    MLNScaleAnimation *copy = [super copyWithZone:zone];
    copy.fromX = _fromX;
    copy.toX = _toX;
    copy.fromY = _fromY;
    copy.toY = _toY;
    return copy;
}

#pragma mark - getter & setter
- (NSString *)animationKey
{
    return kDefaultScaleAnimation;
}

#pragma mark - Export for Lua

- (void)setFromX:(CGFloat)fromX
{
    _fromX = fromX;
    CABasicAnimation *animation = [self animationForKey:kScaleX];
    [animation setFromValue:@(fromX)];
}

- (void)setToX:(CGFloat)toX
{
    _toX = toX;
    CABasicAnimation *animation = [self animationForKey:kScaleX];
    [animation setToValue:@(toX)];
}

- (void)setFromY:(CGFloat)fromY
{
    _fromY = fromY;
    CABasicAnimation *animation = [self animationForKey:kScaleY];
    [animation setFromValue:@(fromY)];
}

- (void)setToY:(CGFloat)toY
{
    _toY = toY;
    CABasicAnimation *animation = [self animationForKey:kScaleY];
    [animation setToValue:@(toY)];
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNScaleAnimation)
LUA_EXPORT_PROPERTY(setFromX, "setFromX:", "fromX", MLNScaleAnimation)
LUA_EXPORT_PROPERTY(setToX, "setToX:", "toX", MLNScaleAnimation)
LUA_EXPORT_PROPERTY(setFromY, "setFromY:", "fromX", MLNScaleAnimation)
LUA_EXPORT_PROPERTY(setToY, "setToY:", "toY", MLNScaleAnimation)
LUA_EXPORT_END_WITH_CFUNC(MLNScaleAnimation, ScaleAnimation, YES, "MLNCanvasAnimation", lua_animation_init)
@end
