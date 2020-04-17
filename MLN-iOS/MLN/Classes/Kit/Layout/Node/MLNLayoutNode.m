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
        _anchorPoint = targetView.layer.anchorPoint;
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
        if (isLayoutNodeWidthNeedMerge(self)) {
            _mergedWidthType = MLNLayoutMeasurementTypeWrapContent;
        }
        // height
        if (isLayoutNodeHeightNeedMerge(self)) {
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
    if (self.overlayNode) {
        CGFloat overlayMaxWidth = self.measuredWidth - self.overlayNode.marginLeft - self.overlayNode.marginRight;
        CGFloat overlayMaxHeight = self.measuredHeight - self.overlayNode.marginTop - self.overlayNode.marginBottom;
        [self.overlayNode measureSizeWithMaxWidth:overlayMaxWidth maxHeight:overlayMaxHeight];
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (CGFloat)calculateWidthBaseOnWeightWithMaxWidth:(CGFloat)maxWidth
{
    if (self.widthType != MLNLayoutMeasurementTypeIdle && self.widthProportion > 0.f) {
        maxWidth = maxWidth * self.widthProportion;
        // min
        maxWidth = MAX(maxWidth, self.minWidth);
        // max
        maxWidth = self.maxWidth > 0.f ? MIN(maxWidth, self.maxWidth) : maxWidth;
        self.isWidthExcatly = YES;
    }  else {
        self.isWidthExcatly = NO;
    }
    return maxWidth;
}

- (CGFloat)calculateHeightBaseOnWeightWithMaxHeight:(CGFloat)maxHeight
{
    if (self.heightType != MLNLayoutMeasurementTypeIdle && self.heightProportion > 0.f) {
        maxHeight = maxHeight * self.heightProportion;
        // min
        maxHeight = MAX(maxHeight, self.minHeight);
        // max
        maxHeight = self.maxHeight > 0.f ? MIN(maxHeight, self.maxHeight) : maxHeight;
        self.isHeightExcatly = YES;
    } else {
        self.isHeightExcatly = NO;
    }
    return maxHeight;
}

MLN_FORCE_INLINE void measureSimapleAutoNodeSize(MLNLayoutNode __unsafe_unretained *node, CGFloat maxWidth, CGFloat maxHeight) {
    // 权重
    maxWidth = [node calculateWidthBaseOnWeightWithMaxWidth:maxWidth];
    maxHeight = [node calculateHeightBaseOnWeightWithMaxHeight:maxHeight];
    if (!node.isDirty && (node.lastMeasuredMaxWidth==maxWidth && node.lastMeasuredMaxHeight==maxHeight) && !isLayoutNodeHeightNeedMerge(node) && !isLayoutNodeWidthNeedMerge(node)) {
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
    if (!node.isWidthExcatly) {
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
    } else {
        node.measuredWidth = maxWidth;
    }
    // height
    if (!node.isHeightExcatly) {
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
    } else {
        node.measuredHeight = maxHeight;
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
            return self.maxWidth > 0.f ? MIN(self.maxWidth, maxWidth) : maxWidth;
    }
}

- (CGFloat)myMaxHeightWithMaxHeight:(CGFloat)maxHeight
{
    switch (self.mergedHeightType) {
        case MLNLayoutMeasurementTypeIdle:
            return self.height;
        default:
            return self.maxHeight > 0.f ? MIN(self.maxHeight, maxHeight) : maxHeight;
    }
}

#pragma mark - Layout
- (void)changeX:(CGFloat)x
{
    [self changeLayoutStrategyTo:MLNLayoutStrategyNativeFrame];
    self.enable = NO;
    if (_x != x || _offsetX != 0.f) {
        _x = x;
        _offsetX = 0.f;
        [self needLayoutAndSpread];
    }
}

- (void)changeY:(CGFloat)y
{
    [self changeLayoutStrategyTo:MLNLayoutStrategyNativeFrame];
    self.enable = NO;
    if (_y != y || _offsetY != 0.f) {
        _y = y;
        _offsetY = 0.f;
        [self needLayoutAndSpread];
    }
}

- (void)changeWidth:(CGFloat)width
{
    MLNLayoutMeasurementType type = width;
    //⚠️ 小于0且不等于MLNLayoutMeasurementTypeWrapContent和MLNLayoutMeasurementTypeMatchParent
    //   认为是绝对宽度0
    if (width != MLNLayoutMeasurementTypeWrapContent &&
        width != MLNLayoutMeasurementTypeMatchParent) {
        type = MLNLayoutMeasurementTypeIdle;
        width = width < 0.f ? 0.f : width;
    }
    BOOL needLayout = NO;
    if (_width != width  || _offsetWidth != 0.f) {
        _width = width;
        _offsetWidth = 0.f;
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
    //⚠️ 小于0且不等于MLNLayoutMeasurementTypeWrapContent和MLNLayoutMeasurementTypeMatchParent
    //   认为是绝对高度0
    if (height != MLNLayoutMeasurementTypeWrapContent &&
        height != MLNLayoutMeasurementTypeMatchParent) {
        type = MLNLayoutMeasurementTypeIdle;
        height = height < 0.f ? 0.f : height;
    }
    BOOL needLayout = NO;
    if (_height != height || _offsetHeight != 0.f) {
        _height = height;
        _offsetHeight = 0.f;
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
        CGRect newFrame = CGRectMake(self.measuredX + self.offsetX, self.measuredY + self.offsetY, self.measuredWidth + self.offsetWidth, self.measuredHeight + self.offsetHeight);
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

- (void)layoutOverlayNode {
    MLNLayoutNode *overlayNode = self.overlayNode;
    if (overlayNode == nil) return;
    if (overlayNode.isGone) return;
    
    switch (overlayNode.layoutStrategy) {
        case MLNLayoutStrategyNativeFrame:
            overlayNode.measuredX = overlayNode.x;
            overlayNode.measuredY = overlayNode.y;
            break;
            
        case MLNLayoutStrategySimapleAuto: {
            CGFloat availableWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
            CGFloat availableHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
            switch (overlayNode.gravity & MLNGravityHorizontalMask) {
                case MLNGravityCenterHorizontal:
                    overlayNode.measuredX = self.paddingLeft + (availableWidth - overlayNode.measuredWidth) / 2.0 + overlayNode.marginLeft - overlayNode.marginRight;
                    break;
                case MLNGravityRight:
                    overlayNode.measuredX = self.measuredWidth - self.paddingRight - overlayNode.measuredWidth - overlayNode.marginRight;
                    break;
                case MLNGravityLeft:
                default:
                    overlayNode.measuredX = self.paddingLeft + overlayNode.marginLeft;
                    break;
            }
            switch (overlayNode.gravity & MLNGravityVerticalMask) {
                case MLNGravityCenterVertical:
                    overlayNode.measuredY = self.paddingTop + (availableHeight - overlayNode.measuredHeight) / 2.0 + overlayNode.marginTop - overlayNode.marginBottom;
                    break;
                case MLNGravityBottom:
                    overlayNode.measuredY = self.measuredHeight - self.paddingBottom - overlayNode.measuredHeight - overlayNode.marginBottom;
                    break;
                case MLNGravityTop:
                default:
                    overlayNode.measuredY = self.paddingTop + overlayNode.marginTop;
                    break;
            }
            break;
        }
            
        default:
            break;
    }

    [overlayNode updateTargetViewFrameIfNeed];
    if (overlayNode.isContainer) {
        [(MLNLayoutContainerNode *)overlayNode layoutSubnodes];
    }
    if (overlayNode.overlayNode) {
        [overlayNode layoutOverlayNode];
    }
}

#pragma mark - Tree Of Node
- (BOOL)isContainer
{
    return NO;
}

- (void)removeFromSupernode
{
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
    if (widthType != MLNLayoutMeasurementTypeWrapContent &&
        widthType != MLNLayoutMeasurementTypeMatchParent) {
        widthType = MLNLayoutMeasurementTypeIdle;
    }
    if (_widthType != widthType) {
        [self needLayoutAndSpread];
        _widthType = widthType;
    }
}

- (void)setHeightType:(MLNLayoutMeasurementType)heightType
{
    if (heightType != MLNLayoutMeasurementTypeWrapContent &&
        heightType != MLNLayoutMeasurementTypeMatchParent) {
        heightType = MLNLayoutMeasurementTypeIdle;
    }
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

- (void)setWeight:(int)weight
{
    if (_weight != weight) {
        _weight = weight;
        [self needLayoutAndSpread];
    }
}

#pragma mark - Setter Of Size
- (void)setWidth:(CGFloat)width
{
    if (_width != width || _offsetWidth != 0.0) {
        [self needLayoutAndSpread];
        _offsetWidth = 0.0;
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
    if (_marginTop != marginTop || _offsetY != 0) {
        [self needLayoutAndSpread];
        _offsetY = 0.0;
        _marginTop = marginTop;
    }
}

- (void)setMarginBottom:(CGFloat)marginBottom
{
    if (_marginBottom != marginBottom || _offsetY != 0) {
        [self needLayoutAndSpread];
        _offsetY = 0.0;
        _marginBottom = marginBottom;
    }
}

- (void)setMarginLeft:(CGFloat)marginLeft
{
    if (_marginLeft != marginLeft || _offsetX != 0) {
        [self needLayoutAndSpread];
        _offsetX = 0.0;
        _marginLeft = marginLeft;
    }
}

- (void)setMarginRight:(CGFloat)marginRight
{
    if (_marginRight != marginRight || _offsetX != 0) {
        [self needLayoutAndSpread];
        _offsetX = 0.0;
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

- (BOOL)isSpacerNode {
    return NO;
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
