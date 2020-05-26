//
//  MLNUIStyleString.m
//  MMDebugTools-DebugManager
//
//  Created by MoMo on 2018/7/4.
//

#import "MLNUIStyleString.h"
#import "MLNUIKitHeader.h"
#import <CoreText/CoreText.h>
#import "MLNUIViewExporterMacro.h"
#import "MLNUIFont.h"
#import "MLNUIStyleElement.h"
#import "NSAttributedString+MLNUIKit.h"
#import "MLNUIKitInstanceHandlersManager.h"

@interface MLNUIStyleString ()

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) MLNUIFontStyle fontStyle;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) BOOL statusChanged;
@property (nonatomic, assign) MLNUIStyleImageAlignType imageAlign;
@property (nonatomic, strong) NSMutableDictionary *styleElementsDictM;

@end
@implementation MLNUIStyleString

- (instancetype)initWithAttributedString:(NSAttributedString *)attributes
{
    if (self = [super init]){
        _mutableStyledString = attributes.mutableCopy;
        [_mutableStyledString setLuaui_styleString:self];
    }
    return self;
}

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore string:(NSString *)attriteStr
{
    if (self = [super initWithMLNUILuaCore:luaCore]){
        attriteStr = attriteStr ?: @"";
        _mutableStyledString = [[NSMutableAttributedString alloc]initWithString:attriteStr];
        [_mutableStyledString setLuaui_styleString:self];
        // 设置默认行间距
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;
        [_mutableStyledString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attriteStr.length)];
    }
    return self;
}

#pragma mark - getter
- (NSMutableDictionary *)styleElementsDictM
{
    if (!_styleElementsDictM) {
        _styleElementsDictM = [NSMutableDictionary dictionaryWithCapacity:_mutableStyledString.length];
    }
    return _styleElementsDictM;
}

#pragma mark - Method

