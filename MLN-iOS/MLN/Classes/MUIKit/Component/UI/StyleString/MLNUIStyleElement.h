//
//  MLNUIStyleElement.h
//
//
//  Created by MoMo on 2019/4/25.
//

#import <Foundation/Foundation.h>
#import "MLNUITextConst.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNUIKitInstance;
@interface MLNUIStyleElement : NSObject<NSCopying>

@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) MLNUIFontStyle fontStyle;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) MLNUIUnderlineStyle underline;
@property (nonatomic, assign) NSRange range;

@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong, readonly) NSDictionary *attributes;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, weak) MLNUIKitInstance *instance;

@end

NS_ASSUME_NONNULL_END
