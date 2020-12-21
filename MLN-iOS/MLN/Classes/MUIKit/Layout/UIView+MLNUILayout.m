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
#import <ArgoAnimation/UIView+AKFrame.h>

#define MLNUI_VALIDATE_CONTAINER_METHOD(ret) \
if (!self.luaui_isContainer) { \
    UIView<MLNUIEntityExportProtocol> *view = (UIView<MLNUIEntityExportProtocol> *)self; \
    MLNUILuaAssert(view.mlnui_luaCore, NO, @"This method is only valid in container view.") \
    return ret; \
}

static const void *kMLNUILayoutAssociatedKey = &kMLNUILayoutAssociatedKey;

@interface UIView (MLNUILayoutVirtualView)

// 当virtualView执行removeFromSuper时，会将其所有的subNode以及subNode对应的view，
// 从superNode以及superView上移除。若virtualView再想添加到视图上时，
// 由于其子视图已全部移除，因而无法添加，故这里存储virtualView的所有子视图.
@property (nonatomic, strong, readonly) NSMutableArray<UIView *> *mlnui_virtualViewSubviews;

// 被add到view层级上时，根据是否需要渲染来决定是否为虚拟视图，默认NO.
@property (nonatomic, assign) BOOL mlnui_markVirtualView;

@end

@implementation UIView (MLNUILayoutVirtualView)

