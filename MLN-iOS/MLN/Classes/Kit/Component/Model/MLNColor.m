//
//  MLNColor.m
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNColor.h"
#import "MLNLuaCore.h"
#import "MLNKitHeader.h"

#define kColorComponentValue(value) ((value) < 0? 0 : ((value) > 255? 255 : (value)))
#define kColorAlphaComponentValue(value) ((value) < 0.0? 0.0 : ((value) > 1.0? 1.0 : (value)))

@interface MLNColor ()

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat red;
@property (nonatomic, assign) CGFloat green;
@property (nonatomic, assign) CGFloat blue;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) NSUInteger hex;

@end

@implementation MLNColor

- (instancetype)initWithColor:(UIColor *)aColor
{
    if (self = [super init]) {
        [self _recalcuValuesByColor:aColor];
        _color = aColor;
    }
    return self;
}

- (instancetype)initWithR:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b a:(CGFloat)a
{
    if (self = [super init]) {
        [self _setByRed:r green:g blue:b alpha:a];
    }
    return self;
}

static int lua_color_init(lua_State *L) {
    MLNColor *color = nil;
    NSUInteger argCount = lua_gettop(L);
    switch (argCount) {
        case 4: {
            NSUInteger red = lua_tonumber(L, 1);
            NSUInteger green = lua_tonumber(L, 2);
            NSUInteger blue = lua_tonumber(L, 3);
            CGFloat alpha = lua_tonumber(L, 4);
            color = [[MLNColor alloc] initWithR:red g:green b:blue a:alpha];
        }
            break;
        case 3: {
            NSUInteger red = lua_tonumber(L, 1);
            NSUInteger green = lua_tonumber(L, 2);
            NSUInteger blue = lua_tonumber(L, 3);
            color = [[MLNColor alloc] initWithR:red g:green b:blue a:1.0];
        }
            break;
        case 0:
            color = [[MLNColor alloc] initWithR:0 g:0 b:0 a:1.0];
            break;
        default: {
            mln_lua_error(L, @"number of arguments must be 3 or 4 or 0!");
            break;
        }
    }
    
    if (color) {
        // 标记为Lua创建
        color.mln_isLuaObject = YES;
        [MLN_LUA_CORE(L) pushNativeObject:color error:NULL];
        return 1;
    }
    
    return 0;
}

- (void)_setByRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
{
    _red = kColorComponentValue(red) / 255.0;
    _green = kColorComponentValue(green) / 255.0;
    _blue = kColorComponentValue(blue) / 255.0;
    _alpha = kColorAlphaComponentValue(alpha);
    _hex = (kColorComponentValue(red)<<16) | (kColorComponentValue(green)<<8) | kColorComponentValue(blue);
    _color = [UIColor colorWithRed:_red green:_green blue:_blue alpha:_alpha];
}

- (void)_recalcuValuesByColor:(UIColor *)color
{
    CGFloat red = 0.f;
    CGFloat green = 0.f;
    CGFloat blue = 0.f;
    CGFloat alpha = 0.f;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    _alpha = alpha;
    _red = red;
    _green = green;
    _blue = blue;
    [self _recalcuHex];
}

- (void)_recalcuHex
{
    NSUInteger u_r = (NSUInteger)self.red *255.f;
    NSUInteger u_g = (NSUInteger)self.green *255.f;
    NSUInteger u_b = (NSUInteger)self.blue *255.f;
    _hex = (u_r<<16) | (u_g<<8) | u_b;
}

#pragma mark - Export
- (void)lua_setByHex:(NSUInteger)hex
{
    [self lua_setByHex:hex alpha:1.f];
}

- (void)lua_setByHex:(NSUInteger)hex alpha:(CGFloat)alpha
{
    alpha = alpha > 1.f ? 1.f:alpha;
    alpha = alpha < 0.f ? 0.f:alpha;
    CGFloat red, green, blue;
    red = ((CGFloat)((hex >> 16) & 0xFF)) / ((CGFloat)0xFF);
    green = ((CGFloat)((hex >> 8) & 0xFF)) / ((CGFloat)0xFF);
    blue = ((CGFloat)((hex >> 0) & 0xFF)) / ((CGFloat)0xFF);
    alpha = hex > 0xFFFFFF ? ((CGFloat)((hex >> 24) & 0xFF)) / ((CGFloat)0xFF) : 1;
    self.color = [UIColor colorWithRed: red green:green blue:blue alpha:alpha];
    self.red = red;
    self.green = green;
    self.blue = blue;
    self.alpha = alpha;
    self.hex = hex;
}


