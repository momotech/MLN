//
//  MLNUILayoutNode.m
//
//
//  Created by MoMo on 2018/10/24.
//

#import "MLNUILayoutNode.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutContainerNode.h"
#import "UIView+MLNUIKit.h"

@interface MLNUILayoutNode ()

@property (nonatomic, assign) BOOL needUpdateAnchorPoint;
@property (nonatomic, assign) BOOL widthForceMatchParent;
@property (nonatomic, assign) BOOL heightForceMatchParent;

@end
@implementation MLNUILayoutNode

#pragma mark - Initialization
- (instancetype)initWithTargetView:(UIView *)targetView
{
    if (self = [super init]) {
        _targetView = targetView;
        _status = MLNUILayoutNodeStatusIdle;
        _enable = YES;
        _heightType = MLNUILayoutMeasurementTypeWrapContent;
        _widthType = MLNUILayoutMeasurementTypeWrapContent;
        _wrapContent = YES;
        _layoutStrategy = MLNUILayoutStrategySimapleAuto;
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

- (void)forceUseMatchParentForWidthMeasureType {
    if (self.widthType == MLNUILayoutMeasurementTypeMatchParent &&
        self.mergedWidthType == MLNUILayoutMeasurementTypeWrapContent) {
        self.widthForceMatchParent = YES;
    }
}

- (void)forceUseMatchParentForHeightMeasureType {
    if (self.heightType == MLNUILayoutMeasurementTypeMatchParent &&
        self.mergedHeightType == MLNUILayoutMeasurementTypeWrapContent) {
        self.heightForceMatchParent = YES;
    }
}

static MLNUI_FORCE_INLINE BOOL MLNUILayoutNodeWidthNeedMerge(MLNUILayoutNode *self) {
    if (self.widthForceMatchParent) {
        self.widthForceMatchParent = NO;
        return NO;
    }
    return isLayoutNodeWidthNeedMerge(self);
}

static MLNUI_FORCE_INLINE BOOL MLNUILayoutNodeHeightNeedMerge(MLNUILayoutNode *self) {
    if (self.heightForceMatchParent) {
        self.heightForceMatchParent = NO;
        return NO;
    }
    return isLayoutNodeHeightNeedMerge(self);
}

- (void)mergeMeasurementTypes
{
    _mergedWidthType = self.widthType;
    _mergedHeightType = self.heightType;
    if (self.supernode) {
        // width
        if (MLNUILayoutNodeWidthNeedMerge(self)) {
            _mergedWidthType = MLNUILayoutMeasurementTypeWrapContent;
        }
        // height
        if (MLNUILayoutNodeHeightNeedMerge(self)) {
            _mergedHeightType = MLNUILayoutMeasurementTypeWrapContent;
        }
    }
}

- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.isGone) {
        return CGSizeZero;
    }
    switch (self.layoutStrategy) {
        case MLNUILayoutStrategySimapleAuto: {
            measureSimapleAutoNodeSize(self, maxWidth, maxHeight);
            break;
        }
        case MLNUILayoutStrategyNativeFrame: {
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
        if (self.overlayNode.width > self.measuredWidth) {
            [self.overlayNode changeWidth:self.measuredWidth];
        }
        if (self.overlayNode.height > self.measuredHeight) {
            [self.overlayNode changeHeight:self.measuredHeight];
        }
        [self.overlayNode measureSizeWithMaxWidth:overlayMaxWidth maxHeight:overlayMaxHeight];
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (CGFloat)calculateWidthBaseOnWeightWithMaxWidth:(CGFloat)maxWidth
{
    if (self.widthType != MLNUILayoutMeasurementTypeIdle && self.widthProportion > 0.f) {
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
    if (self.heightType != MLNUILayoutMeasurementTypeIdle && self.heightProportion > 0.f) {
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

MLNUI_FORCE_INLINE void measureSimapleAutoNodeSize(MLNUILayoutNode __unsafe_unretained *node, CGFloat maxWidth, CGFloat maxHeight) {
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
    if (node.mergedWidthType == MLNUILayoutMeasurementTypeWrapContent ||
        node.mergedHeightType == MLNUILayoutMeasurementTypeWrapContent) {
        CGSize measureSize = [node.targetView lua_measureSizeWithMaxWidth:myMaxWidth maxHeight:myMaxHeight];
        measuredWidth = measureSize.width;
        measuredHeight = measureSize.height;
    }
    // width
    if (!node.isWidthExcatly) {
        switch (node.mergedWidthType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                measuredWidth = MIN(myMaxWidth, measuredWidth);
                node.measuredWidth = MAX(node.minWidth, measuredWidth);
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
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
            case MLNUILayoutMeasurementTypeWrapContent:
                measuredHeight = MIN(myMaxHeight, measuredHeight);
                node.measuredHeight = MAX(node.minHeight, measuredHeight);
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
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
        case MLNUILayoutMeasurementTypeMatchParent:
            self.measuredWidth = MAX(self.minWidth, maxWidth);
            break;
        default:
            break;
    }

    // height
    switch (self.heightType) {
        case MLNUILayoutMeasurementTypeMatchParent:
            self.measuredHeight = MAX(self.minHeight, maxHeight);
            break;
        default:
            break;
    }
}

- (CGFloat)myMaxWidthWithMaxWidth:(CGFloat)maxWidth
{
    switch (self.mergedWidthType) {
        case MLNUILayoutMeasurementTypeIdle:
            return self.width;
        default:
            return self.maxWidth > 0.f ? MIN(self.maxWidth, maxWidth) : maxWidth;
    }
}

- (CGFloat)myMaxHeightWithMaxHeight:(CGFloat)maxHeight
{
    switch (self.mergedHeightType) {
        case MLNUILayoutMeasurementTypeIdle:
            return self.height;
        default:
            return self.maxHeight > 0.f ? MIN(self.maxHeight, maxHeight) : maxHeight;
    }
}

#pragma mark - Layout
- (void)changeX:(CGFloat)x
{
    [self changeLayoutStrategyTo:MLNUILayoutStrategyNativeFrame];
    self.enable = NO;
    if (_x != x || _offsetX != 0.f) {
        _x = x;
        _offsetX = 0.f;
        [self needLayoutAndSpread];
    }
}

- (void)changeY:(CGFloat)y
{
    [self changeLayoutStrategyTo:MLNUILayoutStrategyNativeFrame];
    self.enable = NO;
    if (_y != y || _offsetY != 0.f) {
        _y = y;
        _offsetY = 0.f;
        [self needLayoutAndSpread];
    }
}

- (void)changeWidth:(CGFloat)width
{
    MLNUILayoutMeasurementType type = width;
    //⚠️ 小于0且不等于MLNUILayoutMeasurementTypeWrapContent和MLNUILayoutMeasurementTypeMatchParent
    //   认为是绝对宽度0
    if (width != MLNUILayoutMeasurementTypeWrapContent &&
        width != MLNUILayoutMeasurementTypeMatchParent) {
        type = MLNUILayoutMeasurementTypeIdle;
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
    MLNUILayoutMeasurementType type = height;
    //⚠️ 小于0且不等于MLNUILayoutMeasurementTypeWrapContent和MLNUILayoutMeasurementTypeMatchParent
    //   认为是绝对高度0
    if (height != MLNUILayoutMeasurementTypeWrapContent &&
        height != MLNUILayoutMeasurementTypeMatchParent) {
        type = MLNUILayoutMeasurementTypeIdle;
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
    _status = MLNUILayoutNodeStatusNeedLayout;
}

- (void)needLayoutAndSpread
{
    _status = MLNUILayoutNodeStatusNeedLayout;
    if (self.supernode && !self.supernode.isDirty) {
        [self.supernode needLayoutAndSpread];
    }
}

- (void)needUpdateLayout
{
    _status = MLNUILayoutNodeStatusHasNewLayout;
}

- (void)updatedLayout
{
    _status = MLNUILayoutNodeStatusUp2Date;
}

- (void)requestLayout
{
    [self.rootnode requestLayout];
}

- (void)updateTargetViewFrameIfNeed
{
    if ([self hasNewLayout]) {
        CGRect newFrame = CGRectMake(self.measuredX + self.offsetX, self.measuredY + self.offsetY, self.measuredWidth + self.offsetWidth, self.measuredHeight + self.offsetHeight);
        if (self.overlayNode) {
            self.targetView.superview.frame = newFrame; // 设置overlay的视图的父视图是个临时的wrapView，不参与node布局计算
            newFrame = CGRectMake(0, 0, CGRectGetWidth(newFrame), CGRectGetHeight(newFrame));
        }
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

MLNUI_FORCE_INLINE void resetArchpointIfNeed(MLNUILayoutNode __unsafe_unretained *node) {
    if (node.needUpdateAnchorPoint) {
        node.targetView.layer.anchorPoint = node.anchorPoint;
        node.needUpdateAnchorPoint = NO;
    }
}

- (void)layoutOverlayNode {
    MLNUILayoutNode *overlayNode = self.overlayNode;
    if (overlayNode == nil) return;
    if (overlayNode.isGone) return;
    
    switch (overlayNode.layoutStrategy) {
        case MLNUILayoutStrategyNativeFrame:
            overlayNode.measuredX = overlayNode.x;
            overlayNode.measuredY = overlayNode.y;
            break;
            
        case MLNUILayoutStrategySimapleAuto: {
            CGFloat availableWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
            CGFloat availableHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
            switch (overlayNode.gravity & MLNUIGravityHorizontalMask) {
                case MLNUIGravityCenterHorizontal:
                    overlayNode.measuredX = self.paddingLeft + (availableWidth - overlayNode.measuredWidth) / 2.0 + overlayNode.marginLeft - overlayNode.marginRight;
                    break;
                case MLNUIGravityRight:
                    overlayNode.measuredX = self.measuredWidth - self.paddingRight - overlayNode.measuredWidth - overlayNode.marginRight;
                    break;
                case MLNUIGravityLeft:
                default:
                    overlayNode.measuredX = self.paddingLeft + overlayNode.marginLeft;
                    break;
            }
            switch (overlayNode.gravity & MLNUIGravityVerticalMask) {
                case MLNUIGravityCenterVertical:
                    overlayNode.measuredY = self.paddingTop + (availableHeight - overlayNode.measuredHeight) / 2.0 + overlayNode.marginTop - overlayNode.marginBottom;
                    break;
                case MLNUIGravityBottom:
                    overlayNode.measuredY = self.measuredHeight - self.paddingBottom - overlayNode.measuredHeight - overlayNode.marginBottom;
                    break;
                case MLNUIGravityTop:
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
        [(MLNUILayoutContainerNode *)overlayNode layoutSubnodes];
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
    [(MLNUILayoutContainerNode *)self.supernode removeSubnode:self];
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

- (void)changeLayoutStrategyTo:(MLNUILayoutStrategy)layoutStrategy
{
    _layoutStrategy = layoutStrategy;
}

#pragma mark - Getter Of Status
- (BOOL)isDirty
{
    return self.status == MLNUILayoutNodeStatusNeedLayout;
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
    return self.status == MLNUILayoutNodeStatusHasNewLayout;
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

- (void)setSupernode:(MLNUILayoutNode *)supernode
{
    _supernode = supernode;
}

- (void)setWrapContent:(BOOL)wrapContent
{
    _wrapContent = wrapContent;
    self.widthType = wrapContent ? MLNUILayoutMeasurementTypeWrapContent: MLNUILayoutMeasurementTypeIdle;
    self.heightType = wrapContent ? MLNUILayoutMeasurementTypeWrapContent: MLNUILayoutMeasurementTypeIdle;
}

- (void)setWidthType:(MLNUILayoutMeasurementType)widthType
{
    if (widthType != MLNUILayoutMeasurementTypeWrapContent &&
        widthType != MLNUILayoutMeasurementTypeMatchParent) {
        widthType = MLNUILayoutMeasurementTypeIdle;
    }
    if (_widthType != widthType) {
        [self needLayoutAndSpread];
        _widthType = widthType;
    }
}

- (void)setHeightType:(MLNUILayoutMeasurementType)heightType
{
    if (heightType != MLNUILayoutMeasurementTypeWrapContent &&
        heightType != MLNUILayoutMeasurementTypeMatchParent) {
        heightType = MLNUILayoutMeasurementTypeIdle;
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
        if (!((MLNUILayoutContainerNode *)self.supernode).needSorting) {
            ((MLNUILayoutContainerNode *)self.supernode).needSorting = YES;
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
- (void)setGravity:(enum MLNUIGravity)gravity
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
- (MLNUILayoutNode *)rootnode
{
    if ((!_rootnode && !self.isRoot) || !_rootnode.isRoot) {
        MLNUILayoutNode *superNode = self.supernode;
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
- (void)bindSuper:(MLNUILayoutNode *)supernode
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
