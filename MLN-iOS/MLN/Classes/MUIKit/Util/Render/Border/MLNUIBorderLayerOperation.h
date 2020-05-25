//
//  MLNUIBorderLayerOperation.h
//  MLNUI
//
//  Created by MoMo on 2019/8/14.
//

#import <Foundation/Foundation.h>
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIBorderLayerOperation : NSObject

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic, assign) BOOL needRemake;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) MLNUICornerRadius multiRadius;

- (instancetype)initWithTargetView:(UIView *)targetView;
- (void)remakeIfNeed;
- (void)cleanBorderLayerIfNeed;
- (void)updateCornerRadiusAndRemake:(MLNUICornerRadius)radius;

@end

NS_ASSUME_NONNULL_END
