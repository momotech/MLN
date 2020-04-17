//
//  UIView+MLNLayout.h
//
//
//  Created by MoMo on 2018/10/26.
//

#import <UIKit/UIKit.h>
#import "MLNViewConst.h"
#import "MLNPaddingContainerViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNLayoutNode;
@interface UIView (MLNLayout) <MLNPaddingContainerViewProtocol>

@property (nonatomic, assign) CGFloat lua_marginTop;
@property (nonatomic, assign) CGFloat lua_marginLeft;
@property (nonatomic, assign) CGFloat lua_marginBottom;
@property (nonatomic, assign) CGFloat lua_marginRight;
@property (nonatomic, assign) CGFloat lua_minWidth;
@property (nonatomic, assign) CGFloat lua_minHeight;
@property (nonatomic, assign) CGFloat lua_maxWidth;
@property (nonatomic, assign) CGFloat lua_maxHieght;
@property (nonatomic, assign) BOOL lua_gone;
@property (nonatomic, assign) MLNGravity lua_gravity;
@property (nonatomic, assign) CGFloat lua_priority;
@property (nonatomic, assign) int lua_weight;
@property (nonatomic, assign, getter=isLua_wrapContent) BOOL lua_wrapContent;
@property (nonatomic, assign) BOOL lua_layoutEnable; // defualt is NO
@property (nonatomic, assign, readonly) BOOL lua_isContainer; // defualt is NO
@property (nonatomic, strong, readonly) MLNLayoutNode *lua_node;

- (BOOL)lua_clipsToBounds;
- (void)lua_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

- (void)lua_addSubview:(UIView *)view;
- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index;
- (void)lua_removeFromSuperview;
- (void)lua_removeAllSubViews;
- (void)lua_overlay:(UIView *)overlay;

/**
 标注当前视图需要重新布局，只影响当前视图。
 */
- (void)lua_needLayout;

/**
 标注当前视图需要重新布局，并且检查父视图是否需要重新布局。
 */
- (void)lua_needLayoutAndSpread;

/**
 请求重新计算布局，并立即执行。
 */
- (void)lua_requestLayout;

/**
 请求布局，如果需要更新则立即重新计算布局，否则不做处理。
 */
- (void)lua_requestLayoutIfNeed;

/**
 测量当前视图的大小，如果你需要处理视图的测量方式，你可以重写该方法。

 @param maxWidth 可布局的最大宽度
 @param maxHeight 可布局的最大高度
 @return 测量后的大小
 */
- (CGSize)lua_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;

/**
 当内部Padding需要更新时候被调用，如果你需要自己处理padding，可以重写该方法。
 
 @warning 不可以主动调用该方法！
 */
- (void)lua_onUpdateForPadding;

/**
 当时视图的Frame发生变更时被调用，如果在视图Frame变更时，需要处理自己的事件，可以重写该方法。
 
 @warning 不可以主动调用该方法！
 */
- (void)lua_changedLayout NS_REQUIRES_SUPER;

/**
 当视图的布局完成后被调用。如果在视图布局完成后，需要处理自己的事件，可以重写该方法。
 
 @note 无论Frame是否变更，该方法都会被调用。
 @warning 不可以主动调用该方法！
 */
- (void)lua_layoutCompleted NS_REQUIRES_SUPER;

/**
 开启自动布局
 */
- (void)mln_startAutoLayout;

/**
 关闭自动布局
 */
- (void)mln_stopAutoLayout;

@end

NS_ASSUME_NONNULL_END
