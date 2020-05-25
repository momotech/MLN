//
//  MLNUIPoint.m
//  MLNUI
//
//  Created by MoMo on 2019/8/2.
//

#import "MLNUIPoint.h"
#import "MLNUILuaCore.h"

@interface MLNUIPoint ()

@property (nonatomic, assign) CGPoint point;

@end
@implementation MLNUIPoint

+ (instancetype)pointWithCGPoint:(CGPoint)point
{
    MLNUIPoint *p = [[MLNUIPoint alloc] init];
    p.point = point;
    return p;
}

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore x:(NSNumber *)x y:(NSNumber *)y
{
    if (self = [super initWithMLNUILuaCore:luaCore]) {
        _point = CGPointMake(CGFloatValueFromNumber(x), CGFloatValueFromNumber(y));
    }
    return self;
}

- (void)setX:(CGFloat)x
{
    _point.x = x;
}

- (void)setY:(CGFloat)y
{
    _point.y = y;
}

- (CGFloat)x
{
    return _point.x;
}

- (CGFloat)y
{
    return _point.y;
}

- (CGPoint)CGPointValue
{
    return _point;
}

- (void)getValue:(void *)value
{
    value = &_point;
}

- (const char *)objCType
{
    return @encode(CGPoint);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Point x: %f, y: %f>", _point.x, _point.y];
}

- (BOOL)mlnui_isMultiple
{
    // 该类型只当做UserData
    return NO;
}

#pragma mark - Extra To Lua
LUA_EXPORT_BEGIN(MLNUIPoint)
LUA_EXPORT_PROPERTY(x, "setX:", "x", MLNUIPoint)
LUA_EXPORT_PROPERTY(y, "setY:", "y", MLNUIPoint)
LUA_EXPORT_END(MLNUIPoint, Point, NO, NULL, "initWithMLNUILuaCore:x:y:")

@end
