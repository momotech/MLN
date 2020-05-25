//
//  MLNUIKeyboardViewHandler.h
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef CGFloat(^MLNUIPositionAdjustOffsetYCallBack)(CGFloat keyboardHeight);

@interface MLNUIKeyboardViewHandler : NSObject

@property (nonatomic, assign) BOOL positionAdjust;
@property (nonatomic, assign) CGFloat positionAdjustOffsetY;
@property (nonatomic, assign) CGRect beforePositionAdjustViewFrame;
@property (nonatomic, copy) MLNUIPositionAdjustOffsetYCallBack positionBack;
@property (nonatomic, assign) BOOL alwaysAdjustPositionKeyboardCoverView;

- (instancetype)initWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
