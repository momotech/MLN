//
//  UIView+MLNUILayout.m
//
//
//  Created by MoMo on 2018/10/26.
//

#import "UIView+MLNUILayout.h"
#import <objc/runtime.h>
#import "MLNUIKitHeader.h"
#import "MLNUILayoutNode.h"
#import "MLNUILayoutContainerNode.h"
#import "MLNUILayoutNodeFactory.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIRenderContext.h"

@implementation UIView (MLNUILayout)

- (void)mlnui_user_data_dealloc
{
    [super mlnui_user_data_dealloc];
    // 如果是归属于lua的视图，在对应UserData被GC时候，应该从界面上移除
    if (self.mlnui_isLuaObject) {
        [self luaui_removeFromSuperview];
        if (self.luaui_isContainer) {
            [self luaui_removeAllSubViews];
        }
    }
}

#pragma mark - View Tree
- (UIView *)luaui_superview
{
    if (![self.superview mlnui_isConvertible]) {
        return nil;
    }
    
    return self.superview;
}

- (void)luaui_addSubview:(UIView *)view
{
    //    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    [self addSubview:view];
    // 添加Lua强引用
    MLNUI_Lua_UserData_Retain_With_Index(2, view);
    if (view.luaui_node) {
        [(MLNUILayoutContainerNode *)self.luaui_node addSubnode:view.luaui_node];
    }
    
    // 添加overlay
    [view mlnui_addOverlayIfNeeded];
}

- (void)luaui_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    index = index - 1;
    index = index >= 0 && index < self.subviews.count? index : self.subviews.count;
    [self insertSubview:view atIndex:index];
    // 添加Lua强引用
    MLNUI_Lua_UserData_Retain_With_Index(2, view);
    if (view.luaui_node) {
        [(MLNUILayoutContainerNode *)self.luaui_node insertSubnode:view.luaui_node atIndex:index];
    }
}

- (void)luaui_removeFromSuperview
{
    [self removeFromSuperview];
    // 删除Lua强引用
    MLNUI_Lua_UserData_Release(self);
    if (self.luaui_node) {
        [self.luaui_node removeFromSupernode];
    }
}

- (void)luaui_removeAllSubViews
{
    NSArray *subViews = self.subviews;
    [subViews makeObjectsPerformSelector:@selector(luaui_removeFromSuperview)];
}

- (void)luaui_overlay:(UIView *)overlay {
    if (self.luaui_supportOverlay == NO) {
        return;
    }
    if ([overlay isKindOfClass:[UIView class]]) {
        [self mlnui_removeOverlayIfNeeded]; // 移除旧的(若有)
        self.luaui_node.overlayNode = overlay.luaui_node;
        if (self.superview) { // 先将视图添加到父视图后设置overlay的情况
            [self mlnui_addOverlayIfNeeded];
        }
    }
}

- (void)mlnui_addOverlayIfNeeded {
    MLNUILayoutNode *overlayNode = self.luaui_node.overlayNode;
    if (overlayNode) {
        UIView *wrapView = [[UIView alloc] init]; // 避免overlay被clip
        [self.superview addSubview:wrapView];
        MLNUIChangeSuperview(self, wrapView); // 只调整视图层级，不调整node层级，这样测量布局均只计算self而不是wrapView
        [wrapView addSubview:overlayNode.targetView];
        MLNUI_Lua_UserData_Retain_With_Index(2, overlayNode.targetView);
        [overlayNode.targetView mlnui_addOverlayIfNeeded]; // overlay还有overlay的情况
    }
}

- (void)mlnui_removeOverlayIfNeeded {
    MLNUILayoutNode *oldOverlay = self.luaui_node.overlayNode;
    if (oldOverlay && oldOverlay.targetView.superview) {
        UIView *wrapView = self.superview;
        MLNUIChangeSuperview(self, wrapView.superview); // 恢复视图层级
        [oldOverlay.targetView removeFromSuperview];
        MLNUI_Lua_UserData_Release(self);
        self.luaui_node.overlayNode = nil;
        [wrapView removeFromSuperview]; // remove overlay's wrapView
    }
}

static MLNUI_FORCE_INLINE void MLNUIChangeSuperview(UIView *view, UIView *newSuperview) {
    [view removeFromSuperview];
    [newSuperview addSubview:view];
}

#pragma mark - Layout
- (void)luaui_needLayout
{
    [self.luaui_node needLayout];
}

