//
//  MLNUILayoutNode.m
//  MLN
//
//  Created by MOMO on 2020/5/29.
//

#import "MLNUILayoutNode.h"
#import "UIView+MLNUILayout.h"
#import <ArgoAnimation/UIView+AKFrame.h>

#define YG_PROPERTY(type, lowercased_name, capitalized_name)    \
- (type)lowercased_name                                         \
{                                                               \
return YGNodeStyleGet##capitalized_name(self.node);           \
}                                                               \
\
- (void)set##capitalized_name:(type)lowercased_name             \
{                                                               \
YGNodeStyleSet##capitalized_name(self.node, lowercased_name); \
}

#define YG_VALUE_PROPERTY(lowercased_name, capitalized_name)                       \
- (YGValue)lowercased_name                                                         \
{                                                                                  \
return YGNodeStyleGet##capitalized_name(self.node);                              \
}                                                                                  \
\
- (void)set##capitalized_name:(YGValue)lowercased_name                             \
{                                                                                  \
switch (lowercased_name.unit) {                                                  \
case YGUnitUndefined:                                                         \
YGNodeStyleSet##capitalized_name(self.node, lowercased_name.value);          \
break;                                                                       \
case YGUnitPoint:                                                              \
YGNodeStyleSet##capitalized_name(self.node, lowercased_name.value);          \
break;                                                                       \
case YGUnitPercent:                                                            \
YGNodeStyleSet##capitalized_name##Percent(self.node, lowercased_name.value); \
break;                                                                       \
default:                                                                       \
NSAssert(NO, @"Not implemented");                                            \
}                                                                                \
}

#define YG_AUTO_VALUE_PROPERTY(lowercased_name, capitalized_name)                  \
- (YGValue)lowercased_name                                                         \
{                                                                                  \
return YGNodeStyleGet##capitalized_name(self.node);                              \
}                                                                                  \
\
- (void)set##capitalized_name:(YGValue)lowercased_name                             \
{                                                                                  \
switch (lowercased_name.unit) {                                                  \
case YGUnitPoint:                                                              \
YGNodeStyleSet##capitalized_name(self.node, lowercased_name.value);          \
break;                                                                       \
case YGUnitPercent:                                                            \
YGNodeStyleSet##capitalized_name##Percent(self.node, lowercased_name.value); \
break;                                                                       \
case YGUnitAuto:                                                               \
YGNodeStyleSet##capitalized_name##Auto(self.node);                           \
break;                                                                       \
default:                                                                       \
NSAssert(NO, @"Not implemented");                                            \
}                                                                                \
}

#define YG_EDGE_PROPERTY_GETTER(type, lowercased_name, capitalized_name, property, edge) \
- (type)lowercased_name                                                                  \
{                                                                                        \
return YGNodeStyleGet##property(self.node, edge);                                      \
}

#define YG_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge) \
- (void)set##capitalized_name:(CGFloat)lowercased_name                             \
{                                                                                  \
YGNodeStyleSet##property(self.node, edge, lowercased_name);                      \
}

#define YG_EDGE_PROPERTY(lowercased_name, capitalized_name, property, edge)         \
YG_EDGE_PROPERTY_GETTER(CGFloat, lowercased_name, capitalized_name, property, edge) \
YG_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge)

#define YG_VALUE_EDGE_PROPERTY_SETTER(objc_lowercased_name, objc_capitalized_name, c_name, edge) \
- (void)set##objc_capitalized_name:(YGValue)objc_lowercased_name                                 \
{                                                                                                \
switch (objc_lowercased_name.unit) {                                                           \
case YGUnitUndefined:                                                                        \
YGNodeStyleSet##c_name(self.node, edge, objc_lowercased_name.value);                       \
break;                                                                                     \
case YGUnitPoint:                                                                            \
YGNodeStyleSet##c_name(self.node, edge, objc_lowercased_name.value);                       \
break;                                                                                     \
case YGUnitPercent:                                                                          \
YGNodeStyleSet##c_name##Percent(self.node, edge, objc_lowercased_name.value);              \
break;                                                                                     \
default:                                                                                     \
NSAssert(NO, @"Not implemented");                                                          \
}                                                                                              \
}

