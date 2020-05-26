//
//  MLNUISize.m
//  MLNUI
//
//  Created by MoMo on 2019/8/2.
//

#import "MLNUISize.h"
#import "MLNUILuaCore.h"

@interface MLNUISize ()

@property (nonatomic, assign) CGSize size;

@end
@implementation MLNUISize

+ (instancetype)sizeWithCGSize:(CGSize)size
{
    MLNUISize *s = [[MLNUISize alloc] init];
    s.size = size;
    return s;
}

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore width:(NSNumber *)width height:(NSNumber *)height
{
    if (self = [super initWithMLNUILuaCore:luaCore]) {
        _size = CGSizeMake(CGFloatValueFromNumber(width), CGFloatValueFromNumber(height));
    }
    return self;
}

- (void)setWidth:(CGFloat)width
{
    _size.width = width;
}

- (CGFloat)width
{
    return _size.width;
}

- (void)setHeight:(CGFloat)height
{
    _size.height = height;
}

- (CGFloat)height
{
    return _size.height;
}

- (const char *)objCType
{
    return @encode(CGSize);
}

- (void)getValue:(void *)value
{
    value = &_size;
}

- (CGSize)CGSizeValue
{
    return _size;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Size width: %f, height: %f>", _size.width, _size.height];
}

- (BOOL)mlnui_isMultiple
{
    // 该类型只当做UserData
    return NO;
}

#pragma mark - Extra To Lua
LUAUI_EXPORT_BEGIN(MLNUISize)
LUAUI_EXPORT_PROPERTY(width, "setWidth:", "width", MLNUISize)
LUAUI_EXPORT_PROPERTY(height, "setHeight:", "height", MLNUISize)
LUAUI_EXPORT_END(MLNUISize, Size, NO, NULL, "initWithMLNUILuaCore:width:height:")

@end