- (void)luaui_needLayoutAndSpread
{
    [self.luaui_node needLayoutAndSpread];
}

- (void)luaui_requestLayout
{
    [self.luaui_node requestLayout];
}

- (void)luaui_requestLayoutIfNeed
{
    if (self.luaui_node.isDirty) {
        [self luaui_requestLayout];
    }
}

- (CGSize)luaui_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return CGSizeZero;
}

// @note you can override if need.
- (void)luaui_changedLayout
{
    // 1.如果当前View的Frame变更，检查是否需要修正圆角
    [self mlnui_updateCornersIfNeed];
    // 2.如果当前View的Frame变更，检查是否需要修正渐变色
    [self mlnui_updateGradientLayerIfNeed];
    // 3.标记需要更新padding内的视图
    self.luaui_paddingNeedUpdated = YES;
}

// @note you can override if need.
- (void)luaui_layoutCompleted
{
    // 1. 更新padding
    if (self.luaui_contentView && [self luaui_isPaddingNeedUpdated]) {
        [self luaui_onUpdateForPadding];
        [self luaui_paddingUpdated];
    }
}

#pragma mark - Setter & Getter Status
- (BOOL)luaui_gone
{
    return self.luaui_node.isGone;
}

- (void)setLuaui_gone:(BOOL)luaui_gone
{
    if (luaui_gone != self.luaui_node.isGone) {
        self.luaui_node.gone = luaui_gone;
        self.hidden = luaui_gone;
    }
}

