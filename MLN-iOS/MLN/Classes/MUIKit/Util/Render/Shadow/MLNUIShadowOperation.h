//
//  MLNUIShadowOperation.h
//
//
//  Created by MoMo on 2019/3/20.
//

#import <Foundation/Foundation.h>
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIShadowOperation : NSObject


- (instancetype)initWithTargetView:(UIView *)targetView;

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic, assign) BOOL needRemake;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat shadowOpcity;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) BOOL oval;
@property (nonatomic, assign) MLNUICornerRadius multiRadius;

- (void)remakeIfNeed;
- (void)cleanShadowLayerIfNeed;
- (void)updateCornerRadiusAndRemake:(MLNUICornerRadius)radius;

@end

NS_ASSUME_NONNULL_END
