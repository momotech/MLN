//
//  MLNFont.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import <UIKit/UIKit.h>
#import "MLNTextConst.h"

@interface MLNFont : NSObject

+ (UIFont *)fontWithFontName:(NSString *)fontName fontStyle:(MLNFontStyle)style fontSize:(CGFloat)fontSize;

@end
