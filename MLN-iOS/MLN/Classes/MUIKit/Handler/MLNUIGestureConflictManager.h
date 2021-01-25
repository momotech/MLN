//
//  MLNUIGestureConflictManager.h
//  ArgoUI
//
//  Created by MOMO on 2020/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIGestureConflictManager : NSObject

/// 响应当前手势的视图
+ (__kindof UIView *_Nullable)currentGestureResponder;

/// 在手势开始时设置，在手势结束时置空
/// @Note 需要成对调用
+ (void)setCurrentGesture:(UIGestureRecognizer *_Nullable)gesture;

/// 是否允许子视图接受手势响应，会更新手势响应者
/// @param disable YES表示禁止子视图接受手势响应
/// @param view 该view的子视图是否接受手势响应
+ (void)disableSubviewsInteraction:(BOOL)disable forView:(UIView *)view;

/// 存在手势冲突时，执行responder手势的action
/// @param gesture 当下系统实际响应的手势，但不应该允许其执行action，而应执行responder手势的action.
+ (void)handleResponderGestureActionsWithCurrentGesture:(UIGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
