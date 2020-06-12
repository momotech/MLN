//
//  UIView+MLNUILayoutNode.m
//  MLN
//
//  Created by MOMO on 2020/5/29.
//

#import "UIView+MLNUILayout.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIHeader.h"
#import "MLNUIRenderContext.h"
#import <objc/runtime.h>

#define MLNUI_VALIDATE_CONTAINER_METHOD(ret) \
if (!self.luaui_isContainer) { \
    UIView<MLNUIEntityExportProtocol> *view = (UIView<MLNUIEntityExportProtocol> *)self; \
    MLNUILuaAssert(view.mlnui_luaCore, NO, @"This method is only valid in container view.") \
    return ret; \
}

static const void *kMLNUILayoutAssociatedKey = &kMLNUILayoutAssociatedKey;

@implementation UIView (MLNUILayout)

#pragma mark - Property

- (MLNUILayoutNode *)mlnui_layoutNode {
    MLNUILayoutNode *node = objc_getAssociatedObject(self, kMLNUILayoutAssociatedKey);
    if (!node && self.mlnui_layoutEnable) {
        node = [[MLNUILayoutNode alloc] initWithView:self isRootView:self.mlnui_isRootView];
        objc_setAssociatedObject(self, kMLNUILayoutAssociatedKey, node, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return node;
}

- (BOOL)mlnui_layoutEnable {
    return NO;
}

- (BOOL)mlnui_isRootView {
    return NO;
}

#pragma mark - MLNUIPaddingContainerViewProtocol

- (UIView *)mlnui_contentView {
    return nil;
}

- (CGFloat)mlnui_paddingTop {
    return self.mlnui_layoutNode.paddingTop.value;
}

- (CGFloat)mlnui_paddingLeft {
    return self.mlnui_layoutNode.paddingLeft.value;
}

- (CGFloat)mlnui_paddingRight {
    return self.mlnui_layoutNode.paddingRight.value;
}

- (CGFloat)mlnui_paddingBottom {
    return self.mlnui_layoutNode.paddingBottom.value;
}

#pragma mark - View Hierarchy

- (void)mlnui_user_data_dealloc {
    [super mlnui_user_data_dealloc];
    // 如果是归属于lua的视图，在对应UserData被GC时候，应该从界面上移除
    if (self.mlnui_isLuaObject) {
        [self luaui_removeFromSuperview];
        if (self.luaui_isContainer) {
            [self luaui_removeAllSubViews];
        }
    }
}

- (UIView *)luaui_superview {
    if (![self.superview mlnui_isConvertible]) {
        return nil;
    }
    return self.superview;
}

- (void)luaui_addSubview:(UIView *)view {
    if (view.superview && view.superview == self) {
        return;
    }
    if (view.superview) {
        [view luaui_removeFromSuperview];
    }
    [self addSubview:view];
    // 添加Lua强引用
    MLNUI_Lua_UserData_Retain_With_Index(2, view);
    [self.mlnui_layoutNode addSubNode:view.mlnui_layoutNode];
}

- (void)luaui_insertSubview:(UIView *)view atIndex:(NSInteger)index {
    if (view.superview && view.superview == self) {
        return;
    }
    if (view.superview) {
        [view luaui_removeFromSuperview];
    }
    index = index - 1;
    index = index >= 0 && index < self.subviews.count? index : self.subviews.count;
    [self insertSubview:view atIndex:index];
    // 添加Lua强引用
    MLNUI_Lua_UserData_Retain_With_Index(2, view);
    [self.mlnui_layoutNode insertSubNode:view.mlnui_layoutNode atIndex:index];
}

- (void)luaui_removeFromSuperview {
    [self removeFromSuperview];
    // 删除Lua强引用
    MLNUI_Lua_UserData_Release(self);
    [self.mlnui_layoutNode.superNode removeSubNode:self.mlnui_layoutNode];
}

- (void)luaui_removeAllSubViews {
    NSArray *subViews = self.subviews;
    [subViews makeObjectsPerformSelector:@selector(luaui_removeFromSuperview)];
}

#pragma mark - Layout

- (BOOL)luaui_isContainer {
    return NO;
}

- (BOOL)luaui_clipsToBounds {
    return self.mlnui_renderContext.clipToBounds;
}

- (void)setLuaui_display:(BOOL)display {
    self.mlnui_layoutNode.display = (display == YES) ? MLNUIDisplayFlex : MLNUIDisplayNone;
}

- (BOOL)luaui_display {
    return self.mlnui_layoutNode.display == MLNUIDisplayFlex;
}

- (void)setLuaui_mainAxis:(MLNUIJustify)mainAxis {
    MLNUI_VALIDATE_CONTAINER_METHOD()
    self.mlnui_layoutNode.justifyContent = mainAxis;
}

- (MLNUIJustify)luaui_mainAxis {
    MLNUI_VALIDATE_CONTAINER_METHOD(0)
    return self.mlnui_layoutNode.justifyContent;
}

- (void)setLuaui_crossSelf:(MLNUICrossAlign)align {
    self.mlnui_layoutNode.alignSelf = align;
}

- (MLNUICrossAlign)luaui_crossSelf {
    return self.mlnui_layoutNode.alignSelf;
}

- (void)setLuaui_crossAxis:(MLNUICrossAlign)crossAxis {
    MLNUI_VALIDATE_CONTAINER_METHOD()
    self.mlnui_layoutNode.alignItems = crossAxis;
}

- (MLNUICrossAlign)luaui_crossAxis {
    MLNUI_VALIDATE_CONTAINER_METHOD(0)
    return self.mlnui_layoutNode.alignItems;
}

- (void)setLuaui_crossContent:(MLNUICrossAlign)crossContent {
    MLNUI_VALIDATE_CONTAINER_METHOD()
    self.mlnui_layoutNode.alignContent = crossContent;
}

- (MLNUICrossAlign)luaui_crossContent {
    MLNUI_VALIDATE_CONTAINER_METHOD(0)
    return self.mlnui_layoutNode.alignContent;
}

- (void)setLuaui_wrap:(MLNUIWrap)wrap {
    MLNUI_VALIDATE_CONTAINER_METHOD()
    self.mlnui_layoutNode.flexWrap = wrap;
}

- (MLNUIWrap)luaui_wrap {
    MLNUI_VALIDATE_CONTAINER_METHOD(0)
    return self.mlnui_layoutNode.flexWrap;
}

/**
 * Width
 */
- (void)setLuaui_width:(CGFloat)luaui_width {
    self.mlnui_layoutNode.width = MLNUIPointValue(luaui_width);
}

- (CGFloat)luaui_width {
    MLNUIValue value = self.mlnui_layoutNode.width;
    if (value.unit == MLNUIUnitPoint && value.value > 0) {
        return value.value; // ensure the width value is `point` type.
    }
    if (self.mlnui_layoutNode.layoutWidth > 0) {
        return self.mlnui_layoutNode.layoutWidth;
    }
    return CGRectGetWidth(self.frame);
}

- (void)setLuaui_widthPercent:(CGFloat)widthPercent {
    self.mlnui_layoutNode.width = MLNUIPercentValue(widthPercent);
}

- (CGFloat)luaui_widthPercent {
    MLNUIValue value = self.mlnui_layoutNode.width;
    if (value.unit == MLNUIUnitPercent) {
        return value.value; // ensure the widthPercent value is `percent` type.
    }
    return 0.0;
}

- (void)setLuaui_minWidth:(CGFloat)minWidth {
    self.mlnui_layoutNode.minWidth = MLNUIPointValue(minWidth);
}

- (CGFloat)luaui_minWidth {
    MLNUIValue value = self.mlnui_layoutNode.minWidth;
    if (value.unit == MLNUIUnitPoint) {
        return value.value;
    }
    return 0.0;
}

- (void)setLuaui_maxWidth:(CGFloat)maxWidth {
    self.mlnui_layoutNode.maxWidth = MLNUIPointValue(maxWidth);
}

- (CGFloat)luaui_maxWidth {
    MLNUIValue value = self.mlnui_layoutNode.maxWidth;
    if (value.unit == MLNUIUnitPoint) {
        return value.value;
    }
    return 0.0;
}

- (void)setLuaui_minWidthPercent:(CGFloat)minWidthPercent {
    self.mlnui_layoutNode.minWidth = MLNUIPercentValue(minWidthPercent);
}

- (CGFloat)luaui_minWidthPercent {
    MLNUIValue value = self.mlnui_layoutNode.minWidth;
    if (value.unit == MLNUIUnitPercent) {
        return value.value;
    }
    return 0.0;
}

- (void)setLuaui_maxWidthPercent:(CGFloat)maxWidthPercent {
    self.mlnui_layoutNode.maxWidth = MLNUIPercentValue(maxWidthPercent);
}

- (CGFloat)luaui_maxWidthPercent {
    MLNUIValue value = self.mlnui_layoutNode.maxWidth;
    if (value.unit == MLNUIUnitPercent) {
        return value.value;
    }
    return 0.0;
}

/**
 * Height
 */
- (void)setLuaui_height:(CGFloat)luaui_height {
    self.mlnui_layoutNode.height = MLNUIPointValue(luaui_height);
}

- (CGFloat)luaui_height {
    MLNUIValue value = self.mlnui_layoutNode.height;
    if (value.unit == MLNUIUnitPoint && value.value > 0) {
        return value.value; // ensure the height value is `point` type.
    }
    if (self.mlnui_layoutNode.layoutHeight > 0) {
        return self.mlnui_layoutNode.layoutHeight;
    }
    return CGRectGetHeight(self.frame);
}

- (void)setLuaui_heightPercent:(CGFloat)heightPercent {
    self.mlnui_layoutNode.height = MLNUIPercentValue(heightPercent);
}

- (CGFloat)luaui_heightPercent {
    MLNUIValue value = self.mlnui_layoutNode.height;
    if (value.unit == MLNUIUnitPercent) {
        return value.value; // ensure the heightPercent value is `percent` type.
    }
    return 0.0;
}

- (void)setLuaui_minHeight:(CGFloat)minHeight {
    self.mlnui_layoutNode.minHeight = MLNUIPointValue(minHeight);
}

- (CGFloat)luaui_minHeight {
    MLNUIValue value = self.mlnui_layoutNode.minHeight;
    if (value.unit == MLNUIUnitPoint) {
        return value.value;
    }
    return 0.0;
}

- (void)setLuaui_maxHeight:(CGFloat)maxHeight {
    self.mlnui_layoutNode.maxHeight = MLNUIPointValue(maxHeight);
}

- (CGFloat)luaui_maxHeight {
    MLNUIValue value = self.mlnui_layoutNode.maxHeight;
    if (value.unit == MLNUIUnitPoint) {
        return value.value;
    }
    return 0.0;
}

- (void)setLuaui_minHeightPercent:(CGFloat)minHeightPercent {
    self.mlnui_layoutNode.minHeight = MLNUIPercentValue(minHeightPercent);
}

- (CGFloat)luaui_minHeightPercent {
    MLNUIValue value = self.mlnui_layoutNode.minHeight;
    if (value.unit == MLNUIUnitPercent) {
        return value.value;
    }
    return 0.0;
}

- (void)setLuaui_maxHeightPercent:(CGFloat)maxHeightPercent {
    self.mlnui_layoutNode.maxHeight = MLNUIPercentValue(maxHeightPercent);
}

- (CGFloat)luaui_maxHeightPercent {
    MLNUIValue value = self.mlnui_layoutNode.maxHeight;
    if (value.unit == MLNUIUnitPercent) {
        return value.value;
    }
    return 0.0;
}

/**
 * Padding
 */
- (void)luaui_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left {
    MLNUILayoutNode *layout = self.mlnui_layoutNode;
    layout.paddingTop = MLNUIPointValue(top);
    layout.paddingRight = MLNUIPointValue(right);
    layout.paddingBottom = MLNUIPointValue(bottom);
    layout.paddingLeft = MLNUIPointValue(left);
}

- (void)setLuaui_paddingTop:(CGFloat)paddingTop {
    self.mlnui_layoutNode.paddingTop = MLNUIPointValue(paddingTop);
}

- (CGFloat)luaui_paddingTop {
    MLNUIValue top = self.mlnui_layoutNode.paddingTop;
    if (top.unit == MLNUIUnitPoint) {
        return top.value;
    }
    return 0.0;
}

- (void)setLuaui_paddingLeft:(CGFloat)paddingLeft {
    self.mlnui_layoutNode.paddingLeft = MLNUIPointValue(paddingLeft);
}

- (CGFloat)luaui_paddingLeft {
    MLNUIValue left = self.mlnui_layoutNode.paddingLeft;
    if (left.unit == MLNUIUnitPoint) {
        return left.value;
    }
    return 0.0;
}

- (void)setLuaui_paddingBottom:(CGFloat)paddingBottom {
    self.mlnui_layoutNode.paddingBottom = MLNUIPointValue(paddingBottom);
}

- (CGFloat)luaui_paddingBottom {
    MLNUIValue bottom = self.mlnui_layoutNode.paddingBottom;
    if (bottom.unit == MLNUIUnitPoint) {
        return bottom.value;
    }
    return 0.0;
}

- (void)setLuaui_paddingRight:(CGFloat)paddingRight {
    self.mlnui_layoutNode.paddingRight = MLNUIPointValue(paddingRight);
}

- (CGFloat)luaui_paddingRight {
    MLNUIValue right = self.mlnui_layoutNode.paddingRight;
    if (right.unit == MLNUIUnitPoint) {
        return right.value;
    }
    return 0.0;
}

/**
 * Margin
 */
- (void)luaui_setMarginWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left {
    MLNUILayoutNode *layout = self.mlnui_layoutNode;
    layout.marginTop = MLNUIPointValue(top);
    layout.marginRight = MLNUIPointValue(right);
    layout.marginBottom = MLNUIPointValue(bottom);
    layout.marginLeft = MLNUIPointValue(left);
}

- (void)setLuaui_marginTop:(CGFloat)marginTop {
    self.mlnui_layoutNode.marginTop = MLNUIPointValue(marginTop);
}

- (CGFloat)luaui_marginTop {
    MLNUIValue top = self.mlnui_layoutNode.marginTop;
    if (top.unit == MLNUIUnitPoint) {
        return top.value;
    }
    return 0.0;
}

- (void)setLuaui_marginLeft:(CGFloat)marginLeft {
    self.mlnui_layoutNode.marginLeft = MLNUIPointValue(marginLeft);
}

- (CGFloat)luaui_marginLeft {
    MLNUIValue left = self.mlnui_layoutNode.marginLeft;
    if (left.unit == MLNUIUnitPoint) {
        return left.value;
    }
    return 0.0;
}

- (void)setLuaui_marginBottom:(CGFloat)marginBottom {
    self.mlnui_layoutNode.marginBottom = MLNUIPointValue(marginBottom);
}

- (CGFloat)luaui_marginBottom {
    MLNUIValue bottom = self.mlnui_layoutNode.marginBottom;
    if (bottom.unit == MLNUIUnitPoint) {
        return bottom.value;
    }
    return 0.0;
}

- (void)setLuaui_marginRight:(CGFloat)marginRight {
    self.mlnui_layoutNode.marginRight = MLNUIPointValue(marginRight);
}

- (CGFloat)luaui_marginRight {
    MLNUIValue right = self.mlnui_layoutNode.marginRight;
    if (right.unit == MLNUIUnitPoint) {
        return right.value;
    }
    return 0.0;
}

/**
 * Flex
 */
- (void)setLuaui_basis:(CGFloat)basis {
    self.mlnui_layoutNode.flex = basis;
}

- (CGFloat)luaui_basis {
    return self.mlnui_layoutNode.flex;
}

- (void)setLuaui_grow:(CGFloat)grow {
    self.mlnui_layoutNode.flexGrow = grow;
}

- (CGFloat)luaui_grow {
    return self.mlnui_layoutNode.flexGrow;
}

- (void)setLuaui_shrink:(CGFloat)shrink {
    self.mlnui_layoutNode.flexShrink = shrink;
}

- (CGFloat)luaui_shrink {
    return self.mlnui_layoutNode.flexShrink;
}

/**
 * Position
 */
- (void)luaui_setPositionWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left {
    MLNUILayoutNode *layout = self.mlnui_layoutNode;
    layout.top = MLNUIPointValue(top);
    layout.right = MLNUIPointValue(right);
    layout.bottom = MLNUIPointValue(bottom);
    layout.left = MLNUIPointValue(left);
}

- (void)setLuaui_positionType:(MLNUIPositionType)position {
    self.mlnui_layoutNode.position = position;
}

- (MLNUIPositionType)luaui_positionType {
    return self.mlnui_layoutNode.position;
}

- (void)setLuaui_positionTop:(CGFloat)positionTop {
    self.mlnui_layoutNode.top = MLNUIPointValue(positionTop);
}

- (CGFloat)luaui_positionTop {
    MLNUIValue top = self.mlnui_layoutNode.top;
    if (top.unit == MLNUIUnitPoint) {
        return top.value;
    }
    return 0.0;
}

- (void)setLuaui_positionLeft:(CGFloat)positionLeft {
    self.mlnui_layoutNode.left = MLNUIPointValue(positionLeft);
}

- (CGFloat)luaui_positionLeft {
    MLNUIValue left = self.mlnui_layoutNode.left;
    if (left.unit == MLNUIUnitPoint) {
        return left.value;
    }
    return 0.0;
}

- (void)setLuaui_positionBottom:(CGFloat)positionBottom {
    self.mlnui_layoutNode.bottom = MLNUIPointValue(positionBottom);
}

- (CGFloat)luaui_positionBottom {
    MLNUIValue bottom = self.mlnui_layoutNode.bottom;
    if (bottom.unit == MLNUIUnitPoint) {
        return bottom.value;
    }
    return 0.0;
}

- (void)setLuaui_positionRight:(CGFloat)positionRight {
    self.mlnui_layoutNode.right = MLNUIPointValue(positionRight);
}

- (CGFloat)luaui_positionRight {
    MLNUIValue right = self.mlnui_layoutNode.right;
    if (right.unit == MLNUIUnitPoint) {
        return right.value;
    }
    return 0.0;
}

#pragma mark -

- (void)mlnui_markNeedsLayout {
    [self.mlnui_layoutNode markDirty];
}

- (void)mlnui_requestLayoutIfNeed {
    if (self.mlnui_layoutNode.isDirty) {
        [self.mlnui_layoutNode applyLayout];
    }
}

- (void)mlnui_layoutDidChange {
    // 1.如果当前View的Frame变更，检查是否需要修正圆角
    [self mlnui_updateCornersIfNeed];
    
    // 2.如果当前View的Frame变更，检查是否需要修正渐变色
    [self mlnui_updateGradientLayerIfNeed];
}

- (void)mlnui_layoutCompleted {
    if (self.mlnui_contentView == nil) {
        return;
    }
    UIEdgeInsets padding = UIEdgeInsetsMake(self.luaui_paddingTop, self.luaui_paddingLeft, self.luaui_paddingBottom, self.luaui_paddingRight);
    CGRect contentViewFrame = UIEdgeInsetsInsetRect(self.bounds, padding);
    if (!CGRectEqualToRect(contentViewFrame, self.mlnui_contentView.frame)) {
        contentViewFrame.size.width = contentViewFrame.size.width < 0 ? 0 : contentViewFrame.size.width;
        contentViewFrame.size.height = contentViewFrame.size.height < 0 ? 0: contentViewFrame.size.height;
        self.mlnui_contentView.frame = contentViewFrame;
    }
}

- (CGSize)mlnui_sizeThatFits:(CGSize)size {
    return CGSizeZero;
}

@end

@implementation UIView (MLNUIFrame)

static MLNUI_FORCE_INLINE void MLNUIComposeFrame(UIView *view, CGRect frame1, CGRect frame2) {
    CGRect frame = (CGRect){
        frame1.origin.x + frame2.origin.x,
        frame1.origin.y + frame2.origin.y,
        frame1.size.width + frame2.size.width,
        frame1.size.height + frame2.size.height,
    };
    view.frame = frame;
}

- (void)setMlnuiLayoutFrame:(CGRect)frame {
    objc_setAssociatedObject(self, @selector(mlnuiLayoutFrame), [NSValue valueWithCGRect:frame], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    MLNUIComposeFrame(self, frame, self.mlnuiAnimationFrame);
}

- (CGRect)mlnuiLayoutFrame {
    return [objc_getAssociatedObject(self, _cmd) CGRectValue];
}

- (void)setMlnuiAnimationFrame:(CGRect)frame {
    objc_setAssociatedObject(self, @selector(mlnuiAnimationFrame), [NSValue valueWithCGRect:frame], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    MLNUIComposeFrame(self, frame, self.mlnuiLayoutFrame);
}

- (CGRect)mlnuiAnimationFrame {
    return [objc_getAssociatedObject(self, _cmd) CGRectValue];
}

@end
