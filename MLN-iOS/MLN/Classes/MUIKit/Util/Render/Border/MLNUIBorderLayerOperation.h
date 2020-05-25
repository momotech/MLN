//
//  MLNBorderLayerOperation.h
//  MLN
//
//  Created by MoMo on 2019/8/14.
//

#import <Foundation/Foundation.h>
#import "MLNViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNBorderLayerOperation : NSObject

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic, assign) BOOL needRemake;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) MLNCornerRadius multiRadius;

- (instancetype)initWithTargetView:(UIView *)targetView;
- (void)remakeIfNeed;
- (void)cleanBorderLayerIfNeed;
- (void)updateCornerRadiusAndRemake:(MLNCornerRadius)radius;

@end

NS_ASSUME_NONNULL_END
