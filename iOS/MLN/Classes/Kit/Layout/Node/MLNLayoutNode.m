//
//  MLNLayoutNode.m
//
//
//  Created by MoMo on 2018/10/24.
//

#import "MLNLayoutNode.h"
#import "MLNKitHeader.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutContainerNode.h"
#import "UIView+MLNKit.h"

@interface MLNLayoutNode ()

@property (nonatomic, assign) BOOL needUpdateAnchorPoint;

@end
@implementation MLNLayoutNode

#pragma mark - Initialization
- (instancetype)initWithTargetView:(UIView *)targetView
{
    if (self = [super init]) {
        _targetView = targetView;
        _status = MLNLayoutNodeStatusIdle;
        _enable = YES;
        _heightType = MLNLayoutMeasurementTypeWrapContent;
        _widthType = MLNLayoutMeasurementTypeWrapContent;
        _wrapContent = YES;
        _layoutStrategy = MLNLayoutStrategySimapleAuto;
        _anchorPoint = CGPointMake(0.5f, 0.5f);
        _paddingNeedUpdated = YES;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithTargetView:nil];
}

#pragma mark - Measure Size
- (void)mergeMeasurementTypes
{
    _mergedWidthType = self.widthType;
    _mergedHeightType = self.heightType;
    if (self.supernode) {
        // width
        if (self.widthType == MLNLayoutMeasurementTypeMatchParent &&
            (self.supernode.mergedWidthType == MLNLayoutMeasurementTypeWrapContent ||
             self.supernode.isHorizontalMaxMode)) {
                _mergedWidthType = MLNLayoutMeasurementTypeWrapContent;
            }
        // height
        if (self.heightType == MLNLayoutMeasurementTypeMatchParent &&
            (self.supernode.mergedHeightType == MLNLayoutMeasurementTypeWrapContent ||
             self.supernode.isVerticalMaxMode)) {
                _mergedHeightType = MLNLayoutMeasurementTypeWrapContent;
            }
    }
}

- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.isGone) {
        return CGSizeZero;
    }
    switch (self.layoutStrategy) {
        case MLNLayoutStrategySimapleAuto: {
            measureSimapleAutoNodeSize(self, maxWidth, maxHeight);
            break;
        }
        case MLNLayoutStrategyNativeFrame: {
            self.measuredWidth = self.width;
            self.measuredHeight = self.height;
            break;
        }
        default: {
            break;
        }
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

MLN_FORCE_INLINE void measureSimapleAutoNodeSize(MLNLayoutNode __unsafe_unretained *node, CGFloat maxWidth, CGFloat maxHeight) {
    if (!node.isDirty && (node.lastMeasuredMaxWidth==maxWidth && node.lastMeasuredMaxHeight==maxHeight)) {
        return;
    }
    node.lastMeasuredMaxWidth = maxWidth;
    node.lastMeasuredMaxHeight = maxHeight;
    [node mergeMeasurementTypes];
    CGFloat myMaxWidth = [node myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [node myMaxHeightWithMaxHeight:maxHeight];
    CGFloat measuredWidth = myMaxWidth;
    CGFloat measuredHeight = myMaxHeight;
    if (node.mergedWidthType == MLNLayoutMeasurementTypeWrapContent ||
        node.mergedHeightType == MLNLayoutMeasurementTypeWrapContent) {
        CGSize measureSize = [node.targetView lua_measureSizeWithMaxWidth:myMaxWidth maxHeight:myMaxHeight];
        measuredWidth = measureSize.width;
        measuredHeight = measureSize.height;
    }
    // width
    switch (node.mergedWidthType) {
        case MLNLayoutMeasurementTypeWrapContent:
            measuredWidth = MIN(myMaxWidth, measuredWidth);
            node.measuredWidth = MAX(node.minWidth, measuredWidth);
            break;
        case MLNLayoutMeasurementTypeMatchParent:
            node.measuredWidth = MAX(node.minWidth, myMaxWidth);
            break;
        default:
            node.measuredWidth = myMaxWidth;
            break;
    }
    
    // height
    switch (node.mergedHeightType) {
        case MLNLayoutMeasurementTypeWrapContent:
            measuredHeight = MIN(myMaxHeight, measuredHeight);
            node.measuredHeight = MAX(node.minHeight, measuredHeight);
            break;
        case MLNLayoutMeasurementTypeMatchParent:
            node.measuredHeight = MAX(node.minHeight, myMaxHeight);
            break;
        default:
            node.measuredHeight = myMaxHeight;
            break;
    }
}

- (void)measureSizeLightMatchParentWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    // width
    switch (self.widthType) {
        case MLNLayoutMeasurementTypeMatchParent:
            self.measuredWidth = MAX(self.minWidth, maxWidth);
            break;
        default:
            break;
    }

    // height
    switch (self.heightType) {
        case MLNLayoutMeasurementTypeMatchParent:
            self.measuredHeight = MAX(self.minHeight, maxHeight);
            break;
        default:
            break;
    }
}

- (CGFloat)myMaxWidthWithMaxWidth:(CGFloat)maxWidth
{
    switch (self.mergedWidthType) {
        case MLNLayoutMeasurementTypeIdle:
            return self.width;
        default:
            return self.maxWidth > 0 ? MIN(self.maxWidth, maxWidth) : maxWidth;
    }
}

- (CGFloat)myMaxHeightWithMaxHeight:(CGFloat)maxHeight
{
    switch (self.mergedHeightType) {
        case MLNLayoutMeasurementTypeIdle:
            return self.height;
        default:
            return self.maxHeight > 0 ? MIN(self.maxHeight, maxHeight) : maxHeight;
    }
}

#pragma mark - Layout
- (void)changeX:(CGFloat)x
{
    [self changeLayoutStrategyTo:MLNLayoutStrategyNativeFrame];
    self.enable = NO;
    if (_x != x) {
        _x = x;
        [self needLayoutAndSpread];
    }
}

- (void)changeY:(CGFloat)y
{
    [self changeLayoutStrategyTo:MLNLayoutStrategyNativeFrame];
    self.enable = NO;
    if (_y != y) {
        _y = y;
        [self needLayoutAndSpread];
    }
}

- (void)changeWidth:(CGFloat)width
{
    MLNLayoutMeasurementType type = width;
    if (width >= 0) {
        type = MLNLayoutMeasurementTypeIdle;
    } else {
        width = 0;
    }
    BOOL needLayout = NO;
    if (_width != width) {
        _width = width;
        needLayout = YES;
    }
    if (_widthType != type) {
        _widthType = type;
        needLayout = YES;
    }
    if (needLayout) {
        [self needLayoutAndSpread];
    }
}

- (void)changeHeight:(CGFloat)height
{
    MLNLayoutMeasurementType type = height;
    if (height >= 0) {
        type = MLNLayoutMeasurementTypeIdle;
    } else {
        height = 0;
    }
    BOOL needLayout = NO;
    if (_height != height) {
        _height = height;
        needLayout = YES;
    }
    if (_heightType != type) {
        _heightType = type;
        needLayout = YES;
    }
    if (needLayout) {
        [self needLayoutAndSpread];
    }
}

- (void)changeAnchorPoint:(CGPoint)point
{
    if (!CGPointEqualToPoint(self.anchorPoint, point)) {
        self.needUpdateAnchorPoint = YES;
        _anchorPoint = point;
    }
}

- (void)needLayout
{
    _status = MLNLayoutNodeStatusNeedLayout;
}

- (void)needLayoutAndSpread
{
    _status = MLNLayoutNodeStatusNeedLayout;
    if (self.supernode && !self.supernode.isDirty) {
        [self.supernode needLayoutAndSpread];
    }
}

- (void)needUpdateLayout
{
    _status = MLNLayoutNodeStatusHasNewLayout;
}

- (void)updatedLayout
{
    _status = MLNLayoutNodeStatusUp2Date;
}

- (void)requestLayout
{
    [self.rootnode requestLayout];
}

- (void)updateTargetViewFrameIfNeed
{
    if ([self hasNewLayout]) {
        CGRect newFrame = CGRectMake(self.measuredX + self.offsetX, self.measuredY + self.offsetY, self.measuredWidth + + self.offsetWidth, self.measuredHeight + self.offsetHeight);
        if (!CGRectEqualToRect(self.targetView.frame, newFrame)) {
            self.targetView.transform = CGAffineTransformIdentity;
            self.targetView.frame = newFrame;
            [self.targetView lua_resetTransformIfNeed];
            [self.targetView lua_changedLayout];
        }
    }
    [self updatedLayout];
    resetArchpointIfNeed(self);
    [self.targetView lua_layoutCompleted];
}

MLN_FORCE_INLINE void resetArchpointIfNeed(MLNLayoutNode __unsafe_unretained *node) {
    if (node.needUpdateAnchorPoint) {
        node.targetView.layer.anchorPoint = node.anchorPoint;
        node.needUpdateAnchorPoint = NO;
    }
}

#pragma mark - Tree Of Node
- (BOOL)isContainer
{
    return NO;
}

- (void)removeFromSupernode
{
//    MLNLuaAssert([NSThread isMainThread], @"This application is modifying the layout from a background thread!");
    [(MLNLayoutContainerNode *)self.supernode removeSubnode:self];
    [self resetStatus];
}

- (void)resetStatus
{
    [self needLayoutAndSpread];
    self.offsetX = 0.f;
    self.offsetY = 0.f;
    self.offsetWidth = 0.f;
    self.offsetHeight = 0.f;
    self.idx = 0;
}

- (void)changeLayoutStrategyTo:(MLNLayoutStrategy)layoutStrategy
{
    _layoutStrategy = layoutStrategy;
}

#pragma mark - Getter Of Status
- (BOOL)isDirty
{
    return self.status == MLNLayoutNodeStatusNeedLayout;
}

- (BOOL)isVerticalMaxMode
{
    return NO;
}

- (BOOL)isHorizontalMaxMode
{
    return NO;
}

- (BOOL)hasNewLayout
{
    return self.status == MLNLayoutNodeStatusHasNewLayout;
}

#pragma mark - Setter Of root
- (void)setRoot:(BOOL)root
{
    _root = root;
    self.rootnode = root? self : nil;
}

#pragma mark - Setter Of Status
- (void)setGone:(BOOL)gone
{
    if (_gone != gone) {
        _gone = gone;
        [self needLayoutAndSpread];
    }
}

- (void)setSupernode:(MLNLayoutNode *)supernode
{
    _supernode = supernode;
}

- (void)setWrapContent:(BOOL)wrapContent
{
    _wrapContent = wrapContent;
    self.widthType = wrapContent ? MLNLayoutMeasurementTypeWrapContent: MLNLayoutMeasurementTypeIdle;
    self.heightType = wrapContent ? MLNLayoutMeasurementTypeWrapContent: MLNLayoutMeasurementTypeIdle;
}

- (void)setWidthType:(MLNLayoutMeasurementType)widthType
{
    widthType = widthType >= 0 ? MLNLayoutMeasurementTypeIdle : widthType;
    if (_widthType != widthType) {
        [self needLayoutAndSpread];
        _widthType = widthType;
    }
}

- (void)setHeightType:(MLNLayoutMeasurementType)heightType
{
    heightType = heightType >= 0 ? MLNLayoutMeasurementTypeIdle : heightType;
    if (_heightType != heightType) {
        [self needLayoutAndSpread];
        _heightType = heightType;
    }
}

- (void)setPriority:(CGFloat)priority
{
    if (_priority != priority) {
        [self needLayoutAndSpread];
        _priority = priority;
        if (!((MLNLayoutContainerNode *)self.supernode).needSorting) {
            ((MLNLayoutContainerNode *)self.supernode).needSorting = YES;
        }
    }
}

#pragma mark - Setter Of Size
- (void)setWidth:(CGFloat)width
{
    if (_width != width) {
        [self needLayoutAndSpread];
        _width = width;
    }
}

- (void)setMinWidth:(CGFloat)minWidth
{
    if (_minWidth != minWidth) {
        [self needLayoutAndSpread];
        _minWidth = minWidth;
    }
}

- (void)setMinHeight:(CGFloat)minHeight
{
    if (_minHeight != minHeight) {
        [self needLayoutAndSpread];
        _minHeight = minHeight;
    }
}

- (void)setMaxWidth:(CGFloat)maxWidth
{
    if (_maxWidth != maxWidth) {
        [self needLayoutAndSpread];
        _maxWidth = maxWidth;
    }
}

- (void)setMaxHeight:(CGFloat)maxHeight
{
    if (_maxHeight != maxHeight) {
        [self needLayoutAndSpread];
        _maxHeight = maxHeight;
    }
}

#pragma mark - Setter Of Margin
- (void)setMarginTop:(CGFloat)marginTop
{
    if (_marginTop != marginTop) {
        [self needLayoutAndSpread];
        _marginTop = marginTop;
    }
}

- (void)setMarginBottom:(CGFloat)marginBottom
{
    if (_marginBottom != marginBottom) {
        [self needLayoutAndSpread];
        _marginBottom = marginBottom;
    }
}

- (void)setMarginLeft:(CGFloat)marginLeft
{
    if (_marginLeft != marginLeft) {
        [self needLayoutAndSpread];
        _marginLeft = marginLeft;
    }
}

- (void)setMarginRight:(CGFloat)marginRight
{
    if (_marginRight != marginRight) {
        [self needLayoutAndSpread];
        _marginRight = marginRight;
    }
}

#pragma mark - Setter Of Gravity
- (void)setGravity:(enum MLNGravity)gravity
{
    if (_gravity != gravity) {
        [self needLayoutAndSpread];
        _gravity = gravity;
    }
}

#pragma mark - Setter Of Padding
- (void)setPaddingTop:(CGFloat)paddingTop
{
    if (_paddingTop != paddingTop) {
        [self needLayoutAndSpread];
        _paddingTop = paddingTop;
        _paddingNeedUpdated = YES;
    }
}

- (void)setPaddingBottom:(CGFloat)paddingBottom
{
    if (_paddingBottom != paddingBottom) {
        [self needLayoutAndSpread];
        _paddingBottom = paddingBottom;
        _paddingNeedUpdated = YES;
    }
}

- (void)setPaddingLeft:(CGFloat)paddingLeft
{
    if (_paddingLeft != paddingLeft) {
        [self needLayoutAndSpread];
        _paddingLeft = paddingLeft;
        _paddingNeedUpdated = YES;
    }
}

- (void)setPaddingRight:(CGFloat)paddingRight
{
    if (_paddingRight != paddingRight) {
        [self needLayoutAndSpread];
        _paddingRight = paddingRight;
        _paddingNeedUpdated = YES;
    }
}

- (void)paddingUpdated
{
    _paddingNeedUpdated = NO;
}

#pragma mark - Setter Of Measure
- (void)setMeasuredX:(CGFloat)measuredX
{
    if (_measuredX != measuredX || self.isDirty) {
        [self needUpdateLayout];
        _measuredX = measuredX;
    }
}

- (void)setMeasuredY:(CGFloat)measuredY
{
    if (_measuredY != measuredY || self.isDirty) {
        [self needUpdateLayout];
        _measuredY = measuredY;
    }
}

- (void)setMeasuredWidth:(CGFloat)measuredWidth
{
    if (_measuredWidth != measuredWidth || self.isDirty) {
        [self needUpdateLayout];
        _measuredWidth = measuredWidth;
    }
}

- (void)setMeasuredHeight:(CGFloat)measuredHeight
{
    if (_measuredHeight != measuredHeight || self.isDirty) {
        [self needUpdateLayout];
        _measuredHeight = measuredHeight;
    }
}

#pragma mark - Getter
- (MLNLayoutNode *)rootnode
{
    if ((!_rootnode && !self.isRoot) || !_rootnode.isRoot) {
        MLNLayoutNode *superNode = self.supernode;
        while (superNode != nil && superNode.isRoot == NO) {
            superNode = superNode.supernode;
        }
        _rootnode = superNode ? superNode : self;
    }
    return _rootnode;
}

- (CGFloat)measurePriority
{
    return self.priority - (self.idx * 0.001f);
}

#pragma mark - bind & unbind
- (void)bindSuper:(MLNLayoutNode *)supernode
{
    self.supernode = supernode;
    self.rootnode = supernode.rootnode;
}

- (void)unbind
{
    self.supernode = nil;
    self.rootnode = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p , diryt : %d,  target view: %@>",NSStringFromClass([self class]), self, self.isDirty, self.targetView];
}

@end