#define YG_VALUE_EDGE_PROPERTY(lowercased_name, capitalized_name, property, edge)   \
YG_EDGE_PROPERTY_GETTER(YGValue, lowercased_name, capitalized_name, property, edge) \
YG_VALUE_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge)

#define YG_VALUE_EDGES_PROPERTIES(lowercased_name, capitalized_name)                                                  \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Left, capitalized_name##Left, capitalized_name, YGEdgeLeft)                   \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Top, capitalized_name##Top, capitalized_name, YGEdgeTop)                      \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Right, capitalized_name##Right, capitalized_name, YGEdgeRight)                \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Bottom, capitalized_name##Bottom, capitalized_name, YGEdgeBottom)             \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Start, capitalized_name##Start, capitalized_name, YGEdgeStart)                \
YG_VALUE_EDGE_PROPERTY(lowercased_name##End, capitalized_name##End, capitalized_name, YGEdgeEnd)                      \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Horizontal, capitalized_name##Horizontal, capitalized_name, YGEdgeHorizontal) \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Vertical, capitalized_name##Vertical, capitalized_name, YGEdgeVertical)       \
YG_VALUE_EDGE_PROPERTY(lowercased_name, capitalized_name, capitalized_name, YGEdgeAll)

MLNUIValue MLNUIPointValue(CGFloat value)
{
    return (MLNUIValue) { .value = value, .unit = MLNUIUnitPoint };
}

MLNUIValue MLNUIPercentValue(CGFloat value)
{
    return (MLNUIValue) { .value = value, .unit = MLNUIUnitPercent };
}

static YGConfigRef globalConfig;

@interface MLNUILayoutNode ()

@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) BOOL isUIView;
@property (nonatomic, assign) YGNodeRef node;

@end

@implementation MLNUILayoutNode

+ (void)initialize {
    globalConfig = YGConfigNew();
    YGConfigSetExperimentalFeatureEnabled(globalConfig, YGExperimentalFeatureWebFlexBasis, true);
    YGConfigSetPointScaleFactor(globalConfig, [UIScreen mainScreen].scale);
}

- (void)dealloc {
    YGNodeFree(self.node);
}

- (instancetype)initWithView:(UIView *)view isRootView:(BOOL)isRootView {
    if (self = [super init]) {
        _view = view;
        _node = YGNodeNewWithConfig(globalConfig);
        YGNodeSetContext(_node, (__bridge void *) view);
        _isRootNode = isRootView;
        _isUIView = [view isMemberOfClass:[UIView class]];
        self.justifyContent = MLNUIJustifyFlexStart;
        self.alignContent = MLNUIAlignStart;
        self.alignItems = MLNUIAlignStart;
    }
    return self;
}

#pragma mark - Getter

- (BOOL)isDirty {
    return YGNodeIsDirty(self.node);
}

- (void)markDirty {
    if (self.isDirty || !self.isLeaf) {
        return;
    }
    
    // layout is not happy if we try to mark a node as "dirty" before we have set
    // the measure function. Since we already know that this is a leaf,
    // this *should* be fine. Forgive me Hack Gods.
    const YGNodeRef node = self.node;
    if (!YGNodeHasMeasureFunc(node)) {
        YGNodeSetMeasureFunc(node, YGMeasureView);
    }
    YGNodeMarkDirty(node);
}

- (BOOL)resetOriginAfterLayout {
    return self.view.mlnui_resetOriginAfterLayout;
}

- (NSUInteger)numberOfChildren {
    return YGNodeGetChildCount(self.node);
}

