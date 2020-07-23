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

@property (nonatomic, assign) CGFloat luaui_width;
@property (nonatomic, assign) CGFloat luaui_height;
@property (nonatomic, assign) CGFloat luaui_bottom;
@property (nonatomic, assign) CGFloat luaui_right;
@property (nonatomic, assign) CGRect luaui_frame;
@property (nonatomic, assign) BOOL luaui_enable;

- (CGPoint)luaui_convertRelativePointToView:(UIView *)view point:(CGPoint)point;

#pragma mark - TouchEvent
@property (nonatomic, strong) MLNUIBlock *mlnui_touchesBeganCallback;
@property (nonatomic, strong) MLNUIBlock *mlnui_touchesMovedCallback;
@property (nonatomic, strong) MLNUIBlock *mlnui_touchesEndedCallback;
@property (nonatomic, strong) MLNUIBlock *mlnui_touchesCancelledCallback;
@property (nonatomic, strong) MLNUIBlock *mlnui_touchesBeganExtensionCallback;
@property (nonatomic, strong) MLNUIBlock *mlnui_touchesMovedExtensionCallback;
@property (nonatomic, strong) MLNUIBlock *mlnui_touchesEndedExtensionCallback;
@property (nonatomic, strong) MLNUIBlock *mlnui_touchesCancelledExtensionCallback;

#pragma mark - render
@property (nonatomic, assign, readonly) BOOL mlnui_needRender;
@property (nonatomic, strong, readonly) MLNUIRenderContext *mlnui_renderContext;

#pragma mark - Gesture
@property (nonatomic, strong) MLNUIBlock * mlnui_tapClickBlock;
@property (nonatomic, strong) MLNUIBlock * mlnui_touchClickBlock;
@property (nonatomic, strong) MLNUIBlock * mlnui_longPressBlock;

- (void)luaui_addClick:(MLNUIBlock *)clickCallback;
- (void)luaui_addTouch:(MLNUIBlock *)touchCallBack;
- (void)luaui_addLongPress:(MLNUIBlock *)longPressCallback;
/**
 Return YES if it can respond to tap events. Default is NO
 */
- (BOOL)luaui_canClick;
/**
 Return YES if it can respond to long press events. Default is NO
 */
- (BOOL)luaui_canLongPress;

- (void)mlnui_addTouchBlock:(MLNUITouchCallback)block;
- (void)mlnui_removeTouchBlock:(MLNUITouchCallback)block;

#pragma mark - Render
- (void)luaui_setCornerRadius:(CGFloat)cornerRadius;
- (void)luaui_addCornerMaskWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(MLNUIRectCorner)corners;
- (void)mlnui_updateCornersIfNeed;
- (void)mlnui_updateGradientLayerIfNeed;

#pragma mark - Focus

/**
 请求焦点
 */
- (void)luaui_requestFocus;

/**
 如果需要就重置Transform
 */
- (void)luaui_resetTransformIfNeed;

@end

@interface UIView(Snapshot)

/**
 对当前视图截图，并将图片按指定文件名称存贮。

 @param fileName 截图存储的指定文件名称
 @return 文件存储的路径
 */
- (NSString *)luaui_snapshotWithFileName:(NSString *)fileName;

@end

@interface UIView (Layout)

// override and return YES, if is container view.
@property (nonatomic, assign, readonly) BOOL luaui_isContainer;

@end

/**
 很多场景下，如果你要做的一些操作，需要依赖于MLNUI布局之后，请使用以下方法
 */
@interface UIView (LazyTask)

/**
 压栈自动布局完成以后执行的任务
 
 @param lazyTask 延迟执行任务
 */
- (void)mlnui_pushLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask;

/**
 出栈自动布局完成以后执行的任务
 
 @param lazyTask 延迟执行任务
 */
- (void)mlnui_popLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask;

/**
 压栈自动布局完成以后执行的动画任务，时机晚于LazyTask
 
 @param animation 动画任务，时机晚于LazyTask
 */
- (void)mlnui_pushAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation;

/**
 出栈自动布局完成以后执行的动画任务，时机晚于LazyTask
 
 @param animation 动画任务，时机晚于LazyTask
 */
- (void)mlnui_popAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation;

/**
 压栈自动布局完成以后执行的渲染任务，时机晚于动画任务
 
 @param renderTask 渲染任务，时机晚于动画任务
 */
- (void)mlnui_pushRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask;

/**
 出栈自动布局完成以后执行的渲染任务，时机晚于动画任务
 
 @param renderTask 渲染任务，时机晚于动画任务
 */
- (void)mlnui_popRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask;

@end

NS_ASSUME_NONNULL_END
