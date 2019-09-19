//
//  MLNRect.m
//  MLN
//
//  Created by MoMo on 2019/8/2.
//

#import "MLNRect.h"
#import "NSObject+MLNCore.h"
#import "MLNLuaCore.h"

@interface MLNRect ()

@property (nonatomic, assign) CGRect rect;

@end
@implementation MLNRect

+ (instancetype)rectWithCGRect:(CGRect)rect
{
    MLNRect *r = [[MLNRect alloc] init];
    r.rect = rect;
    return r;
}

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore xNum:(NSNumber *)xNum yNum:(NSNumber *)yNum widthNum:(NSNumber *)widthNum heightNum:(NSNumber *)heightNum
{
    if (self = [super initWithLuaCore:luaCore]) {
        CGFloat x = CGFloatValueFromNumber(xNum);
        CGFloat y = CGFloatValueFromNumber(yNum);
        CGFloat width = CGFloatValueFromNumber(widthNum);
        CGFloat height = CGFloatValueFromNumber(heightNum);
        _rect = CGRectMake(x, y, width, height);
    }
    return self;
}

- (CGFloat)lua_x
{
    return _rect.origin.x;
}

- (void)lua_setX:(CGFloat)x
{
    _rect.origin.x = x;
}

- (CGFloat)lua_y
{
    return _rect.origin.y;
}

- (void)lua_setY:(CGFloat)y
{
    _rect.origin.y = y;
}

- (CGFloat)lua_width
{
    return _rect.size.width;
}

- (void)lua_setWidth:(CGFloat)width
{
    _rect.size.width = width;
}

- (CGFloat)lua_height
{
    return _rect.size.height;
}

- (void)lua_setHeight:(CGFloat)height
{
    _rect.size.height = height;
}

- (void)lua_setPoint:(CGPoint)point
{
    _rect.origin.x = point.x;
    _rect.origin.y = point.y;
}

- (CGPoint)point
{
    return _rect.origin;
}

- (void)lua_setSize:(CGSize)size
{
    _rect.size.width = size.width;
    _rect.size.height = size.height;
}

- (CGSize)size
{
    return _rect.size;
}

- (void)getValue:(void *)value
{
    value = &_rect;
}

- (const char *)objCType
{
    return @encode(CGRect);
}

- (CGRect)CGRectValue
{
    return _rect;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Rect x: %f, y: %f, width: %f, height: %f>", _rect.origin.x, _rect.origin.y, _rect.size.width, _rect.size.height];
}

- (BOOL)mln_isMultiple
{
    // 该类型只当做UserData
    return NO;
}

LUA_EXPORT_BEGIN(MLNRect)
LUA_EXPORT_PROPERTY(point, "lua_setPoint:", "point", MLNRect)
LUA_EXPORT_PROPERTY(size, "lua_setSize:", "size", MLNRect)
LUA_EXPORT_PROPERTY(x, "lua_setX:", "lua_x", MLNRect)
LUA_EXPORT_PROPERTY(y, "lua_setY:", "lua_y", MLNRect)
LUA_EXPORT_PROPERTY(width, "lua_setWidth:", "lua_width", MLNRect)
LUA_EXPORT_PROPERTY(height, "lua_setHeight:", "lua_height", MLNRect)
LUA_EXPORT_END(MLNRect, Rect, NO, NULL, "initWithLuaCore:xNum:yNum:widthNum:heightNum:")

@end
