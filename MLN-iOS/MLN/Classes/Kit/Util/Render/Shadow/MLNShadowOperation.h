//
//  MLNShadowOperation.h
//
//
//  Created by MoMo on 2019/3/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNShadowOperation : NSObject


- (instancetype)initWithTargetView:(UIView *)targetView;

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic, assign) BOOL needRemake;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat shadowOpcity;
@property (nonatomic, assign) CGFloat shadowRadius;

- (void)remakeIfNeed;
- (void)cleanShadowLayerIfNeed;

@end

NS_ASSUME_NONNULL_END
