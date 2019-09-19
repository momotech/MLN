//
//  MLNKeyboardViewHandler.h
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef CGFloat(^MLNPositionAdjustOffsetYCallBack)(CGFloat keyboardHeight);

@interface MLNKeyboardViewHandler : NSObject

@property (nonatomic, assign) BOOL positionAdjust;
@property (nonatomic, assign) CGFloat positionAdjustOffsetY;
@property (nonatomic, assign) CGRect beforePositionAdjustViewFrame;
@property (nonatomic, copy) MLNPositionAdjustOffsetYCallBack positionBack;
@property (nonatomic, assign) BOOL alwaysAdjustPositionKeyboardCoverView;

- (instancetype)initWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
