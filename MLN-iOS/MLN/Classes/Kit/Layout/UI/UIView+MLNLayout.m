//
//  UIView+MLNLayout.m
//
//
//  Created by MoMo on 2018/10/26.
//

#import "UIView+MLNLayout.h"
#import <objc/runtime.h>
#import "MLNKitHeader.h"
#import "MLNLayoutNode.h"
#import "MLNLayoutContainerNode.h"
#import "MLNLayoutNodeFactory.h"
#import "UIView+MLNKit.h"
#import "MLNRenderContext.h"

@implementation UIView (MLNLayout)

- (void)mln_user_data_dealloc
{
    [super mln_user_data_dealloc];
    // 如果是归属于lua的视图，在对应UserData被GC时候，应该从界面上移除
    if (self.mln_isLuaObject) {
        [self lua_removeFromSuperview];
        if (self.lua_isContainer) {
            [self lua_removeAllSubViews];
        }
    }
}

#pragma mark - View Tree
- (UIView *)lua_superview
{
    if (![self.superview mln_isConvertible]) {
        return nil;
    }
    
    return self.superview;
}

- (void)lua_addSubview:(UIView *)view
{
    //    MLNCheckTypeAndNilValue(view, @"View", UIView);
    [self addSubview:view];
    // 添加Lua强引用
    MLN_Lua_UserData_Retain_With_Index(2, view);
    if (view.lua_node) {
        [(MLNLayoutContainerNode *)self.lua_node addSubnode:view.lua_node];
    }
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    index = index - 1;
    index = index >= 0 && index < self.subviews.count? index : self.subviews.count;
    [self insertSubview:view atIndex:index];
    // 添加Lua强引用
    MLN_Lua_UserData_Retain_With_Index(2, view);
    if (view.lua_node) {
        [(MLNLayoutContainerNode *)self.lua_node insertSubnode:view.lua_node atIndex:index];
    }
}

- (void)lua_removeFromSuperview
{
    [self removeFromSuperview];
    // 删除Lua强引用
    MLN_Lua_UserData_Release(self);
    if (self.lua_node) {
        [self.lua_node removeFromSupernode];
    }
}

- (void)lua_removeAllSubViews
{
    NSArray *subViews = self.subviews;
    [subViews makeObjectsPerformSelector:@selector(lua_removeFromSuperview)];
}

#pragma mark - Layout
- (void)lua_needLayout
{
    [self.lua_node needLayout];
}

- (void)lua_needLayoutAndSpread
{
    [self.lua_node needLayoutAndSpread];
}

- (void)lua_requestLayout
{
    [self.lua_node requestLayout];
}

- (void)lua_requestLayoutIfNeed
{
    if (self.lua_node.isDirty) {
        [self lua_requestLayout];
    }
}

- (CGSize)lua_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return CGSizeZero;
}

// @note you can override if need.
- (void)lua_changedLayout
{
    // 1.如果当前View的Frame变更，检查是否需要修正圆角
    [self mln_updateCornersIfNeed];
    // 2.如果当前View的Frame变更，检查是否需要修正渐变色
    [self mln_updateGradientLayerIfNeed];
    // 3.标记需要更新padding内的视图
    self.lua_paddingNeedUpdated = YES;
}

// @note you can override if need.
- (void)lua_layoutCompleted
{
    // 1. 更新padding
    if (self.lua_contentView && [self lua_isPaddingNeedUpdated]) {
        [self lua_onUpdateForPadding];
        [self lua_paddingUpdated];
    }
}

#pragma mark - Setter & Getter Status
- (BOOL)lua_gone
{
    return self.lua_node.isGone;
}

- (void)setLua_gone:(BOOL)lua_gone
{
    if (lua_gone != self.lua_node.isGone) {
        self.lua_node.gone = lua_gone;
        self.hidden = lua_gone;
    }
}

