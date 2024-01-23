//
//  MLNTextAlign.h
//  
//
//  Created by MoMo on 2018/7/5.
//

#import <UIKit/UIKit.h>
#import "MLNGlobalVarExportProtocol.h"

#define kLuaDefaultFontSize 14
#define kLuaDefaultPlaceHolderColor [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.00]
#define kLuaDefaultFont [UIFont systemFontOfSize:kLuaDefaultFontSize]

typedef enum : NSUInteger {
    MLNFontStyleDefault = 0,
    MLNFontStyleBold,
    MLNFontStyleItalic,
    MLNFontStyleBoldItalic
} MLNFontStyle;

typedef enum : NSUInteger {
    MLNUnderlineStyleClean = -1,
    MLNUnderlineStyleNone = 0,
    MLNUnderlineStyleSingle = 1,
} MLNUnderlineStyle;

@interface MLNTextConst : NSObject <MLNGlobalVarExportProtocol>

@end