- (NSArray *)shouldChangedElementWithNewRange:(NSRange *)newRange;
{
    NSMutableArray *interRangesArray = [NSMutableArray array];
    NSArray *sortedArray = [self.styleElementsDictM.allValues sortedArrayUsingComparator:^NSComparisonResult(MLNUIStyleElement  *obj1, MLNUIStyleElement  *obj2) {
        return obj1.range.location > obj2.range.location;
    }];
    for (MLNUIStyleElement *element in sortedArray) {
        NSRange oldRange = element.range;
        NSRange interRange = NSIntersectionRange(oldRange, (*newRange));
        if (interRange.length == 0) {
            continue;
        }
        //存在交集，四种情况，旧包含新，新包含旧，新大于旧，新小于旧
        if ((*newRange).location > oldRange.location && (*newRange).location + (*newRange).length < oldRange.location + oldRange.length) { //旧包裹新且不沾边 1-5 2-3
            NSRange range1 = NSMakeRange(oldRange.location, (*newRange).location - oldRange.location);
            MLNUIStyleElement *element1 = [element copy];
            element1.range = range1;
            NSRange range2 = (*newRange);
            MLNUIStyleElement *element2 = [element copy];
            element2.range = range2;
            NSRange range3 = NSMakeRange((*newRange).location + (*newRange).length, oldRange.location + oldRange.length - (*newRange).location - (*newRange).length);
            MLNUIStyleElement *element3 = [element copy];
            element3.range = range3;
            
            [self.styleElementsDictM removeObjectForKey:NSStringFromRange(oldRange)];
            [self.styleElementsDictM setObject:element1 forKey:NSStringFromRange(range1)];
            [self.styleElementsDictM setObject:element2 forKey:NSStringFromRange(range2)];
            [self.styleElementsDictM setObject:element3 forKey:NSStringFromRange(range3)];
            
            [interRangesArray addObject:element2];
            (*newRange).length = 0;
            break;
        } else if ((*newRange).location == oldRange.location && (*newRange).location + (*newRange).length < oldRange.location + oldRange.length) { //旧包裹新且左沾边 1-5 1-2
            NSRange range1 = (*newRange);
            MLNUIStyleElement *element1 = [element copy];
            element1.range = range1;
            NSRange range2 = NSMakeRange((*newRange).location + (*newRange).length, oldRange.location + oldRange.length - (*newRange).location - (*newRange).length);
            MLNUIStyleElement *element2 = [element copy];
            element2.range = range2;
            
            [self.styleElementsDictM removeObjectForKey:NSStringFromRange(oldRange)];
            [self.styleElementsDictM setObject:element1 forKey:NSStringFromRange(range1)];
            [self.styleElementsDictM setObject:element2 forKey:NSStringFromRange(range2)];
            
            [interRangesArray addObject:element1];
            (*newRange).length = 0;
            break;
        } else if ((*newRange).location > oldRange.location && (*newRange).location + (*newRange).length == oldRange.location + oldRange.length) {//旧包裹新且右沾边 1-5 3-5
            NSRange range1 = NSMakeRange(oldRange.location, (*newRange).location - oldRange.location);
            MLNUIStyleElement *element1 = [element copy];
            element1.range = range1;
            NSRange range2 = (*newRange);
            MLNUIStyleElement *element2 = [element copy];
            element2.range = range2;
            
            [self.styleElementsDictM removeObjectForKey:NSStringFromRange(oldRange)];
            [self.styleElementsDictM setObject:element1 forKey:NSStringFromRange(range1)];
            [self.styleElementsDictM setObject:element2 forKey:NSStringFromRange(range2)];
            
            [interRangesArray addObject:element2];
            (*newRange).length = 0;
            break;
        } else if ((*newRange).location < oldRange.location && (*newRange).location + (*newRange).length > oldRange.location + oldRange.length ) { //新包裹旧  1-5 0-6
            NSRange range1 = NSMakeRange((*newRange).location,oldRange.location - (*newRange).location);
            MLNUIStyleElement *element1 = [self styleElementWithKey:NSStringFromRange(range1)];
            element1.range = range1;
            NSRange range2 = oldRange;
            MLNUIStyleElement *element2 = element;
            element2.range = range2;
            
            (*newRange) = NSMakeRange(oldRange.location + oldRange.length , (*newRange).location + (*newRange).length - oldRange.location - oldRange.length);
            
            [interRangesArray addObject:element1];
            [interRangesArray addObject:element2];
        } else if ((*newRange).location > oldRange.location && (*newRange).location < oldRange.location + oldRange.length && (*newRange).location + (*newRange).length > oldRange.location + oldRange.length) { // 新右边跨旧 1-5 2-6
            NSRange range1 = NSMakeRange(oldRange.location, (*newRange).location - oldRange.location);
            MLNUIStyleElement *element1 = element.copy;
            element1.range = range1;
            NSRange range2 = NSMakeRange((*newRange).location, oldRange.location + oldRange.length - (*newRange).location);
            MLNUIStyleElement *element2 = element.copy;
            element2.range = range2;
            
            (*newRange) = NSMakeRange(oldRange.location + oldRange.length , (*newRange).location + (*newRange).length - oldRange.location - oldRange.length);
            
            [self.styleElementsDictM removeObjectForKey:NSStringFromRange(oldRange)];
            [self.styleElementsDictM setObject:element1 forKey:NSStringFromRange(range1)];
            [self.styleElementsDictM setObject:element2 forKey:NSStringFromRange(range2)];
            
            [interRangesArray addObject:element2];
        } else if ((*newRange).location == oldRange.location && (*newRange).location + (*newRange).length > oldRange.location + oldRange.length) { //新左边贴旧 1-5 1-6
            (*newRange) = NSMakeRange(oldRange.location + oldRange.length , (*newRange).location + (*newRange).length - oldRange.location - oldRange.length);
            [interRangesArray addObject:element];
        } else if ((*newRange).location < oldRange.location && (*newRange).location + (*newRange).length >= oldRange.location) { //新左边跨旧  1-5  0-3
            NSRange range1 = NSMakeRange((*newRange).location,oldRange.location - (*newRange).location);
            MLNUIStyleElement *element1 = [self styleElementWithKey:NSStringFromRange(range1)];
            element1.range = range1;
            NSRange range2 = NSMakeRange(oldRange.location, (*newRange).location + (*newRange).length - oldRange.location);
            MLNUIStyleElement *element2 = [element copy];
            element2.range = range2;
            
            NSRange range3 = NSMakeRange((*newRange).location + (*newRange).length , oldRange.location + oldRange.length - (*newRange).location - (*newRange).length);
            MLNUIStyleElement *element3 = [element copy];
            element3.range = range3;
            
            [self.styleElementsDictM removeObjectForKey:NSStringFromRange(oldRange)];
            [self.styleElementsDictM setObject:element2 forKey:NSStringFromRange(range2)];
            [self.styleElementsDictM setObject:element3 forKey:NSStringFromRange(range3)];
            
            [interRangesArray addObject:element1];
            [interRangesArray addObject:element2];
            (*newRange).length = 0;
            break;
        }
    }
    return interRangesArray;
}

