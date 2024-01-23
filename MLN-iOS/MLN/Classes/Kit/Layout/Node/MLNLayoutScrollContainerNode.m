//
//  MLNLayoutScrollContainerNode.m
//
//
//  Created by MoMo on 2018/12/13.
//

#import "MLNLayoutScrollContainerNode.h"
#import "UIScrollView+MLNKit.h"

@implementation MLNLayoutScrollContainerNode

- (instancetype)initWithTargetView:(UIScrollView *)targetView
{
    if (self = [super initWithTargetView:targetView]) {
        _scrollHorizontal = targetView.mln_horizontal;
    }
    return self;
}

- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.isGone) {
        return CGSizeZero;
    }
    // 权重
    maxWidth = [self calculateWidthBaseOnWeightWithMaxWidth:maxWidth];
    maxHeight = [self calculateHeightBaseOnWeightWithMaxHeight:maxHeight];
    if (!self.isDirty && (self.lastMeasuredMaxWidth==maxWidth && self.lastMeasuredMaxHeight==maxHeight) &&  !isLayoutNodeHeightNeedMerge(self) && !isLayoutNodeWidthNeedMerge(self)) {
        return CGSizeMake(self.measuredWidth, self.measuredHeight);
    }
    self.lastMeasuredMaxWidth = maxWidth;
    self.lastMeasuredMaxHeight = maxHeight;
    [self mergeMeasurementTypes];
    CGFloat myMaxWidth = [self myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [self myMaxHeightWithMaxHeight:maxHeight];
    
    CGFloat myMeasuredWidth = 0.f;
    CGFloat myMeasuredHeight = 0.f;
    CGFloat usableZoneWidth = myMaxWidth - self.paddingLeft - self.paddingRight;
    CGFloat usableZoneHeight = myMaxHeight - self.paddingTop - self.paddingBottom;
    if (self.scrollHorizontal) {
        usableZoneWidth = CGFLOAT_MAX;
    } else {
        usableZoneHeight = CGFLOAT_MAX;
    }
    
    // 2. calculate subnodes
    NSArray<MLNLayoutNode *> *subnodes_t = self.subnodes;
    for (NSUInteger i = 0; i < subnodes_t.count; i++) {
        MLNLayoutNode *subnode = subnodes_t[i];
        if (subnode.isGone) {
            continue;
        }
        CGFloat subMaxWidth = 0.f;
        CGFloat subMaxHeight = 0.f;
        CGFloat subUsableZoneWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subUsableZoneHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subUsableZoneWidth maxHeight:subUsableZoneHeight];
        switch (subnode.layoutStrategy) {
            case MLNLayoutStrategyNativeFrame:
                subMaxWidth = subMeasuredSize.width + subnode.x;
                subMaxHeight = subMeasuredSize.height + subnode.y;
                break;
            default:
                subMaxWidth = subMeasuredSize.width +subnode.marginLeft +subnode.marginRight +self.paddingLeft +self.paddingRight;
                subMaxHeight = subMeasuredSize.height +subnode.marginTop +subnode.marginBottom +self.paddingTop +self.paddingBottom;
                break;
        }
        // calculate width
        myMeasuredWidth = MAX(myMeasuredWidth, subMaxWidth);
        // calculate height
        myMeasuredHeight = MAX(myMeasuredHeight, subMaxHeight);
    }
    // 3. remain content size
    CGFloat rawContentWidth = myMeasuredWidth;
    CGFloat rawContentHeight = myMeasuredHeight;
    // 4. update width
    if (!self.isWidthExcatly) {
        switch (self.mergedWidthType) {
            case MLNLayoutMeasurementTypeWrapContent:
                myMeasuredWidth = MIN(myMeasuredWidth, myMaxWidth);
                myMeasuredWidth = MAX(self.minWidth, myMeasuredWidth);
                self.measuredWidth = myMeasuredWidth;
                break;
            case MLNLayoutMeasurementTypeMatchParent:
                self.measuredWidth = MAX(self.minWidth, myMaxWidth);
                break;
            default:
                self.measuredWidth = myMaxWidth;
        }
    } else {
        self.measuredWidth = maxWidth;
    }
    // 5. update height
    if (!self.isHeightExcatly) {
        switch (self.mergedHeightType) {
            case MLNLayoutMeasurementTypeWrapContent:
                myMeasuredHeight = MIN(myMeasuredHeight, myMaxHeight);
                myMeasuredHeight = MAX(self.minHeight, myMeasuredHeight);
                self.measuredHeight = myMeasuredHeight;
                break;
            case MLNLayoutMeasurementTypeMatchParent:
                self.measuredHeight = MAX(self.minHeight, myMaxHeight);
                break;
            default:
                self.measuredHeight = myMaxHeight;
        }
    } else {
        self.measuredHeight = maxHeight;
    }
    
    if (self.overlayNode) {
        CGFloat overlayMaxWidth = self.measuredWidth - self.overlayNode.marginLeft - self.overlayNode.marginRight;
        CGFloat overlayMaxHeight = self.measuredHeight - self.overlayNode.marginTop - self.overlayNode.marginBottom;
        [self.overlayNode measureSizeWithMaxWidth:overlayMaxWidth maxHeight:overlayMaxHeight];
    }
    
    // 6. calculate content size
    [self measureContentSize:rawContentWidth rawContentHeight:rawContentHeight];
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (void)measureContentSize:(CGFloat)rawContentWidth rawContentHeight:(CGFloat)rawContentHeight
{
    if (self.scrollHorizontal) {
        self.measuredContentWidth = rawContentWidth;
        self.measuredContentHeight = rawContentHeight > self.measuredHeight ? self.measuredHeight : rawContentHeight;
    } else {
        self.measuredContentWidth = rawContentWidth > self.measuredWidth ? self.measuredWidth : rawContentWidth;
        self.measuredContentHeight = rawContentHeight;
    }
}

- (void)updateTargetViewFrameIfNeed
{
    [self updateTargetViewContentSizeIfNeed];
    [super updateTargetViewFrameIfNeed];
}

- (void)updateTargetViewContentSizeIfNeed
{
    if (self.measuredContentWidth > 0 || self.measuredContentHeight > 0) {
        UIScrollView *myScrollView = (UIScrollView *)self.targetView;
        if (myScrollView.contentSize.width != self.measuredContentWidth ||
            myScrollView.contentSize.height != self.measuredContentHeight) {
            myScrollView.contentSize = CGSizeMake(self.measuredContentWidth, self.measuredContentHeight);
        }
    }
}

- (BOOL)isHorizontalMaxMode
{
    return self.scrollHorizontal;
}

- (BOOL)isVerticalMaxMode
{
    return !self.scrollHorizontal;
}

@end
