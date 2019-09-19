//
//  MLNStyleElement.m
//
//
//  Created by MoMo on 2019/4/25.
//

#import "MLNStyleElement.h"
#import "MLNFont.h"

@implementation MLNStyleElement

- (instancetype)init
{
    if (self = [super init]) {
        _fontSize = 14;
        _fontStyle = MLNFontStyleDefault;
        _fontColor = [UIColor blackColor];
        _underline = MLNUnderlineStyleNone;
        _changed = YES;
        _underline = MLNUnderlineStyleClean;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MLNStyleElement *copy = [[[self class] allocWithZone:zone] init];
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
    
    return copy;
}

- (NSDictionary *)attributes
{
    UIFont *font = [MLNFont fontWithFontName:_fontName fontStyle:_fontStyle fontSize:_fontSize];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dict setObject:font forKey:NSFontAttributeName];
    if (_fontColor) {
        [dict setObject:_fontColor forKey:NSForegroundColorAttributeName];
    }
    if (_backgroundColor) {
        [dict setObject:_backgroundColor forKey:NSBackgroundColorAttributeName];
    }
    switch (_underline) {
        case MLNUnderlineStyleSingle:
            [dict setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
            break;
        case MLNUnderlineStyleNone:
            [dict setObject:@(NSUnderlineStyleNone) forKey:NSUnderlineStyleAttributeName];
            _underline = MLNUnderlineStyleClean;
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

- (void)setFontStyle:(MLNFontStyle)fontStyle
{
    if (_fontStyle != fontStyle) {
        _fontStyle = fontStyle;
        _changed = YES;
    }
}

- (void)setUnderline:(MLNUnderlineStyle)underline
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