- (BOOL)outOfRange:(NSInteger)location length:(NSInteger)length
{
    MLNUILuaAssert(self.mlnui_luaCore, ((location + length) <= self.mutableStyledString.length), @"out of range");
    return (location + length) > self.mutableStyledString.length;
}

- (MLNUIStyleElement *)styleElementWithKey:(NSString *)key
{
    if (!key || key.length == 0) {
        return nil;
    }
    MLNUIStyleElement* element = [self.styleElementsDictM objectForKey:key];
    if (!element) {
        element = [[MLNUIStyleElement alloc] init];
        element.instance = [self myKitInstance];
        [self.styleElementsDictM setObject:element forKey:key];
    }
    return element;
}

- (void)handleStyleStringIfNeed
{
    if (!_statusChanged) {
        return;
    }
    
    for (MLNUIStyleElement *element in self.styleElementsDictM.allValues) {
        NSRange range = element.range;
        if ([self outOfRange:range.location length:range.length] || element.changed == NO || element.imagePath.length > 0) continue;
        [self.mutableStyledString addAttributes:element.attributes range:range];
        element.changed = NO;
    }
    
    
    _statusChanged = NO;
}

- (void)mlnui_checkImageIfNeed
{
    NSMutableArray *imageElementArray = [NSMutableArray array];
    MLNUIImageLoadFinishedCallback tempCallback = self.loadFinishedCallback;
    NSMutableAttributedString *tempAttributeString = self.mutableStyledString;
    for (MLNUIStyleElement *element in self.styleElementsDictM.allValues) {
        if (element.imagePath.length > 0 && element.range.length > 0 ) {
            [imageElementArray addObject:element];
        }
    }
    
    if (imageElementArray.count > 0) {
        __block NSUInteger count = 0;
        dispatch_group_t imagesGroup = dispatch_group_create();
        
        id<MLNUIImageLoaderProtocol> imageLoader = [self imageLoader];
        for (MLNUIStyleElement *element in imageElementArray) {
            dispatch_group_enter(imagesGroup);
            [imageLoader view:(UIView<MLNUIEntityExportProtocol> *)self loadImageWithPath:element.imagePath completed:^(UIImage *image, NSError *error, NSString *imagePath) {
                if (image) {
                    element.image = image;
                    element.changed = NO;
                }
                count += 1;
                dispatch_group_leave(imagesGroup);
            }];
        }
        
        dispatch_group_notify(imagesGroup, dispatch_get_main_queue(), ^{
            if (count == imageElementArray.count && tempCallback) {
                for (MLNUIStyleElement *element in imageElementArray) {
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                    textAttachment.image = element.image;
                    UIFont *font = [self lineHeightWithElement:element];
                    switch (self.imageAlign) {
                        case MLNUIStyleImageAlignTypeCenter:
                        {
                            CGFloat attachmentTop = fabs(element.imageSize.height - font.capHeight)/2.0;
                            textAttachment.bounds = CGRectMake(0, -attachmentTop, element.imageSize.width, element.imageSize.height);
                        }
                            break;
                        case MLNUIStyleImageAlignTypeTop:
                        case MLNUIStyleImageAlignTypeBottom:
                        default:
                        {
                            textAttachment.bounds = CGRectMake(0, 0, element.imageSize.width, element.imageSize.height);
                        }
                            break;
                    }
                    
                    NSAttributedString *imageAttribute = [NSAttributedString attributedStringWithAttachment:textAttachment].mutableCopy;
                    [tempAttributeString replaceCharactersInRange:element.range withAttributedString:imageAttribute];
                }
                tempCallback(tempAttributeString);
            }
        });
    }
}

