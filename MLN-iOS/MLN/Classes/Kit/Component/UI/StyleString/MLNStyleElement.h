//
//  MLNStyleElement.h
//
//
//  Created by MoMo on 2019/4/25.
//

#import <Foundation/Foundation.h>
#import "MLNTextConst.h"
#import "MLNBlock.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNKitInstance;
@interface MLNStyleElement : NSObject<NSCopying>

@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) MLNFontStyle fontStyle;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) MLNUnderlineStyle underline;
@property (nonatomic, assign) NSRange range;

@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong, readonly) NSDictionary *attributes;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, weak) MLNKitInstance *instance;
@property (nonatomic, strong) MLNBlock *linkCallBack;

@end

NS_ASSUME_NONNULL_END
