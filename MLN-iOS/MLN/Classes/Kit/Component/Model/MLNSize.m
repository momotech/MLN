//
//  MLNSize.m
//  MLN
//
//  Created by MoMo on 2019/8/2.
//

#import "MLNSize.h"
#import "MLNLuaCore.h"

@interface MLNSize ()

@property (nonatomic, assign) CGSize size;

@end
@implementation MLNSize

+ (instancetype)sizeWithCGSize:(CGSize)size
{
    MLNSize *s = [[MLNSize alloc] init];
    s.size = size;
    return s;
}

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore width:(NSNumber *)width height:(NSNumber *)height
{
    if (self = [super initWithLuaCore:luaCore]) {
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

- (BOOL)mln_isMultiple
{
    // 该类型只当做UserData
    return NO;
}

#pragma mark - Extra To Lua
LUA_EXPORT_BEGIN(MLNSize)
LUA_EXPORT_PROPERTY(width, "setWidth:", "width", MLNSize)
LUA_EXPORT_PROPERTY(height, "setHeight:", "height", MLNSize)
LUA_EXPORT_END(MLNSize, Size, NO, NULL, "initWithLuaCore:with:height:")

@end