- (void)lua_setAlpha:(CGFloat)alpha
{
    self.alpha = alpha < 0? 0 : (alpha > 1.0? 1.0 : alpha);
    self.color = [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
}

- (void)lua_setRed:(NSUInteger)red
{
    self.red = kColorComponentValue(red) / 255.0;
    self.color = [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
    [self _recalcuHex];
}

- (NSUInteger)lua_red
{
    return self.red * 255.f;
}

- (void)lua_setGreen:(NSUInteger)green
{
    self.green = kColorComponentValue(green) / 255.0;
    self.color = [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
    [self _recalcuHex];
}

- (NSUInteger)lua_green
{
    return self.green * 255.f;
}

- (void)lua_setBlue:(NSUInteger)blue
{
    self.blue = kColorComponentValue(blue) / 255.0;
    self.color = [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
    [self _recalcuHex];
}

- (NSUInteger)lua_blue
{
    return self.blue * 255.f;
}

- (void)lua_setByR:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b
{
    [self lua_setByR:r g:g b:b a:1.f];
}

- (void)lua_setByR:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b a:(CGFloat)a
{
    [self _setByRed:r green:g blue:b alpha:a];
}

- (void)lua_setColor:(NSString*)color { //#ffffffff”或“rgb(12,23,34)”或“rgba(12,23,45,0.1)”
    color = [color stringByReplacingOccurrencesOfString:@" " withString:@""];
    color = [color stringByReplacingOccurrencesOfString:@"(" withString:@""];
    color = [color stringByReplacingOccurrencesOfString:@")" withString:@""];
    color = [color uppercaseString];
    if ([color rangeOfString:@"RGBA"].location != NSNotFound) {
        unsigned int  r, g, b;
        float a = 1.0;
        color = [color stringByReplacingOccurrencesOfString:@"RGBA" withString:@""];
        NSArray* array = [color componentsSeparatedByString:@","];
        if (array.count != 4) {
            return;
        }
        r = CGFloatValueFromNumber(array[0]);
        g = CGFloatValueFromNumber(array[1]);
        b = CGFloatValueFromNumber(array[2]);
        a = CGFloatValueFromNumber(array[3]);
        [self _setByRed:r green:g blue:b alpha:a];
    } else  if ([color rangeOfString:@"RGB"].location != NSNotFound) {
        unsigned  r, g, b;
        float a = 1.0;
        color = [color stringByReplacingOccurrencesOfString:@"RGB" withString:@""];
        NSArray* array = [color componentsSeparatedByString:@","];
        if (array.count != 3) {
            return;
        }
        r = [array[0] intValue];
        g = [array[1] intValue];
        b = [array[2] intValue];
        [self lua_setByR:r g:g b:b a:a];
    } else {
        [self lua_setColorWithHex:color];
    }
}

- (void)lua_clear
{
    self.color = [UIColor clearColor];
    self.red = 0.f;
    self.green = 0.f;
    self.blue = 0.f;
    self.alpha = 0.f;
    self.hex = 0x000000;
}

//设置颜色RGBA
- (void)lua_setColorWithHex:(NSString *)hex {
    MLNCheckStringTypeAndNilValue(hex);
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6 && [cString length] != 8)
        return;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    
    NSString *rString = [cString substringWithRange:range];
    
    range.location += 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location += 2;
    NSString *bString = [cString substringWithRange:range];
    
    range.location += 2;
    NSString *aString = @"FF";
    if (cString.length == 8) { //
        aString = [cString substringWithRange:range];
    }
    
    unsigned int a, r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    [self lua_setByR:r g:g b:b a:a/255.0f];
}

//设置颜色ARGB
- (void)lua_setAHex:(NSString *)aHex {
    MLNCheckStringTypeAndNilValue(aHex);
    NSString *cString = [[aHex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6 && [cString length] != 8)
        return;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *aString = @"FF";
    if (cString.length == 8) { //
        aString = [cString substringWithRange:range];
        range.location += 2;
    }
    
    NSString *rString = [cString substringWithRange:range];
    
    range.location += 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location += 2;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int a, r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    [self lua_setByR:r g:g b:b a:a/255.0f];
}

- (id)mln_rawNativeData
{
    return self.color;
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNColor)
LUA_EXPORT_PROPERTY(hex, "lua_setByHex:", "hex", MLNColor)
LUA_EXPORT_PROPERTY(alpha, "lua_setAlpha:", "alpha", MLNColor)
LUA_EXPORT_PROPERTY(red, "lua_setRed:", "lua_red", MLNColor)
LUA_EXPORT_PROPERTY(green, "lua_setGreen:", "lua_green", MLNColor)
LUA_EXPORT_PROPERTY(blue, "lua_setBlue:", "lua_blue", MLNColor)
LUA_EXPORT_METHOD(setHexA, "lua_setByHex:alpha:", MLNColor)
LUA_EXPORT_METHOD(setRGBA, "lua_setByR:g:b:a:", MLNColor)
LUA_EXPORT_METHOD(setColor, "lua_setColor:", MLNColor)
LUA_EXPORT_METHOD(setAColor, "lua_setAHex:", MLNColor)
LUA_EXPORT_METHOD(clear, "lua_clear", MLNColor)
LUA_EXPORT_END_WITH_CFUNC(MLNColor, Color, NO, NULL, lua_color_init)

@end