- (id<MLNUIImageLoaderProtocol>)imageLoader
{
    return MLNUI_KIT_INSTANCE(self.mlnui_luaCore).instanceHandlersManager.imageLoader;
}

#pragma mark - Method For Lua

- (void)luaui_setFontName:(NSString *)name
{
    [self luaui_setFontName:name location:0 length:self.mutableStyledString.length];
}

- (void)luaui_setFontName:(NSString *)name location:(NSInteger)location length:(NSInteger)length
{
    location = location <= 0 ? 0 : location - 1;
    _statusChanged = YES;
    NSRange newRange = NSMakeRange(location, length);
    if (self.styleElementsDictM.count > 0) {
        NSArray *interRangesArray = [self shouldChangedElementWithNewRange:&newRange];
        if (interRangesArray.count > 0) {
            for (MLNUIStyleElement *element in interRangesArray) {
                element.fontName = name;
            }
        }
    }
    
    if (newRange.length != 0) {
        MLNUIStyleElement *element = [self styleElementWithKey:NSStringFromRange(newRange)];
        element.range = newRange;
        element.fontName = name;
    }
}

- (void)luaui_setFontSize:(CGFloat)size
{
    [self luaui_setFontSize:size location:0 length:self.mutableStyledString.length];
}

- (void)luaui_setFontSize:(CGFloat)size location:(NSInteger)location length:(NSInteger)length
{
    location = location <= 0 ? 0 : location - 1;
    _statusChanged = YES;
    NSRange newRange = NSMakeRange(location, length);
    if (self.styleElementsDictM.count > 0) {
        NSArray *interRangesArray = [self shouldChangedElementWithNewRange:&newRange];
        if (interRangesArray.count > 0) {
            for (MLNUIStyleElement *element in interRangesArray) {
                element.fontSize = size;
            }
        }
    }
    
    if (newRange.length != 0) {
        MLNUIStyleElement *element = [self styleElementWithKey:NSStringFromRange(newRange)];
        element.range = newRange;
        element.fontSize = size;
    }
}

- (void)luaui_setFontColor:(UIColor *)color
{
    MLNUICheckTypeAndNilValue(color, @"Color", [UIColor class])
    [self luaui_setFontColor:color location:0 length:self.mutableStyledString.length];
}

- (void)luaui_setFontColor:(UIColor *)color location:(NSInteger)location length:(NSInteger)length
{
    MLNUICheckTypeAndNilValue(color, @"Color", [UIColor class])
    location = location <= 0 ? 0 : location - 1;
    _statusChanged = YES;
    NSRange newRange = NSMakeRange(location, length);
    NSArray *interRangesArray = [self shouldChangedElementWithNewRange:&newRange];
    
    if (interRangesArray.count > 0) {
        for (MLNUIStyleElement *element in interRangesArray) {
            element.fontColor = color;
        }
    }
    
    if (newRange.length != 0) {
        MLNUIStyleElement *element = [self styleElementWithKey:NSStringFromRange(newRange)];
        element.range = newRange;
        element.fontColor = color;
    }

}


- (void)luaui_setBackgroundColor:(UIColor *)color
{
    MLNUICheckTypeAndNilValue(color, @"Color", UIColor)
    [self luaui_setBackgroundColor:color location:0 length:self.mutableStyledString.length];
}

- (void)luaui_setBackgroundColor:(UIColor *)color location:(NSInteger)location length:(NSInteger)length
{
    MLNUICheckTypeAndNilValue(color, @"Color", UIColor)
    location = location <= 0 ? 0 : location - 1;
    _statusChanged = YES;
    NSRange newRange = NSMakeRange(location, length);
    NSArray *interRangesArray = [self shouldChangedElementWithNewRange:&newRange];
    
    if (interRangesArray.count > 0) {
        for (MLNUIStyleElement *element in interRangesArray) {
            element.backgroundColor = color;
        }
    }
    
    if (newRange.length != 0) {
        MLNUIStyleElement *element = [self styleElementWithKey:NSStringFromRange(newRange)];
        element.range = newRange;
        element.backgroundColor = color;
    }
    
}

