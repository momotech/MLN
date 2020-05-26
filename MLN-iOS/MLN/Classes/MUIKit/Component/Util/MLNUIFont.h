//
//  MLNUIFont.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import <UIKit/UIKit.h>
#import "MLNUITextConst.h"

@class MLNUIKitInstance;
@interface MLNUIFont : NSObject

+ (UIFont *)fontWithFontName:(NSString *)fontName fontStyle:(MLNUIFontStyle)style fontSize:(CGFloat)fontSize instance:(MLNUIKitInstance *)instance;

@end
