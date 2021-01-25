//
//  UIView+AKFrame.h
//  ArgoKit
//
//  Created by MOMO on 2020/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (AKFrame)

@property (nonatomic, assign) CGFloat akAnimationX;
@property (nonatomic, assign) CGFloat akAnimationY;
@property (nonatomic, assign) CGFloat akAnimationWidth;
@property (nonatomic, assign) CGFloat akAnimationHeight;
@property (nonatomic, assign) CGPoint akAnimationPosition; // @Note 相对于原点而不是锚点
@property (nonatomic, assign) CGRect akAnimationFrame;

@property (nonatomic, assign) CGRect akLayoutFrame;

@end

NS_ASSUME_NONNULL_END