static const void *kLuaLayoutEnable = &kLuaLayoutEnable;
- (void)setLuaui_layoutEnable:(BOOL)luaui_layoutEnable
{
    objc_setAssociatedObject(self, kLuaLayoutEnable, @(luaui_layoutEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)luaui_layoutEnable
{
    id luaui_layoutEnable = objc_getAssociatedObject(self, kLuaLayoutEnable);
    return [luaui_layoutEnable boolValue];
}

- (void)setLuaui_gravity:(MLNUIGravity)luaui_gravity
{
    self.luaui_node.gravity = luaui_gravity;
}

- (MLNUIGravity)luaui_gravity
{
    return self.luaui_node.gravity;
}

- (void)setLuaui_priority:(CGFloat)luaui_priority
{
    self.luaui_node.priority = luaui_priority;
}

- (CGFloat)luaui_priority
{
    return self.luaui_node.priority;
}

- (void)setLuaui_weight:(int)luaui_weight
{
    self.luaui_node.weight = luaui_weight;
}

- (int)luaui_weight
{
    return self.luaui_node.weight;
}

- (void)setLuaui_wrapContent:(BOOL)luaui_wrapContent
{
    self.luaui_node.wrapContent = luaui_wrapContent;
}

- (BOOL)isLua_wrapContent
{
    return self.luaui_node.wrapContent;
}

- (BOOL)luaui_isContainer
{
    return NO;
}

- (BOOL)luaui_supportOverlay {
    return NO;
}

- (BOOL)luaui_clipsToBounds
{
    return self.mlnui_renderContext.clipToBounds;
}

#pragma mark - Setter & Getter Padding
- (void)luaui_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    MLNUILayoutNode *node = self.luaui_node;
    node.paddingTop = top;
    node.paddingRight = right;
    node.paddingBottom = bottom;
    node.paddingLeft = left;
}

#pragma mark - MLNUIPaddingViewProtocol
- (CGFloat)luaui_paddingLeft
{
    return self.luaui_node.paddingLeft;
}

- (void)setLuaui_paddingLeft:(CGFloat)luaui_paddingLeft
{
    self.luaui_node.paddingLeft = luaui_paddingLeft;
}

- (CGFloat)luaui_paddingRight
{
    return self.luaui_node.paddingRight;
}

- (void)setLuaui_paddingRight:(CGFloat)luaui_paddingRight
{
    self.luaui_node.paddingRight = luaui_paddingRight;
}

- (CGFloat)luaui_paddingTop
{
    return self.luaui_node.paddingTop;
}

- (void)setLuaui_paddingTop:(CGFloat)luaui_paddingTop
{
    self.luaui_node.paddingTop = luaui_paddingTop;
}

- (CGFloat)luaui_paddingBottom
{
    return self.luaui_node.paddingBottom;
}

- (void)setLuaui_paddingBottom:(CGFloat)luaui_paddingBottom
{
    self.luaui_node.paddingBottom = luaui_paddingBottom;
}

- (BOOL)luaui_isPaddingNeedUpdated
{
    return self.luaui_node.isPaddingNeedUpdated;
}

- (void)setLuaui_paddingNeedUpdated:(BOOL)luaui_paddingNeedUpdated
{
    self.luaui_node.paddingNeedUpdated = luaui_paddingNeedUpdated;
}

- (UIView *)luaui_contentView
{
    return nil;
}

- (void)luaui_onUpdateForPadding
{
    UIEdgeInsets padding = UIEdgeInsetsMake(self.luaui_paddingTop, self.luaui_paddingLeft, self.luaui_paddingBottom, self.luaui_paddingRight);
    CGRect luaui_contentViewFrame = UIEdgeInsetsInsetRect(self.bounds, padding);
    if (!CGRectEqualToRect(luaui_contentViewFrame, self.luaui_contentView.frame)) {
        luaui_contentViewFrame.size.width = luaui_contentViewFrame.size.width <0 ? 0 : luaui_contentViewFrame.size.width;
        luaui_contentViewFrame.size.height = luaui_contentViewFrame.size.height <0 ? 0: luaui_contentViewFrame.size.height;
        self.luaui_contentView.frame = luaui_contentViewFrame;
    }
}

- (void)luaui_paddingUpdated
{
    [self.luaui_node paddingUpdated];
}

#pragma mark - Setter & Getter Margin
- (void)setLuaui_marginTop:(CGFloat)luaui_marginTop
{
    self.luaui_node.marginTop = luaui_marginTop;
}

- (CGFloat)luaui_marginTop
{
    return self.luaui_node.marginTop;
}

- (void)setLuaui_marginLeft:(CGFloat)luaui_marginLeft
{
    self.luaui_node.marginLeft = luaui_marginLeft;
}

- (CGFloat)luaui_marginLeft
{
    return self.luaui_node.marginLeft;
}

- (void)setLuaui_marginBottom:(CGFloat)luaui_marginBottom
{
    self.luaui_node.marginBottom = luaui_marginBottom;
}

- (CGFloat)luaui_marginBottom
{
    return self.luaui_node.marginBottom;
}

- (void)setLuaui_marginRight:(CGFloat)luaui_marginRight
{
    self.luaui_node.marginRight = luaui_marginRight;
}

- (CGFloat)luaui_marginRight
{
    return self.luaui_node.marginRight;
}

#pragma mark - Setter & Getter Size
- (void)setLuaui_minWidth:(CGFloat)luaui_minWidth
{
    self.luaui_node.minWidth = luaui_minWidth;
}

- (CGFloat)luaui_minWidth
{
    return self.luaui_node.minWidth;
}

- (void)setLuaui_minHeight:(CGFloat)luaui_minHeight
{
    self.luaui_node.minHeight = luaui_minHeight;
}

- (CGFloat)luaui_minHeight
{
    return self.luaui_node.minHeight;
}

- (void)setLuaui_maxWidth:(CGFloat)luaui_maxWidth
{
    self.luaui_node.maxWidth = luaui_maxWidth;
}

- (CGFloat)luaui_maxWidth
{
    return self.luaui_node.maxWidth;
}

- (void)setLuaui_maxHieght:(CGFloat)luaui_maxHieght
{
    self.luaui_node.maxHeight = luaui_maxHieght;
}

- (CGFloat)luaui_maxHieght
{
    return self.luaui_node.maxHeight;
}

- (void)mlnui_startAutoLayout
{
    if ([self mlnui_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mlnui_luaCore]);
        [instance addRootnode:(MLNUILayoutContainerNode *)self.luaui_node.rootnode];
    }
}

- (void)mlnui_stopAutoLayout
{
    if ([self mlnui_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mlnui_luaCore]);
        [instance removeRootNode:(MLNUILayoutContainerNode *)self.luaui_node.rootnode];
    }
}

#pragma mark - Getter Of Node
static const void *kLuaLayoutNode = &kLuaLayoutNode;
- (MLNUILayoutNode *)luaui_node
{
    MLNUILayoutNode *node = objc_getAssociatedObject(self, kLuaLayoutNode);
    if (!node && self.luaui_layoutEnable) {
        node = [MLNUILayoutNodeFactory createNodeWithTargetView:self];
        objc_setAssociatedObject(self, kLuaLayoutNode, node, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return node;
}

@end
