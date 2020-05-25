//
//  MLNUITranslateAnimation.m
//  MLNUI
//
//  Created by MoMo on 2019/5/16.
//

#import "MLNUITranslateAnimation.h"
#import "MLNUIEntityExporterMacro.h"
#import "MLNUIBlock.h"
#import "NSDictionary+MLNUISafety.h"

@interface MLNUITranslateAnimation()

@property (nonatomic, assign) MLNUIAnimationValueType fromXType;
@property (nonatomic, assign) CGFloat fromX;
@property (nonatomic, assign) MLNUIAnimationValueType toXType;
@property (nonatomic, assign) CGFloat toX;

@property (nonatomic, assign) MLNUIAnimationValueType fromYType;
@property (nonatomic, assign) CGFloat fromY;
@property (nonatomic, assign) MLNUIAnimationValueType toYType;
@property (nonatomic, assign) CGFloat toY;

@end

@implementation MLNUITranslateAnimation

- (instancetype)initWith:(CGFloat)fromX
                     toX:(CGFloat)toX
                   fromY:(CGFloat)fromY
                     toY:(CGFloat)toY
{
    if (self = [super init]) {
        [self setFromXType:MLNUIAnimationValueTypeAbsolute];
        [self setFromX:fromX];
        [self setToXType:MLNUIAnimationValueTypeAbsolute];
        [self setToX:toX];
        [self setFromYType:MLNUIAnimationValueTypeAbsolute];
        [self setFromY:fromY];
        [self setToYType:MLNUIAnimationValueTypeAbsolute];
        [self setToY:toY];
    }
    return self;
}

- (instancetype)initWith:(MLNUIAnimationValueType)fromXType
                   fromX:(CGFloat)fromX
                 toXType:(MLNUIAnimationValueType)toXType
                     toX:(CGFloat)toX
               fromYType:(MLNUIAnimationValueType)fromYType
                   fromY:(CGFloat)fromY
                 toYType:(MLNUIAnimationValueType)toYType
                     toY:(CGFloat)toY
{
    if (self = [self initWith:fromX toX:toX fromY:fromY toY:toY]) {
        [self setFromXType:fromXType];
        [self setToXType:toXType];
        [self setFromYType:fromYType];
        [self setToYType:toYType];
    }
    return self;
}


static int lua_animation_init(lua_State *L) {
    MLNUITranslateAnimation *animation = nil;
    NSUInteger argCount = lua_gettop(L);
    switch (argCount) {
        case 8: {
            CGFloat fromXType          = lua_tonumber(L, 1);
            CGFloat fromX              = lua_tonumber(L, 2);
            CGFloat toXType            = lua_tonumber(L, 3);
            CGFloat toX                = lua_tonumber(L, 4);
            CGFloat fromYType          = lua_tonumber(L, 5);
            CGFloat fromY              = lua_tonumber(L, 6);
            CGFloat toYType            = lua_tonumber(L, 7);
            CGFloat toY                = lua_tonumber(L, 8);
            animation = [[MLNUITranslateAnimation alloc] initWith:fromXType fromX:fromX toXType:toXType toX:toX fromYType:fromYType fromY:fromY toYType:toYType toY:toY];
        }
            break;
        case 4: {
            CGFloat fromX             = lua_tonumber(L, 1);
            CGFloat toX               = lua_tonumber(L, 2);
            CGFloat fromY             = lua_tonumber(L, 3);
            CGFloat toY               = lua_tonumber(L, 4);
            animation = [[MLNUITranslateAnimation alloc] initWith:fromX toX:toX fromY:fromY toY:toY];
        }
            break;
        case 0:
        {
            animation = [[MLNUITranslateAnimation alloc] init];
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

- (void)startWithView:(UIView *)targetView
{
    [self resetRelativeValuesWithTargetView:targetView];
    [super startWithView:targetView];
}

- (void)resetRelativeValuesWithTargetView:(UIView *)targetView
{
    CABasicAnimation *xAnimation = [self animationForKey:kMUITranslationX];
    CGFloat fromX = [self relativeValue:YES targetView:targetView relativeType:_fromXType value:_fromX];
    xAnimation.fromValue = @(fromX);
    CGFloat toX = [self relativeValue:YES targetView:targetView relativeType:_toXType value:_toX];
    xAnimation.toValue = @(toX);
    
    CABasicAnimation *yAnimation = [self animationForKey:kMUITranslationY];
    CGFloat fromY = [self relativeValue:YES targetView:targetView relativeType:_fromYType value:_fromY];
    yAnimation.fromValue = @(fromY);
    CGFloat toY = [self relativeValue:YES targetView:targetView relativeType:_toYType value:_toY];
    yAnimation.toValue = @(toY);
}

#pragma mark - copy
- (id)copyWithZone:(NSZone *)zone
{
    MLNUITranslateAnimation *copy = [super copyWithZone:zone];
    copy.fromX = _fromX;
    copy.fromXType = _fromXType;
    copy.toX   = _toX;
    copy.toXType = _toXType;
    copy.fromY = _fromY;
    copy.fromYType = _fromYType;
    copy.toY = _toY;
    copy.toYType = _toYType;
    return copy;
}

#pragma mark - getter & setter
- (CGFloat)relativeValue:(BOOL)xAxis
              targetView:(UIView *)targetView
            relativeType:(MLNUIAnimationValueType)rType
                   value:(CGFloat)value
{
    if (rType == MLNUIAnimationValueTypeAbsolute) {
        return value;
    }
    
    UIView *relativeView = rType == MLNUIAnimationValueTypeRelativeToSelf ? targetView : targetView.superview;
    return xAxis ? relativeView.frame.size.width * value : relativeView.frame.size.height * value;
}

- (void)setFromXType:(MLNUIAnimationValueType)fromXType
{
    _fromXType = fromXType;
}

- (void)setFromX:(CGFloat)fromX
{
    _fromX = fromX;
}

- (void)setToXType:(MLNUIAnimationValueType)toXType
{
    _toXType = toXType;
}

- (void)setToX:(CGFloat)toX
{
    _toX = toX;
}

- (void)setFromYType:(MLNUIAnimationValueType)fromYType
{
    _fromYType = fromYType;
}

- (void)setFromY:(CGFloat)fromY
{
    _fromY = fromY;
}

- (void)setToYType:(MLNUIAnimationValueType)toYType
{
    _toYType = toYType;
}

- (void)setToY:(CGFloat)toY
{
    _toY = toY;
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNUITranslateAnimation)
LUA_EXPORT_PROPERTY(setFromXType, "setFromXType:", "fromXType", MLNUITranslateAnimation)
LUA_EXPORT_PROPERTY(setFromX, "setFromX:", "fromX", MLNUITranslateAnimation)
LUA_EXPORT_PROPERTY(setToXType, "setToXType:", "toXType", MLNUITranslateAnimation)
LUA_EXPORT_PROPERTY(setToX, "setToX:", "toX", MLNUITranslateAnimation)
LUA_EXPORT_PROPERTY(setFromYType, "setFromYType:", "fromYType", MLNUITranslateAnimation)
LUA_EXPORT_PROPERTY(setFromY, "setFromY:", "fromY", MLNUITranslateAnimation)
LUA_EXPORT_PROPERTY(setToYType, "setToYType:", "toYType", MLNUITranslateAnimation)
LUA_EXPORT_PROPERTY(setToY, "setToY:", "toY", MLNUITranslateAnimation)
LUA_EXPORT_END_WITH_CFUNC(MLNUITranslateAnimation, TranslateAnimation, YES, "MLNUICanvasAnimation", lua_animation_init)
@end
