//
//  MLNUITextAlign.h
//  
//
//  Created by MoMo on 2018/7/5.
//

#import <UIKit/UIKit.h>
#import "MLNUIGlobalVarExportProtocol.h"

#define kLuaDefaultFontSize 14
#define kLuaDefaultPlaceHolderColor [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.00]
#define kLuaDefaultFont [UIFont systemFontOfSize:kLuaDefaultFontSize]

typedef enum : NSUInteger {
    MLNUIFontStyleDefault = 0,
    MLNUIFontStyleBold,
    MLNUIFontStyleItalic,
    MLNUIFontStyleBoldItalic
} MLNUIFontStyle;

typedef enum : NSInteger {
    MLNUIUnderlineStyleClean = -1,
    MLNUIUnderlineStyleNone = 0,
    MLNUIUnderlineStyleSingle = 1,
} MLNUIUnderlineStyle;

@interface MLNUITextConst : NSObject <MLNUIGlobalVarExportProtocol>

@end
