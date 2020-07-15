//
//  UIView+MLNUILayoutNode.h
//  MLN
//
//  Created by MOMO on 2020/5/29.
//

#import <UIKit/UIKit.h>
#import "MLNUILayoutNode.h"
#import "MLNUIPaddingContainerViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MLNUILayout)<MLNUIPaddingContainerViewProtocol>

- (Class)mlnui_bindedLayoutNodeClass;
@property (nonatomic, strong, readonly) MLNUILayoutNode *mlnui_layoutNode;

/// 可重写该属性get方法. 若返回NO, 则不会参与测量布局计算, 也不会关联`mlnui_layoutNode`. 默认为NO.
@property (nonatomic, assign, readonly) BOOL mlnui_layoutEnable;
@property (nonatomic, assign, readonly) BOOL mlnui_isRootView;   // default is NO
@property (nonatomic, assign, readonly) BOOL mlnui_resetOriginAfterLayout; // default is YES.

#pragma mark - Hierarchy

- (void)luaui_addSubview:(UIView *)view;
- (void)luaui_insertSubview:(UIView *)view atIndex:(NSInteger)index;
- (void)luaui_removeFromSuperview;
- (void)luaui_removeAllSubViews;

#pragma mark - Layout

- (void)luaui_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;
@property (nonatomic, assign) CGFloat luaui_paddingTop;
@property (nonatomic, assign) CGFloat luaui_paddingLeft;
@property (nonatomic, assign) CGFloat luaui_paddingRight;
@property (nonatomic, assign) CGFloat luaui_paddingBottom;
@property (nonatomic, assign) BOOL luaui_display;

- (void)mlnui_markNeedsLayout;
- (void)mlnui_requestLayoutIfNeed;
- (void)mlnui_requestLayoutIfNeedWithSize:(CGSize)size; // constraint size

/**
 * 当时视图的Frame发生变更时被调用，如果在视图Frame变更时，需要处理自己的事件，可以重写该方法。
 * @warning 不可以主动调用该方法！
 */
- (void)mlnui_layoutDidChange NS_REQUIRES_SUPER;

/**
 * 当视图的布局完成后被调用。如果在视图布局完成后，需要处理自己的事件，可以重写该方法。
 * @note 无论frame是否变更，都会调用该方法。
 * @warning 不可以主动调用该方法！
 */
- (void)mlnui_layoutCompleted NS_REQUIRES_SUPER;

/// 用于测量叶子节点视图大小, 子类应该覆盖该方法
- (CGSize)mlnui_sizeThatFits:(CGSize)size;

@end

@interface UIView (MLNUIFrame)

@property (nonatomic, assign) CGFloat mlnuiAnimationX;
@property (nonatomic, assign) CGFloat mlnuiAnimationY;
@property (nonatomic, assign) CGFloat mlnuiAnimationWidth;
@property (nonatomic, assign) CGFloat mlnuiAnimationHeight;
@property (nonatomic, assign) CGPoint mlnuiAnimationCenter;
@property (nonatomic, assign) CGRect mlnuiAnimationFrame;

@property (nonatomic, assign) CGFloat mlnuiLayoutX;
@property (nonatomic, assign) CGFloat mlnuiLayoutY;
@property (nonatomic, assign) CGFloat mlnuiLayoutWidth;
@property (nonatomic, assign) CGFloat mlnuiLayoutHeight;
@property (nonatomic, assign) CGRect mlnuiLayoutFrame;

@end

NS_ASSUME_NONNULL_END
