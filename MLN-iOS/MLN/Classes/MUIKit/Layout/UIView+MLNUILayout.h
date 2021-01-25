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

/// 是否参与Node测量布局。若返回NO，则不会参与测量布局计算，也不会关联`mlnui_layoutNode`。默认为NO。 \b 可重写get方法。
@property (nonatomic, assign, readonly) BOOL mlnui_layoutEnable;

/// 是否为根视图。若为根视图，则其节点为根节点。eg: MLNUITableViewCell。默认为NO。\b 可重写get方法。
@property (nonatomic, assign, readonly) BOOL mlnui_isRootView;

/// 是否允许虚拟布局。目前只有 HStack 和 VStack 以及 Spacer 允许虚拟布局。默认为NO。 \b 可重写get方法。
@property (nonatomic, assign, readonly) BOOL mlnui_allowVirtualLayout;

/// 当前视图是否为虚拟视图（不参与视图层级渲染）
- (BOOL)mlnui_isVirtualView;

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

/// 当时视图的Frame发生变更时被调用，如果在视图Frame变更时，需要处理自己的事件，可以重写该方法。
- (void)mlnui_layoutDidChange NS_REQUIRES_SUPER;

/// 当视图的布局完成后被调用。如果在视图布局完成后，需要处理自己的事件，可以重写该方法。
/// @Note 无论frame是否变更，都会调用该方法。
- (void)mlnui_layoutCompleted NS_REQUIRES_SUPER;

/// 用于测量叶子节点视图大小, 子类应该覆盖该方法
- (CGSize)mlnui_sizeThatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