- (void)luaui_setFontStyle:(MLNUIFontStyle)style
{
    [self luaui_setFontStyle:style location:0 length:self.mutableStyledString.length];
}

- (void)luaui_setFontStyle:(MLNUIFontStyle)style location:(NSInteger)location length:(NSInteger)length
{
    location = location <= 0 ? 0 : location - 1;
    _statusChanged = YES;
    NSRange newRange = NSMakeRange(location, length);
    NSArray *interRangesArray = [self shouldChangedElementWithNewRange:&newRange];
    
    if (interRangesArray.count > 0) {
        for (MLNUIStyleElement *element in interRangesArray) {
            element.fontStyle = style;
        }
    }
    
    if (newRange.length != 0) {
        MLNUIStyleElement *element = [self styleElementWithKey:NSStringFromRange(newRange)];
        element.range = newRange;
        element.fontStyle = style;
    }
    
}

- (void)luaui_setUnderLineStyle:(MLNUIUnderlineStyle)style
{
    [self luaui_setUnderLineStyle:style location:0 length:self.mutableStyledString.length];
}

- (void)luaui_setUnderLineStyle:(MLNUIUnderlineStyle)style location:(NSInteger)location length:(NSInteger)length
{
    location = location <= 0 ? 0 : location - 1;
    _statusChanged = YES;
    NSRange newRange = NSMakeRange(location, length);
    NSArray *interRangesArray = [self shouldChangedElementWithNewRange:&newRange];
    
    if (interRangesArray.count > 0) {
        for (MLNUIStyleElement *element in interRangesArray) {
            element.underline = style;
        }
    }
    
    if (newRange.length != 0) {
        MLNUIStyleElement *element = [self styleElementWithKey:NSStringFromRange(newRange)];
        element.range = newRange;
        element.underline = style;
    }

}

- (void)luaui_setImageAlignType:(MLNUIStyleImageAlignType)alignType
{
    self.imageAlign = alignType;
}

- (void)luaui_append:(NSMutableAttributedString *)styleString
{
    MLNUICheckTypeAndNilValue(styleString, @"StyleString", [NSMutableAttributedString class])
    if (![styleString isKindOfClass:[NSMutableAttributedString class]]) return;
    if (!styleString || !self.mutableStyledString) return;
    
    MLNUIStyleString *luaui_styleString = styleString.luaui_styleString;
    if (luaui_styleString) {
        for (MLNUIStyleElement *element in luaui_styleString.styleElementsDictM.allValues) {
            MLNUIStyleElement *newElement = element.copy;
            NSRange oldRange = element.range;
            oldRange.location += self.mutableStyledString.length;
            newElement.range = oldRange;
            [self.styleElementsDictM setObject:newElement forKey:NSStringFromRange(newElement.range)];
        }
    }
    [styleString setLuaui_styleString:nil];
    
    [self.mutableStyledString appendAttributedString:[styleString copy]];
    
}

- (id)mlnui_rawNativeData
{
    [self handleStyleStringIfNeed];
    return self.mutableStyledString;
}

