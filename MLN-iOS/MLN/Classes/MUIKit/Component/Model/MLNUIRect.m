//
//  MLNUIRect.m
//  MLNUI
//
//  Created by MoMo on 2019/8/2.
//

#import "MLNUIRect.h"
#import "NSObject+MLNUICore.h"
#import "MLNUILuaCore.h"

@interface MLNUIRect ()

@property (nonatomic, assign) CGRect rect;

@end
@implementation MLNUIRect

+ (instancetype)rectWithCGRect:(CGRect)rect
{
    MLNUIRect *r = [[MLNUIRect alloc] init];
    r.rect = rect;
    return r;
}

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore xNum:(NSNumber *)xNum yNum:(NSNumber *)yNum widthNum:(NSNumber *)widthNum heightNum:(NSNumber *)heightNum
{
    if (self = [super initWithMLNUILuaCore:luaCore]) {
        CGFloat x = CGFloatValueFromNumber(xNum);
        CGFloat y = CGFloatValueFromNumber(yNum);
        CGFloat width = CGFloatValueFromNumber(widthNum);
        CGFloat height = CGFloatValueFromNumber(heightNum);
        _rect = CGRectMake(x, y, width, height);
    }
    return self;
}

- (CGFloat)luaui_x
{
    return _rect.origin.x;
}

- (void)luaui_setX:(CGFloat)x
{
    _rect.origin.x = x;
}

- (CGFloat)luaui_y
{
    return _rect.origin.y;
}

- (void)luaui_setY:(CGFloat)y
{
    _rect.origin.y = y;
}

- (CGFloat)luaui_width
{
    return _rect.size.width;
}

- (void)luaui_setWidth:(CGFloat)width
{
    _rect.size.width = width;
}

- (CGFloat)luaui_height
{
    return _rect.size.height;
}

- (void)luaui_setHeight:(CGFloat)height
{
    _rect.size.height = height;
}

- (void)luaui_setPoint:(CGPoint)point
{
    _rect.origin.x = point.x;
    _rect.origin.y = point.y;
}

- (CGPoint)point
{
    return _rect.origin;
}

- (void)luaui_setSize:(CGSize)size
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

- (BOOL)mlnui_isMultiple
{
    // 该类型只当做UserData
    return NO;
}

LUA_EXPORT_BEGIN(MLNUIRect)
LUA_EXPORT_PROPERTY(point, "luaui_setPoint:", "point", MLNUIRect)
LUA_EXPORT_PROPERTY(size, "luaui_setSize:", "size", MLNUIRect)
LUA_EXPORT_PROPERTY(x, "luaui_setX:", "luaui_x", MLNUIRect)
LUA_EXPORT_PROPERTY(y, "luaui_setY:", "luaui_y", MLNUIRect)
LUA_EXPORT_PROPERTY(width, "luaui_setWidth:", "luaui_width", MLNUIRect)
LUA_EXPORT_PROPERTY(height, "luaui_setHeight:", "luaui_height", MLNUIRect)
LUA_EXPORT_END(MLNUIRect, Rect, NO, NULL, "initWithMLNUILuaCore:xNum:yNum:widthNum:heightNum:")

@end