- (BOOL)isLeaf {
    NSArray<MLNUILayoutNode *> *subNodes = [self subNodes];
    if (subNodes.count == 0) {
        return YES;
    }
    for (MLNUILayoutNode *node in subNodes) {
        if (node.view.mlnui_layoutEnable) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isWrapContent {
    return MLNUIValueEqual(self.width, MLNUIValueAuto) && MLNUIValueEqual(self.height, MLNUIValueAuto);
}

- (CGFloat)layoutWidth {
    return YGNodeLayoutGetWidth(self.node);
}

- (CGFloat)layoutHeight {
    return YGNodeLayoutGetHeight(self.node);
}

- (NSArray<MLNUILayoutNode *> *)subNodes {
    int count = YGNodeGetChildCount(self.node);
    if (count == 0) return nil;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        UIView *view = (__bridge id)YGNodeGetContext(YGNodeGetChild(self.node, i));
        [array addObject:view.mlnui_layoutNode];
    }
    return array;
}

- (MLNUILayoutNode *)superNode {
    YGNodeRef nodeRef = YGNodeGetOwner(self.node);
    if (!nodeRef) return nil;
    UIView *view = (__bridge id)YGNodeGetContext(nodeRef);
    return [view mlnui_layoutNode];
}

#pragma mark - Style

- (YGPositionType)position
{
    return YGNodeStyleGetPositionType(self.node);
}

- (void)setPosition:(YGPositionType)position
{
    YGNodeStyleSetPositionType(self.node, position);
}

YG_PROPERTY(YGDirection, direction, Direction)
YG_PROPERTY(YGFlexDirection, flexDirection, FlexDirection)
YG_PROPERTY(YGJustify, justifyContent, JustifyContent)
YG_PROPERTY(YGAlign, alignContent, AlignContent)
YG_PROPERTY(YGAlign, alignItems, AlignItems)
YG_PROPERTY(YGAlign, alignSelf, AlignSelf)
YG_PROPERTY(YGWrap, flexWrap, FlexWrap)
YG_PROPERTY(YGOverflow, overflow, Overflow)
YG_PROPERTY(YGDisplay, display, Display)

YG_PROPERTY(CGFloat, flex, Flex)
YG_PROPERTY(CGFloat, flexGrow, FlexGrow)
YG_PROPERTY(CGFloat, flexShrink, FlexShrink)
YG_AUTO_VALUE_PROPERTY(flexBasis, FlexBasis)

YG_VALUE_EDGE_PROPERTY(left, Left, Position, YGEdgeLeft)
YG_VALUE_EDGE_PROPERTY(top, Top, Position, YGEdgeTop)
YG_VALUE_EDGE_PROPERTY(right, Right, Position, YGEdgeRight)
YG_VALUE_EDGE_PROPERTY(bottom, Bottom, Position, YGEdgeBottom)
YG_VALUE_EDGE_PROPERTY(start, Start, Position, YGEdgeStart)
YG_VALUE_EDGE_PROPERTY(end, End, Position, YGEdgeEnd)
YG_VALUE_EDGES_PROPERTIES(margin, Margin)
YG_VALUE_EDGES_PROPERTIES(padding, Padding)

YG_EDGE_PROPERTY(borderLeftWidth, BorderLeftWidth, Border, YGEdgeLeft)
YG_EDGE_PROPERTY(borderTopWidth, BorderTopWidth, Border, YGEdgeTop)
YG_EDGE_PROPERTY(borderRightWidth, BorderRightWidth, Border, YGEdgeRight)
YG_EDGE_PROPERTY(borderBottomWidth, BorderBottomWidth, Border, YGEdgeBottom)
YG_EDGE_PROPERTY(borderStartWidth, BorderStartWidth, Border, YGEdgeStart)
YG_EDGE_PROPERTY(borderEndWidth, BorderEndWidth, Border, YGEdgeEnd)
YG_EDGE_PROPERTY(borderWidth, BorderWidth, Border, YGEdgeAll)

YG_AUTO_VALUE_PROPERTY(width, Width)
YG_AUTO_VALUE_PROPERTY(height, Height)
YG_VALUE_PROPERTY(minWidth, MinWidth)
YG_VALUE_PROPERTY(minHeight, MinHeight)
YG_VALUE_PROPERTY(maxWidth, MaxWidth)
YG_VALUE_PROPERTY(maxHeight, MaxHeight)
YG_PROPERTY(CGFloat, aspectRatio, AspectRatio)

#pragma mark - Layout and Sizing

- (YGDirection)resolvedDirection {
    return YGNodeLayoutGetDirection(self.node);
}

- (CGSize)applyLayout {
    return [self applyLayoutWithSize:CGSizeZero];
}

- (CGSize)applyLayoutWithSize:(CGSize)size {
    CGSize result = [self calculateLayoutWithSize:size];
    YGApplyLayoutRecursive(self.view.mlnui_layoutNode, 0, 0);
    return result;
}

- (void)applyLayoutWithDimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility {
    CGSize size = self.view.bounds.size;
    if (dimensionFlexibility & YGDimensionFlexibilityFlexibleWidth) {
        size.width = YGUndefined;
    }
    if (dimensionFlexibility & YGDimensionFlexibilityFlexibleHeight) {
        size.height = YGUndefined;
    }
    [self calculateLayoutWithSize:size];
    YGApplyLayoutRecursive(self.view.mlnui_layoutNode, 0, 0);
}

- (CGSize)calculateLayout {
    return [self calculateLayoutWithSize:CGSizeZero];
}

- (CGSize)calculateLayoutWithSize:(CGSize)size {
    NSAssert([NSThread isMainThread], @"layout calculation must be done on main.");
    YGAttachNodesFromViewHierachy(self.view);
    
    if (size.width > 0) {
        self.maxWidth = MLNUIPointValue(size.width);
    }
    if (size.height > 0) {
        self.maxHeight = MLNUIPointValue(size.height);
    }
    const YGNodeRef node = self.node;
    YGNodeCalculateLayout(node, MLNUIUndefined, MLNUIUndefined, YGNodeStyleGetDirection(node));
    
    return (CGSize) {
        .width = YGNodeLayoutGetWidth(node),
        .height = YGNodeLayoutGetHeight(node),
    };
}

#pragma mark - Node Tree

- (void)addSubNode:(MLNUILayoutNode *)node {
    if (!node) return;
    [self insertSubNode:node atIndex:YGNodeGetChildCount(self.node)];
}

- (void)insertSubNode:(MLNUILayoutNode *)node atIndex:(NSInteger)index {
    if (!node) return;
    YGNodeSetMeasureFunc(self.node, NULL); // ensure the node being inserted no measure func
    YGNodeInsertChild(self.node, node.node, (const uint32_t)index);
}

- (void)removeSubNode:(MLNUILayoutNode *)node {
    if (!node) return;
    YGNodeRemoveChild(self.node, node.node);
}

#pragma mark - Private

static YGSize YGMeasureView(
                            YGNodeRef node,
                            float width,
                            YGMeasureMode widthMode,
                            float height,
                            YGMeasureMode heightMode)
{
    const CGFloat constrainedWidth = (widthMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : width;
    const CGFloat constrainedHeight = (heightMode == YGMeasureModeUndefined) ? CGFLOAT_MAX: height;
    
    UIView *view = (__bridge UIView*) YGNodeGetContext(node);
    CGSize sizeThatFits = CGSizeZero;
    
    // The default implementation of sizeThatFits: returns the existing size of
    // the view. That means that if we want to layout an empty UIView, which
    // already has got a frame set, its measured size should be CGSizeZero, but
    // UIKit returns the existing size.
    //
    // See https://github.com/facebook/layout/issues/606 for more information.
    if (!view.mlnui_layoutNode.isUIView || [view.subviews count] > 0) {
        sizeThatFits = [view mlnui_sizeThatFits:CGSizeMake(constrainedWidth, constrainedHeight)]; // some class should override this method if needed, such as MLNUILabel、MLNUITableView and so on.
    }
    
    return (YGSize) {
        .width = YGSanitizeMeasurement(constrainedWidth, sizeThatFits.width, widthMode),
        .height = YGSanitizeMeasurement(constrainedHeight, sizeThatFits.height, heightMode),
    };
}

static CGFloat YGSanitizeMeasurement(CGFloat constrainedSize, CGFloat measuredSize, YGMeasureMode measureMode) {
    CGFloat result;
    if (measureMode == YGMeasureModeExactly) {
        result = constrainedSize;
    } else if (measureMode == YGMeasureModeAtMost) {
        result = MIN(constrainedSize, measuredSize);
    } else {
        result = measuredSize;
    }
    return result;
}

static void YGAttachNodesFromViewHierachy(UIView *const view) {
    MLNUILayoutNode *layoutNode = view.mlnui_layoutNode;
    const YGNodeRef node = layoutNode.node;
    
    // Only leaf nodes should have a measure function
    if (layoutNode.isLeaf) {
        YGRemoveAllChildren(node);
        YGNodeSetMeasureFunc(node, YGMeasureView);
    } else {
        YGNodeSetMeasureFunc(node, NULL);
        NSMutableArray<UIView *> *needLayoutViews = [[NSMutableArray alloc] initWithCapacity:view.subviews.count];
        for (UIView *subview in view.subviews) {
            if (subview.mlnui_layoutEnable) {
                [needLayoutViews addObject:subview];
            }
        }
        for (UIView *subview in needLayoutViews) {
            YGAttachNodesFromViewHierachy(subview);
        }
    }
}

static void YGRemoveAllChildren(const YGNodeRef node) {
    if (node == NULL) {
        return;
    }
    YGNodeRemoveAllChildren(node);
}

static CGFloat YGRoundPixelValue(CGFloat value) {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(){
        scale = [UIScreen mainScreen].scale;
    });
    return roundf(value * scale) / scale;
}

/// 虚拟视图的 x 和 y 分别作为子视图的 xOffset 和 yOffset
static void YGApplyLayoutRecursive(MLNUILayoutNode *layoutNode, float xOffset, float yOffset) {
    YGNodeRef node = layoutNode.node;
    if (isnan(YGNodeLayoutGetWidth(node)) || isnan(YGNodeLayoutGetHeight(node))) {
        return;
    }
    
    CGFloat top = YGNodeLayoutGetTop(node);
    CGFloat left = YGNodeLayoutGetLeft(node);
    CGPoint origin = (CGPoint){YGRoundPixelValue(left), YGRoundPixelValue(top)};
    
    UIView *view = layoutNode.view;
    NSArray<MLNUILayoutNode *> *subNodes = layoutNode.subNodes;
    if (view.mlnui_isVirtualView) {
        for (MLNUILayoutNode *subNode in subNodes) {
            YGApplyLayoutRecursive(subNode, origin.x + xOffset, origin.y + yOffset);
        }
    } else {
        CGRect frame = view.akLayoutFrame;
        CGPoint oldOrigin = layoutNode.resetOriginAfterLayout ? CGPointZero : frame.origin;
        frame.origin = (CGPoint){origin.x + oldOrigin.x + xOffset, origin.y + oldOrigin.y + yOffset};
        frame.size = (CGSize){
            YGRoundPixelValue(YGNodeLayoutGetWidth(node)),
            YGRoundPixelValue(YGNodeLayoutGetHeight(node))
        };
        if (!CGRectEqualToRect(view.akLayoutFrame, frame)) {
            view.akLayoutFrame = frame;
            [view mlnui_layoutDidChange];
        }
        [view mlnui_layoutCompleted];
        
        if (!layoutNode.isLeaf) {
            for (MLNUILayoutNode *subNode in subNodes) {
                YGApplyLayoutRecursive(subNode, 0.0, 0.0); // 当前视图(即view) 非虚拟视图，故偏移量为0.0
            }
        }
    }
}

static inline BOOL MLNUIValueEqual(MLNUIValue value1, MLNUIValue value2) {
    if (value1.unit != value2.unit) {
        return false;
    }
    if (isnan(value1.value) && isnan(value2.value)) { // MLNUIValueAuto
        return true;
    }
    return (value1.value == value2.value);
}

#pragma mark - Debug

static inline NSString *BOOLString(BOOL value) {
    return value ? @"YES" : @"NO";
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<\n%@\n-> view: %@\n-> isRootNode: %@\n-> isLeaf: %@\n-> isVirtualView: %@\n-> isDirty: %@\n-> superNode: %@\n-> subNodes: %@\n>", self, _view, BOOLString(self.isRootNode), BOOLString(self.isLeaf), BOOLString(self.view.mlnui_isVirtualView),  BOOLString(self.isDirty), self.superNode, self.subNodes];
}

@end