- (CGSize)calculateSize:(CGFloat)maxWidth
{
    [self handleStyleStringIfNeed];
    CGSize size = [self.mutableStyledString boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}

- (CGSize)luaui_sizeThatFits:(CGFloat)maxWidth
{
    [self handleStyleStringIfNeed];
    if (!self.mutableStyledString) return CGSizeZero;
    NSMutableAttributedString *drawString = self.mutableStyledString;
    CFAttributedStringRef attributedStringRef = (__bridge_retained CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRelease(attributedStringRef);
    if (!framesetter) {
        // 字符串处理失败
        return CGSizeZero;
    }
    CFRange range = CFRangeMake(0, 0);
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, CGSizeMake(maxWidth, MAXFLOAT), &fitCFRange);
    if (framesetter) {
        CFRelease(framesetter);
    }
    if (newSize.height < 14 * 2) {
        return CGSizeMake(ceilf(newSize.width), ceilf(newSize.height));
    } else {
        return CGSizeMake(maxWidth, ceilf(newSize.height));
    }
}

- (BOOL)luaui_showAsImageWithSize:(CGSize)size
{
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    NSString *imagePathString = self.mutableStyledString.string;
    textAttachment.image = nil;
    textAttachment.bounds = CGRectMake(0, 0, size.width, size.height);
    _mutableStyledString = [NSAttributedString attributedStringWithAttachment:textAttachment].mutableCopy;
    [_mutableStyledString setLuaui_styleString:self];
    MLNUIStyleElement *element = [[MLNUIStyleElement alloc] init];
    element.range = NSMakeRange(0, 1);
    element.imageSize = size;
    element.imagePath = imagePathString;
    element.instance = [self myKitInstance];
    
    [self.styleElementsDictM removeAllObjects];
    [_styleElementsDictM setObject:element forKey:NSStringFromRange(element.range)];
    _statusChanged = YES;
    return textAttachment.image != nil;
}

- (void)luaui_setText:(NSString*)attriteStr {
    attriteStr = attriteStr ?: @"";
    [_mutableStyledString setLuaui_styleString:nil];
    [_styleElementsDictM removeAllObjects];
    _mutableStyledString = [[NSMutableAttributedString alloc]initWithString:attriteStr];
    [_mutableStyledString setLuaui_styleString:self];
    // 设置默认行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    [_mutableStyledString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attriteStr.length)];
}

#pragma mark - Private method
- (UIFont *)lineHeightWithElement:(MLNUIStyleElement *)element
{
    NSArray *sortKeys = [self.styleElementsDictM keysSortedByValueUsingComparator:^NSComparisonResult(MLNUIStyleElement * _Nonnull obj1, MLNUIStyleElement * _Nonnull obj2) {
        if (obj1.range.location < obj2.range.location) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    NSUInteger index = [sortKeys indexOfObjectIdenticalTo:NSStringFromRange(element.range)];
    index = index > 0? index - 1 : index + 1;
    MLNUIStyleElement *styleElement =  nil;
    if (index >= 0 && index < sortKeys.count) {
        styleElement = [self.styleElementsDictM objectForKey:[sortKeys objectAtIndex:index]];
    }
    if (!styleElement) {
        styleElement = element;
    }
    return [MLNUIFont fontWithFontName:styleElement.fontName fontStyle:styleElement.fontStyle fontSize:styleElement.fontSize instance:[self myKitInstance]];
}

- (MLNUIKitInstance *)myKitInstance
{
    return MLNUI_KIT_INSTANCE(self.mlnui_luaCore);
}

#pragma mark - Export For Lua
LUAUI_EXPORT_BEGIN(MLNUIStyleString)
LUAUI_EXPORT_METHOD(fontName,"luaui_setFontName:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(setFontNameForRange,"luaui_setFontName:location:length:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(fontSize,"luaui_setFontSize:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(setFontSizeForRange,"luaui_setFontSize:location:length:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(fontStyle,"luaui_setFontStyle:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(setFontStyleForRange,"luaui_setFontStyle:location:length:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(fontColor,"luaui_setFontColor:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(setFontColorForRange,"luaui_setFontColor:location:length:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(backgroundColor,"luaui_setBackgroundColor:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(setBackgroundColorForRange,"luaui_setBackgroundColor:location:length:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(underline,"luaui_setUnderLineStyle:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(setUnderlineForRange,"luaui_setUnderLineStyle:location:length:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(showAsImage,"luaui_showAsImageWithSize:",MLNUIStyleString)
LUAUI_EXPORT_METHOD(append, "luaui_append:", MLNUIStyleString)
LUAUI_EXPORT_METHOD(calculateSize, "calculateSize:", MLNUIStyleString)
LUAUI_EXPORT_METHOD(sizeThatFits, "luaui_sizeThatFits:", MLNUIStyleString)
LUAUI_EXPORT_METHOD(setText, "luaui_setText:", MLNUIStyleString)
LUAUI_EXPORT_METHOD(imageAlign, "luaui_setImageAlignType:", MLNUIStyleString)
LUAUI_EXPORT_END(MLNUIStyleString, StyleString, NO, NULL, "initWithMLNUILuaCore:string:")

@end