- (NSMutableArray<UIView *> *)mlnui_virtualViewSubviews {
    NSMutableArray *subviews = objc_getAssociatedObject(self, _cmd);
    if (!subviews) {
        subviews = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, subviews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSParameterAssert([subviews isKindOfClass:[NSMutableArray class]]);
    return subviews;
}

- (void)mlnui_markViewAsVirtualViewIfNeeded {
    if (!self.mlnui_allowVirtualLayout || self.mlnui_needRender) {
        return;
    }
    self.mlnui_markVirtualView = YES;
    if (self.mlnui_virtualViewSubviews.count == 0) { // 当标记虚拟视图时，要把其所有子视图转移到该数组中
        NSArray<MLNUILayoutNode *> *subNodes = [[self mlnui_layoutNode] subNodes];
        [subNodes enumerateObjectsUsingBlock:^(MLNUILayoutNode *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [self.mlnui_virtualViewSubviews addObject:obj.view];
        }];
    }
}

- (void)setMlnui_markVirtualView:(BOOL)mark {
    objc_setAssociatedObject(self, @selector(mlnui_markVirtualView), @(mark), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mlnui_markVirtualView {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

#pragma mark -

@implementation UIView (MLNUILayout)

- (Class)mlnui_bindedLayoutNodeClass {
    return [MLNUILayoutNode class];
}

#pragma mark - Property

- (MLNUILayoutNode *)mlnui_layoutNode {
    MLNUILayoutNode *node = objc_getAssociatedObject(self, kMLNUILayoutAssociatedKey);
    if (!node && self.mlnui_layoutEnable) {
        node = [[[self mlnui_bindedLayoutNodeClass] alloc] initWithView:self isRootView:self.mlnui_isRootView];
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

- (BOOL)mlnui_allowVirtualLayout {
    return NO;
}

- (BOOL)mlnui_isVirtualView {
    if (!self.mlnui_allowVirtualLayout) {
        return NO;
    }
    return self.mlnui_markVirtualView;
}

- (BOOL)mlnui_resetOriginAfterLayout {
    return YES;
}

- (void)setMlnui_layoutCompleteCallback:(MLNUIBlock *)complete {
    objc_setAssociatedObject(self, @selector(mlnui_layoutCompleteCallback), complete, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_layoutCompleteCallback {
    return objc_getAssociatedObject(self, _cmd);
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

static inline void MLNUITransferView(UIView *view, UIView *targetSuperview) {
    if (view.superview) {
        [view removeFromSuperview];
    }
    [targetSuperview addSubview:view];
}

static inline void MLNUITransferViewAtIndex(UIView *view, UIView *targetSuperview, NSInteger index) {
    if (view.superview) {
        [view removeFromSuperview];
    }
    [targetSuperview insertSubview:view atIndex:index];
}

static inline UIView *MLNUIValidSuperview(UIView *self) {
    MLNUILayoutNode *superNode = self.mlnui_layoutNode.superNode;
    if (!superNode) return self; // `self` is virtual view and it has not been added to any view yet.
    while (superNode.superNode && superNode.view.mlnui_isVirtualView) {
        superNode = superNode.superNode;
    }
    return superNode.view;
}

- (void)_mlnui_transferSubviewsFromView:(UIView *)view {
    if (!view.mlnui_isVirtualView) return;
    NSArray<UIView *> *subviews = [view mlnui_virtualViewSubviews];
    if (subviews.count == 0) {
        return;
    }
    UIView *toView = self.mlnui_isVirtualView ? MLNUIValidSuperview(self) : self;
    for (UIView<MLNUIEntityExportProtocol> *sub in subviews) {
        if (sub.mlnui_isVirtualView) {
            [toView _mlnui_transferSubviewsFromView:sub];
        } else {
            MLNUITransferView(sub, toView);
        }
        if (!sub.mlnui_layoutNode.superNode) {
            MLNUI_Lua_UserData_Retain_With_Index(2, sub);
            [view.mlnui_layoutNode addSubNode:sub.mlnui_layoutNode];
        }
    }
}

- (void)_mlnui_transferSubviewsFromView:(UIView *)view atIndex:(NSInteger)index {
    if (!view.mlnui_isVirtualView) return;
    NSArray<UIView *> *subviews = [view mlnui_virtualViewSubviews];
    if (subviews.count == 0) {
        return;
    }
    UIView *toView = self.mlnui_isVirtualView ? MLNUIValidSuperview(self) : self;
    for (UIView<MLNUIEntityExportProtocol> *sub in subviews.reverseObjectEnumerator) { // 插入时，视图是往后堆叠，故倒叙遍历
        if (sub.mlnui_isVirtualView) {
            [toView _mlnui_transferSubviewsFromView:sub atIndex:index];
        } else {
            MLNUITransferViewAtIndex(sub, toView, index);
        }
        if (!sub.mlnui_layoutNode.superNode) {
            MLNUI_Lua_UserData_Retain_With_Index(2, sub);
            [view.mlnui_layoutNode insertSubNode:sub.mlnui_layoutNode atIndex:index];
        }
    }
}

- (void)_mlnui_transferViewToSuperview:(UIView *)view {
    MLNUITransferView(view, MLNUIValidSuperview(self));
}

- (void)_mlnui_transferViewToSuperview:(UIView *)view atIndex:(NSInteger)index {
    MLNUITransferViewAtIndex(view, MLNUIValidSuperview(self), index);
}

- (void)_mlnui_removeVirtualViewSubviews {
    if (!self.mlnui_isVirtualView) return;
    NSArray<MLNUILayoutNode *> *subNodes = self.mlnui_layoutNode.subNodes;
    [subNodes enumerateObjectsUsingBlock:^(MLNUILayoutNode *_Nonnull node, NSUInteger idx, BOOL *_Nonnull stop) {
        [node.view luaui_removeFromSuperview];
    }];
}

- (UIView *)luaui_superview {
    if (![self.superview mlnui_isConvertible]) {
        return nil;
    }
    return self.superview;
}

- (void)luaui_addSubview:(UIView *)view {
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    MLNUILayoutNode *superNode = view.mlnui_layoutNode.superNode;
    if (superNode && superNode == self.mlnui_layoutNode) {
        return;
    }
    if (superNode) {
        [view luaui_removeFromSuperview];
    }
    [view mlnui_markViewAsVirtualViewIfNeeded];
    
    if (view.mlnui_isVirtualView) {
        [self _mlnui_transferSubviewsFromView:view]; // -[view add:virtualView]
    } else if (self.mlnui_isVirtualView && self.mlnui_layoutNode.superNode) {
        [self _mlnui_transferViewToSuperview:view];  // -[virtualView add:view]
    } else {
        [self addSubview:view];
    }
    
    if (self.mlnui_isVirtualView) {
        [self.mlnui_virtualViewSubviews addObject:view];
    }
    
    MLNUI_Lua_UserData_Retain_With_Index(2, view); // should retain view
    [self.mlnui_layoutNode addSubNode:view.mlnui_layoutNode];
}

- (void)luaui_insertSubview:(UIView *)view atIndex:(NSInteger)index {
    if (view.superview && view.superview == self) {
        return;
    }
    if (view.superview) {
        [view luaui_removeFromSuperview];
    }
    [view mlnui_markViewAsVirtualViewIfNeeded];
    
    index = index - 1;
    index = index >= 0 && index < self.subviews.count? index : self.subviews.count;
    
    if (view.mlnui_isVirtualView) {
        [self _mlnui_transferSubviewsFromView:view atIndex:index];
    } else if (self.mlnui_isVirtualView && self.mlnui_layoutNode.superNode) {
        [self _mlnui_transferViewToSuperview:view atIndex:index];
    } else {
        [self insertSubview:view atIndex:index];
    }
    MLNUI_Lua_UserData_Retain_With_Index(2, view);
    [self.mlnui_layoutNode insertSubNode:view.mlnui_layoutNode atIndex:index];
}

- (void)luaui_removeFromSuperview {
    UIView *superview = [self superview];
    if ([superview.mlnui_virtualViewSubviews containsObject:self]) {
        [superview.mlnui_virtualViewSubviews removeObject:self];
    }
    
    [self removeFromSuperview];
    MLNUI_Lua_UserData_Release(self); // 删除Lua强引用
    [self.mlnui_layoutNode.superNode removeSubNode:self.mlnui_layoutNode];
    
    if (self.mlnui_isVirtualView) { // 如果是虚拟视图则需要主动移除其所有子视图
        [self _mlnui_removeVirtualViewSubviews];
    }
}

- (void)luaui_removeAllSubViews {
    NSArray *subViews = self.subviews;
    [subViews makeObjectsPerformSelector:@selector(luaui_removeFromSuperview)];
    
    NSArray<MLNUILayoutNode *> *subNodes = self.mlnui_layoutNode.subNodes;
    if (subNodes.count > 0) { // 可能包含虚拟视图
        [subNodes enumerateObjectsUsingBlock:^(MLNUILayoutNode *_Nonnull node, NSUInteger idx, BOOL *_Nonnull stop) {
            [node.view luaui_removeFromSuperview];
        }];
    }
    
    if (self.mlnui_virtualViewSubviews.count > 0) {
        [self.mlnui_virtualViewSubviews removeAllObjects];
    }
}

#pragma mark - Layout

- (BOOL)luaui_isContainer {
    return NO;
}

- (BOOL)luaui_clipsToBounds {
    return self.mlnui_renderContext.clipToBounds;
}

// 应该获取布局的X (frame.x = layoutFrame.x + animationFrame.x)
- (CGFloat)luaui_getX {
    return self.akLayoutFrame.origin.x;
}

// 应该获取布局的Y (frame.y = layoutFrame.y + animationFrame.y)
- (CGFloat)luaui_getY {
    return self.akLayoutFrame.origin.y;
}

- (void)luaui_layoutComplete:(MLNUIBlock *)complete {
    [self setMlnui_layoutCompleteCallback:complete];
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

- (void)setLuaui_widthAuto {
    self.mlnui_layoutNode.width = MLNUIValueAuto;
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

- (void)setLuaui_heightAuto {
    self.mlnui_layoutNode.height = MLNUIValueAuto;
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
    self.mlnui_layoutNode.flexBasis = MLNUIPointValue(basis);
}

- (CGFloat)luaui_basis {
    MLNUIValue basis = self.mlnui_layoutNode.flexBasis;
    if (basis.unit == MLNUIUnitPoint && !isnan(basis.value)) {
        return basis.value;
    }
    return 0;
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

- (void)mlnui_requestLayoutIfNeedWithSize:(CGSize)size {
    if (self.mlnui_layoutNode.isDirty) {
        [self.mlnui_layoutNode applyLayoutWithSize:size];
    }
}

- (void)mlnui_layoutDidChange {
    // 1.如果当前View的Frame变更，检查是否需要修正圆角
    [self mlnui_updateCornersIfNeed];
    
    // 2.如果当前View的Frame变更，检查是否需要修正渐变色
    [self mlnui_updateGradientLayerIfNeed];
}

- (void)mlnui_layoutCompleted {
    if (self.mlnui_layoutCompleteCallback) {
        [self.mlnui_layoutCompleteCallback callIfCan];
    }
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
