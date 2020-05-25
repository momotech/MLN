//
//  UIView+MLNUIKit.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import <UIKit/UIKit.h>
#import "UIView+MLNUICore.h"
#import "MLNUIViewConst.h"
#import "MLNUIBeforeWaitingTaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNUIBlock;
@class MLNUIKeyboardViewHandler;
@class MLNUIRenderContext;
@interface UIView (MLNUIKit)

@property (nonatomic, assign) CGFloat lua_x;
@property (nonatomic, assign) CGFloat lua_y;
@property (nonatomic, assign) CGFloat lua_width;
@property (nonatomic, assign) CGFloat lua_height;
@property (nonatomic, assign) CGFloat lua_bottom;
@property (nonatomic, assign) CGFloat lua_right;
@property (nonatomic, assign) CGRect lua_frame;
@property (nonatomic, assign) BOOL lua_enable;

- (void)lua_layoutIfNeed;
- (void)lua_sizeToFit;
- (CGPoint)lua_convertRelativePointToView:(UIView *)view point:(CGPoint)point;

#pragma mark - TouchEvent
@property (nonatomic, strong) MLNUIBlock *mln_touchesBeganCallback;
@property (nonatomic, strong) MLNUIBlock *mln_touchesMovedCallback;
@property (nonatomic, strong) MLNUIBlock *mln_touchesEndedCallback;
@property (nonatomic, strong) MLNUIBlock *mln_touchesCancelledCallback;
@property (nonatomic, strong) MLNUIBlock *mln_touchesBeganExtensionCallback;
@property (nonatomic, strong) MLNUIBlock *mln_touchesMovedExtensionCallback;
@property (nonatomic, strong) MLNUIBlock *mln_touchesEndedExtensionCallback;
@property (nonatomic, strong) MLNUIBlock *mln_touchesCancelledExtensionCallback;

#pragma mark - render
@property (nonatomic, strong, readonly) MLNUIRenderContext *mln_renderContext;

#pragma mark - Gesture
@property (nonatomic, strong) MLNUIBlock * mln_tapClickBlock;
@property (nonatomic, strong) MLNUIBlock * mln_touchClickBlock;
@property (nonatomic, strong) MLNUIBlock * mln_longPressBlock;

- (void)lua_addClick:(MLNUIBlock *)clickCallback;
- (void)lua_addTouch:(MLNUIBlock *)touchCallBack;
- (void)lua_addLongPress:(MLNUIBlock *)longPressCallback;
/**
 Return YES if it can respond to tap events. Default is NO
 */
- (BOOL)lua_canClick;
/**
 Return YES if it can respond to long press events. Default is NO
 */
- (BOOL)lua_canLongPress;

#pragma mark - Render
- (void)lua_setCornerRadius:(CGFloat)cornerRadius;
- (void)lua_addCornerMaskWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(MLNUIRectCorner)corners;
- (void)mln_updateCornersIfNeed;
- (void)mln_updateGradientLayerIfNeed;

#pragma mark - Focus

/**
 请求焦点
 */
- (void)lua_requestFocus;

#pragma mark - Keyboard

/**
 * keyboardHandler 处理键盘偏移相关
 **/
@property (nonatomic, strong) MLNUIKeyboardViewHandler *lua_keyboardViewHandler;

/**
 键盘出现自动上移View
 
 @param bAdjust 是否上移
 */
- (void)lua_setPositionAdjustForKeyboard:(BOOL)bAdjust;

/**
 键盘出现自动上移View
 
 @param bAdjust 是否上移（默认上移键盘高度
 @param offsetY  数值方向偏移（默认为0
 */
- (void)lua_setPositionAdjustForKeyboard:(BOOL)bAdjust offsetY:(CGFloat)offsetY;

/**
 键盘出现自动上移View 源生
 
 @param bAdjust 是否上移（默认上移键盘高度
 @param offsetY  数值方向偏移（默认为0
 **/
- (void)mln_in_setPositionAdjustForKeyboard:(BOOL)bAdjust offsetY:(CGFloat)offsetY;

/**
 如果需要就重置Transform
 */
- (void)lua_resetTransformIfNeed;

@end

@interface UIView(Snapshot)

/**
 对当前视图截图，并将图片按指定文件名称存贮。

 @param fileName 截图存储的指定文件名称
 @return 文件存储的路径
 */
- (NSString *)lua_snapshotWithFileName:(NSString *)fileName;

@end

@interface UIView (Layout)

// override and return YES, if is container view.
@property (nonatomic, assign, readonly) BOOL lua_isContainer;

@end

/**
 很多场景下，如果你要做的一些操作，需要依赖于MLNUI布局之后，请使用以下方法
 */
@interface UIView (LazyTask)

/**
 压栈自动布局完成以后执行的任务
 
 @param lazyTask 延迟执行任务
 */
- (void)mln_pushLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask;

/**
 出栈自动布局完成以后执行的任务
 
 @param lazyTask 延迟执行任务
 */
- (void)mln_popLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask;

/**
 压栈自动布局完成以后执行的动画任务，时机晚于LazyTask
 
 @param animation 动画任务，时机晚于LazyTask
 */
- (void)mln_pushAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation;

/**
 出栈自动布局完成以后执行的动画任务，时机晚于LazyTask
 
 @param animation 动画任务，时机晚于LazyTask
 */
- (void)mln_popAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation;

/**
 压栈自动布局完成以后执行的渲染任务，时机晚于动画任务
 
 @param renderTask 渲染任务，时机晚于动画任务
 */
- (void)mln_pushRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask;

/**
 出栈自动布局完成以后执行的渲染任务，时机晚于动画任务
 
 @param renderTask 渲染任务，时机晚于动画任务
 */
- (void)mln_popRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask;

@end

NS_ASSUME_NONNULL_END
