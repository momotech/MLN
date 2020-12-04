//
//  MLNUIGestureRecognizer.h
//  ArgoUI
//
//  Created by MOMO on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNUIGestureRecogizerDelegate <NSObject>

/// 通过访问该属性来替代`state`.
@property (readonly) UIGestureRecognizerState argoui_state;

/// 手势识别器 (UIGestureRecognizer) 通过调用此方法来主动触发手势的 action.
- (void)argoui_handleTargetActions;

@end

@interface MLNUIGestureRecognizer : NSObject

- (void)addTarget:(id)target action:(SEL)action;
- (void)removeTarget:(id)target action:(SEL)action;
- (void)handleTargetActionsWithGestureRecognizer:(__kindof UIGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
