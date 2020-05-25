//
//  MLNUIAlphaAnimation.m
//  MLNUI
//
//  Created by MoMo on 2019/5/16.
//

#import "MLNUIAlphaAnimation.h"
#import "MLNUIEntityExporterMacro.h"
#import "MLNUIBlock.h"
#import "NSDictionary+MLNUISafety.h"

@interface MLNUIAlphaAnimation()

@property (nonatomic, assign) CGFloat fromAlpha;
@property (nonatomic, assign) CGFloat toAlpha;


@end

@implementation MLNUIAlphaAnimation

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore fromAlpha:(NSNumber *)fromAlpha toAlpha:(NSNumber *)toAlpha
{
    if (self = [super init]) {
        if (fromAlpha) {
            [self setFromAlpha:fromAlpha.floatValue];
        }
        if (toAlpha) {
            [self setToAlpha:toAlpha.floatValue];
        }
    }
    return self;
}

#pragma mark - copy
- (id)copyWithZone:(NSZone *)zone
{
    MLNUIAlphaAnimation *copy = [super copyWithZone:zone];
    copy.fromAlpha = _fromAlpha;
    copy.toAlpha = _toAlpha;
    return copy;
}

#pragma mark - getter & setter
- (void)setFromAlpha:(CGFloat)fromAlpha
{
    _fromAlpha = fromAlpha;
    CABasicAnimation *animation = [self animationForKey:kMUIOpacity];
    [animation setFromValue:@(fromAlpha)];
}

- (void)setToAlpha:(CGFloat)toAlpha
{
    _toAlpha = toAlpha;
    CABasicAnimation *animation = [self animationForKey:kMUIOpacity];
    [animation setToValue:@(toAlpha)];
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNUIAlphaAnimation)
LUA_EXPORT_PROPERTY(setFromAlpha, "setFromAlpha:", "fromAlpha", MLNUIAlphaAnimation)
LUA_EXPORT_PROPERTY(setToAlpha, "setToAlpha:", "toAlpha", MLNUIAlphaAnimation)
LUA_EXPORT_END(MLNUIAlphaAnimation, AlphaAnimation, YES, "MLNUICanvasAnimation", "initWithMLNUILuaCore:fromAlpha:toAlpha:")
@end
