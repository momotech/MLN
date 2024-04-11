//
//  MLNPoint.m
//  MLN
//
//  Created by MoMo on 2019/8/2.
//

#import "MLNPoint.h"
#import "MLNLuaCore.h"

@interface MLNPoint ()

@property (nonatomic, assign) CGPoint point;

@end
@implementation MLNPoint

+ (instancetype)pointWithCGPoint:(CGPoint)point
{
    MLNPoint *p = [[MLNPoint alloc] init];
    p.point = point;
    return p;
}

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore x:(NSNumber *)x y:(NSNumber *)y
{
    if (self = [super initWithLuaCore:luaCore]) {
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

- (BOOL)mln_isMultiple
{
    // 该类型只当做UserData
    return NO;
}

#pragma mark - Extra To Lua
LUA_EXPORT_BEGIN(MLNPoint)
LUA_EXPORT_PROPERTY(x, "setX:", "x", MLNPoint)
LUA_EXPORT_PROPERTY(y, "setY:", "y", MLNPoint)
LUA_EXPORT_END(MLNPoint, Point, NO, NULL, "initWithLuaCore:x:y:")

@end
