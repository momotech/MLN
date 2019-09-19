//
//  MLNGradientLayerTask.h
//  MMLNua
//
//  Created by MoMo on 2019/4/16.
//

#import <UIKit/UIKit.h>
#import "MLNViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNGradientLayerOperation : NSObject

- (instancetype)initWithTargetView:(UIView *)targetView;

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic, assign) BOOL needRemake;
@property (nonatomic, strong, nullable) UIColor *startColor;
@property (nonatomic, strong, nullable) UIColor *endColor;
@property (nonatomic, assign) MLNGradientType direction;

- (void)remakeIfNeed;
- (void)cleanGradientLayerIfNeed;

@end

NS_ASSUME_NONNULL_END
