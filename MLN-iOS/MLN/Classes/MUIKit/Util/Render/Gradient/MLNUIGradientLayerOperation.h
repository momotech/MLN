//
//  MLNUIGradientLayerTask.h
//  MMLNUIua
//
//  Created by MoMo on 2019/4/16.
//

#import <UIKit/UIKit.h>
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIGradientLayerOperation : NSObject

- (instancetype)initWithTargetView:(UIView *)targetView;

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic, assign) BOOL needRemake;
@property (nonatomic, strong, nullable) UIColor *startColor;
@property (nonatomic, strong, nullable) UIColor *endColor;
@property (nonatomic, assign) MLNUIGradientType direction;

- (void)remakeIfNeed;
- (void)cleanGradientLayerIfNeed;

@end

NS_ASSUME_NONNULL_END
