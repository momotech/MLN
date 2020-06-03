//
//  MLNUIStyleElement.m
//
//
//  Created by MoMo on 2019/4/25.
//

#import "MLNUIStyleElement.h"
#import "MLNUIFont.h"

@implementation MLNUIStyleElement

- (instancetype)init
{
    if (self = [super init]) {
        _fontSize = 14;
        _fontStyle = MLNUIFontStyleDefault;
        _fontColor = [UIColor blackColor];
        _underline = MLNUIUnderlineStyleNone;
        _changed = YES;
        _underline = MLNUIUnderlineStyleClean;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MLNUIStyleElement *copy = [[[self class] allocWithZone:zone] init];
    copy.fontSize = _fontSize;
    copy.fontStyle = _fontStyle;
    copy.fontName = _fontName;
    copy.fontColor = _fontColor;
    copy.backgroundColor = _backgroundColor;
    copy.underline = _underline;
    copy.range = _range;
    copy.changed = _changed;
    copy.image = _image;
    copy.imagePath = _imagePath;
    copy.imageSize = _imageSize;
    copy.instance = _instance;
    
    return copy;
}

- (NSDictionary *)attributes
{
    UIFont *font = [MLNUIFont fontWithFontName:_fontName fontStyle:_fontStyle fontSize:_fontSize instance:self.instance];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dict setObject:font forKey:NSFontAttributeName];
    if (_fontColor) {
        [dict setObject:_fontColor forKey:NSForegroundColorAttributeName];
    }
    if (_backgroundColor) {
        [dict setObject:_backgroundColor forKey:NSBackgroundColorAttributeName];
    }
    switch (_underline) {
        case MLNUIUnderlineStyleSingle:
            [dict setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
            break;
        case MLNUIUnderlineStyleNone:
            [dict setObject:@(NSUnderlineStyleNone) forKey:NSUnderlineStyleAttributeName];
            _underline = MLNUIUnderlineStyleClean;
            break;
        default:
            break;
    }
    return dict;
}

- (void)setFontName:(NSString *)fontName
{
    if (_fontName != fontName ) {
        _fontName = fontName;
        _changed  = YES;
    }
}

- (void)setFontSize:(CGFloat)fontSize
{
    if (_fontSize != fontSize) {
        _fontSize = fontSize;
        _changed = YES;
    }
}

- (void)setFontStyle:(MLNUIFontStyle)fontStyle
{
    if (_fontStyle != fontStyle) {
        _fontStyle = fontStyle;
        _changed = YES;
    }
}

- (void)setUnderline:(MLNUIUnderlineStyle)underline
{
    if (_underline != underline) {
        _underline = underline;
        _changed = YES;
    }
}

- (void)setFontColor:(UIColor *)fontColor
{
    if (_fontColor != fontColor) {
        _fontColor = fontColor;
        _changed =  YES;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        _changed  = YES;
    }
}

@end
