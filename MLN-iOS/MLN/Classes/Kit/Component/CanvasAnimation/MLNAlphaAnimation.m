//
//  MLNAlphaAnimation.m
//  MLN
//
//  Created by MoMo on 2019/5/16.
//

#import "MLNAlphaAnimation.h"
#import "MLNEntityExporterMacro.h"
#import "MLNBlock.h"
#import "NSDictionary+MLNSafety.h"

@interface MLNAlphaAnimation()

@property (nonatomic, assign) CGFloat fromAlpha;
@property (nonatomic, assign) CGFloat toAlpha;


@end

@implementation MLNAlphaAnimation

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore fromAlpha:(NSNumber *)fromAlpha toAlpha:(NSNumber *)toAlpha
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
    MLNAlphaAnimation *copy = [super copyWithZone:zone];
    copy.fromAlpha = _fromAlpha;
    copy.toAlpha = _toAlpha;
    return copy;
}

#pragma mark - getter & setter
- (void)setFromAlpha:(CGFloat)fromAlpha
{
    _fromAlpha = fromAlpha;
    CABasicAnimation *animation = [self animationForKey:kOpacity];
    [animation setFromValue:@(fromAlpha)];
}

- (void)setToAlpha:(CGFloat)toAlpha
{
    _toAlpha = toAlpha;
    CABasicAnimation *animation = [self animationForKey:kOpacity];
    [animation setToValue:@(toAlpha)];
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNAlphaAnimation)
LUA_EXPORT_PROPERTY(setFromAlpha, "setFromAlpha:", "fromAlpha", MLNAlphaAnimation)
LUA_EXPORT_PROPERTY(setToAlpha, "setToAlpha:", "toAlpha", MLNAlphaAnimation)
LUA_EXPORT_END(MLNAlphaAnimation, AlphaAnimation, YES, "MLNCanvasAnimation", "initWithLuaCore:fromAlpha:toAlpha:")
@end
