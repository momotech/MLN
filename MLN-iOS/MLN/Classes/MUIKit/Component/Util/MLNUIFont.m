//
//  MLNFont.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import "MLNFont.h"
#import "MLNKitHeader.h"

@implementation MLNFont

+ (UIFont *)fontWithFontName:(NSString *)fontName fontStyle:(MLNFontStyle)style fontSize:(CGFloat)fontSize instance:(MLNKitInstance *)instance
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = nil;
    
    if (!fontName) {
        fontDescriptor = [font fontDescriptor];
    } else {
        MLNLuaAssert(instance.luaCore, [self isFontRegistered:fontName], @"Font is not registered! ! !");
        if ([self isFontRegistered:fontName]) {
            fontDescriptor = [UIFontDescriptor fontDescriptorWithName:fontName size:fontSize];
        } else {
            fontDescriptor = [font fontDescriptor];
        }
    }
   
    switch (style) {
        case MLNFontStyleBold:{
            UIFontDescriptorSymbolicTraits traits = [fontDescriptor symbolicTraits];
            traits |= UIFontDescriptorTraitBold;
            fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:traits];
            break;
        }
        case MLNFontStyleItalic:{
            CGAffineTransform matrix =CGAffineTransformMake(1, 0, tanf(5 * (CGFloat)M_PI / 180), 1, 0, 0);
            fontDescriptor = [fontDescriptor fontDescriptorWithMatrix:matrix];
            break;
        }
        case MLNFontStyleBoldItalic:{
            UIFontDescriptorSymbolicTraits traits = [fontDescriptor symbolicTraits];
            traits |= UIFontDescriptorTraitBold;
            fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:traits];
            CGAffineTransform matrix =CGAffineTransformMake(1, 0, tanf(5 * (CGFloat)M_PI / 180), 1, 0, 0);
            fontDescriptor = [fontDescriptor fontDescriptorWithMatrix:matrix];
            break;
        }
        default:
            break;
    }
    
    if (@available(iOS 7.0, *)) {
        font = [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
    } else {
        MLNLuaAssert(instance.luaCore,NO, @"Unsupported version of the system below 7.0！！！");
    }
    
    return font;
}

#pragma mark - private method
+ (BOOL)isFontRegistered:(NSString *)fontName
{
    UIFont* aFont = [UIFont fontWithName:fontName size:12.0];
    BOOL isRegistered = (aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame));
    return isRegistered;
}
@end