static const void *kLuaLayoutEnable = &kLuaLayoutEnable;
- (void)setLua_layoutEnable:(BOOL)lua_layoutEnable
{
    objc_setAssociatedObject(self, kLuaLayoutEnable, @(lua_layoutEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)lua_layoutEnable
{
    id lua_layoutEnable = objc_getAssociatedObject(self, kLuaLayoutEnable);
    return [lua_layoutEnable boolValue];
}

- (void)setLua_gravity:(MLNGravity)lua_gravity
{
    self.lua_node.gravity = lua_gravity;
}

- (MLNGravity)lua_gravity
{
    return self.lua_node.gravity;
}

- (void)setLua_priority:(CGFloat)lua_priority
{
    self.lua_node.priority = lua_priority;
}

- (CGFloat)lua_priority
{
    return self.lua_node.priority;
}

- (void)setLua_weight:(int)lua_weight
{
    self.lua_node.weight = lua_weight;
}

- (int)lua_weight
{
    return self.lua_node.weight;
}

- (void)setLua_wrapContent:(BOOL)lua_wrapContent
{
    self.lua_node.wrapContent = lua_wrapContent;
}

- (BOOL)isLua_wrapContent
{
    return self.lua_node.wrapContent;
}

- (BOOL)lua_isContainer
{
    return NO;
}

- (BOOL)lua_clipsToBounds
{
    return self.mln_renderContext.clipToBounds;
}

#pragma mark - Setter & Getter Padding
- (void)lua_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    MLNLayoutNode *node = self.lua_node;
    node.paddingTop = top;
    node.paddingRight = right;
    node.paddingBottom = bottom;
    node.paddingLeft = left;
}

#pragma mark - MLNPaddingViewProtocol
- (CGFloat)lua_paddingLeft
{
    return self.lua_node.paddingLeft;
}

- (void)setLua_paddingLeft:(CGFloat)lua_paddingLeft
{
    self.lua_node.paddingLeft = lua_paddingLeft;
}

- (CGFloat)lua_paddingRight
{
    return self.lua_node.paddingRight;
}

- (void)setLua_paddingRight:(CGFloat)lua_paddingRight
{
    self.lua_node.paddingRight = lua_paddingRight;
}

- (CGFloat)lua_paddingTop
{
    return self.lua_node.paddingTop;
}

- (void)setLua_paddingTop:(CGFloat)lua_paddingTop
{
    self.lua_node.paddingTop = lua_paddingTop;
}

- (CGFloat)lua_paddingBottom
{
    return self.lua_node.paddingBottom;
}

- (void)setLua_paddingBottom:(CGFloat)lua_paddingBottom
{
    self.lua_node.paddingBottom = lua_paddingBottom;
}

- (BOOL)lua_isPaddingNeedUpdated
{
    return self.lua_node.isPaddingNeedUpdated;
}

- (void)setLua_paddingNeedUpdated:(BOOL)lua_paddingNeedUpdated
{
    self.lua_node.paddingNeedUpdated = lua_paddingNeedUpdated;
}

- (UIView *)lua_contentView
{
    return nil;
}

- (void)lua_onUpdateForPadding
{
    UIEdgeInsets padding = UIEdgeInsetsMake(self.lua_paddingTop, self.lua_paddingLeft, self.lua_paddingBottom, self.lua_paddingRight);
    CGRect lua_contentViewFrame = UIEdgeInsetsInsetRect(self.bounds, padding);
    if (!CGRectEqualToRect(lua_contentViewFrame, self.lua_contentView.frame)) {
        lua_contentViewFrame.size.width = lua_contentViewFrame.size.width <0 ? 0 : lua_contentViewFrame.size.width;
        lua_contentViewFrame.size.height = lua_contentViewFrame.size.height <0 ? 0: lua_contentViewFrame.size.height;
        self.lua_contentView.frame = lua_contentViewFrame;
    }
}

- (void)lua_paddingUpdated
{
    [self.lua_node paddingUpdated];
}

#pragma mark - Setter & Getter Margin
- (void)setLua_marginTop:(CGFloat)lua_marginTop
{
    self.lua_node.marginTop = lua_marginTop;
}

- (CGFloat)lua_marginTop
{
    return self.lua_node.marginTop;
}

- (void)setLua_marginLeft:(CGFloat)lua_marginLeft
{
    self.lua_node.marginLeft = lua_marginLeft;
}

- (CGFloat)lua_marginLeft
{
    return self.lua_node.marginLeft;
}

- (void)setLua_marginBottom:(CGFloat)lua_marginBottom
{
    self.lua_node.marginBottom = lua_marginBottom;
}

- (CGFloat)lua_marginBottom
{
    return self.lua_node.marginBottom;
}

- (void)setLua_marginRight:(CGFloat)lua_marginRight
{
    self.lua_node.marginRight = lua_marginRight;
}

- (CGFloat)lua_marginRight
{
    return self.lua_node.marginRight;
}

#pragma mark - Setter & Getter Size
- (void)setLua_minWidth:(CGFloat)lua_minWidth
{
    self.lua_node.minWidth = lua_minWidth;
}

- (CGFloat)lua_minWidth
{
    return self.lua_node.minWidth;
}

- (void)setLua_minHeight:(CGFloat)lua_minHeight
{
    self.lua_node.minHeight = lua_minHeight;
}

- (CGFloat)lua_minHeight
{
    return self.lua_node.minHeight;
}

- (void)setLua_maxWidth:(CGFloat)lua_maxWidth
{
    self.lua_node.maxWidth = lua_maxWidth;
}

- (CGFloat)lua_maxWidth
{
    return self.lua_node.maxWidth;
}

- (void)setLua_maxHieght:(CGFloat)lua_maxHieght
{
    self.lua_node.maxHeight = lua_maxHieght;
}

- (CGFloat)lua_maxHieght
{
    return self.lua_node.maxHeight;
}

- (void)mln_startAutoLayout
{
    if ([self mln_isConvertible]) {
        MLNKitInstance *instance = MLN_KIT_INSTANCE([(UIView<MLNEntityExportProtocol> *)self mln_luaCore]);
        [instance addRootnode:(MLNLayoutContainerNode *)self.lua_node.rootnode];
    }
}

- (void)mln_stopAutoLayout
{
    if ([self mln_isConvertible]) {
        MLNKitInstance *instance = MLN_KIT_INSTANCE([(UIView<MLNEntityExportProtocol> *)self mln_luaCore]);
        [instance removeRootNode:(MLNLayoutContainerNode *)self.lua_node.rootnode];
    }
}

#pragma mark - Getter Of Node
static const void *kLuaLayoutNode = &kLuaLayoutNode;
- (MLNLayoutNode *)lua_node
{
    MLNLayoutNode *node = objc_getAssociatedObject(self, kLuaLayoutNode);
    if (!node && self.lua_layoutEnable) {
        node = [MLNLayoutNodeFactory createNodeWithTargetView:self];
        objc_setAssociatedObject(self, kLuaLayoutNode, node, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return node;
}

@end
