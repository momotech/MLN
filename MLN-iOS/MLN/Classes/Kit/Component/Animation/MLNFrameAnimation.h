//
//  MLNFrameAnimation.h
//
//
//  Created by MoMo on 2018/11/14.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"
#import "MLNBeforeWaitingTaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNBlock;
@interface MLNFrameAnimation : NSObject <MLNEntityExportProtocol, MLNBeforeWaitingTaskProtocol>

@property (nonatomic, assign) CGFloat translationStartX;
@property (nonatomic, assign) CGFloat translationEndX;
@property (nonatomic, assign) CGFloat translationStartY;
@property (nonatomic, assign) CGFloat translationEndY;
@property (nonatomic, assign) CGFloat translationStartCenterX;
@property (nonatomic, assign) CGFloat translationEndCenterX;
@property (nonatomic, assign) CGFloat translationStartCenterY;
@property (nonatomic, assign) CGFloat translationEndCenterY;
@property (nonatomic, assign) CGFloat scaleStartWidth;
@property (nonatomic, assign) CGFloat scaleEndWidth;
@property (nonatomic, assign) CGFloat scaleStartHeight;
@property (nonatomic, assign) CGFloat scaleEndHeight;
@property (nonatomic, assign) CGFloat startAlpha;
@property (nonatomic, assign) CGFloat endAlpha;
@property (nonatomic, strong) UIColor *startBgColor;
@property (nonatomic, strong) UIColor *endBgColor;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) UIViewAnimationOptions options;
@property (nonatomic, strong) MLNBlock *completionCallback;

- (void)lua_startWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
