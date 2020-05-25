//
//  MLNUILayoutNode.h
//
//
//  Created by MoMo on 2018/10/24.
//

#import <UIKit/UIKit.h>
#import "MLNUIViewConst.h"

#define isLayoutNodeWidthNeedMerge(NODE) (NODE.widthType == MLNUILayoutMeasurementTypeMatchParent &&\
                                   (NODE.supernode.mergedWidthType == MLNUILayoutMeasurementTypeWrapContent || \
                                    NODE.supernode.isHorizontalMaxMode))
#define isLayoutNodeHeightNeedMerge(NODE) (NODE.heightType == MLNUILayoutMeasurementTypeMatchParent &&\
                                    (NODE.supernode.mergedHeightType == MLNUILayoutMeasurementTypeWrapContent || \
                                     NODE.supernode.isVerticalMaxMode))

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MLNUILayoutNodeStatusIdle = 0,    // By default.
    MLNUILayoutNodeStatusNeedLayout,
    MLNUILayoutNodeStatusHasNewLayout,
    MLNUILayoutNodeStatusUp2Date,
} MLNUILayoutNodeStatus;

typedef enum : NSUInteger {
    MLNUILayoutStrategySimapleAuto = 0, // By default.
    MLNUILayoutStrategyNativeFrame,
} MLNUILayoutStrategy;

@interface MLNUILayoutNode : NSObject

//*******
//******                Absolute
//*****
@property (nonatomic, assign, readonly) CGFloat x;
@property (nonatomic, assign, readonly) CGFloat y;
@property (nonatomic, assign, readonly) CGFloat width;
@property (nonatomic, assign, readonly) CGFloat height;
//*******
//******                MaxSize
//*****
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat minHeight;
//*******
//******                Gravity
//*****
@property (nonatomic, assign) enum MLNUIGravity gravity;
//*******
//******                Margin
//*****
@property (nonatomic, assign) CGFloat marginTop;
@property (nonatomic, assign) CGFloat marginBottom;
@property (nonatomic, assign) CGFloat marginLeft;
@property (nonatomic, assign) CGFloat marginRight;
//*******
//******                Padding
//*****
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat paddingLeft;
@property (nonatomic, assign) CGFloat paddingRight;
@property (nonatomic, assign, getter=isPaddingNeedUpdated) BOOL paddingNeedUpdated;// default is YES.
- (void)paddingUpdated;
//*******
//******                Measure
//*****
@property (nonatomic, assign) CGFloat measuredX;
@property (nonatomic, assign) CGFloat measuredY;
@property (nonatomic, assign) CGFloat measuredWidth;
@property (nonatomic, assign) CGFloat measuredHeight;
@property (nonatomic, assign) CGFloat lastMeasuredMaxWidth;
@property (nonatomic, assign) CGFloat lastMeasuredMaxHeight;
@property (nonatomic, assign) CGFloat lastGravityZoneWidth;
@property (nonatomic, assign) CGFloat lastGravityZoneHeight;
//*******
//******                Offset
//*****
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) CGFloat offsetWidth;
@property (nonatomic, assign) CGFloat offsetHeight;
//*******
//******                anchorPoint
//*****
@property (nonatomic, assign, readonly) CGPoint anchorPoint;
//*******
//******                State
//*****
@property (nonatomic, assign, readonly) MLNUILayoutStrategy layoutStrategy;
@property (nonatomic, assign, readonly) MLNUILayoutNodeStatus status;
@property (nonatomic, assign, getter=isWrapContent) BOOL wrapContent;
@property (nonatomic, assign) MLNUILayoutMeasurementType widthType;
@property (nonatomic, assign) MLNUILayoutMeasurementType heightType;
@property (nonatomic, assign, readonly) MLNUILayoutMeasurementType mergedWidthType;
@property (nonatomic, assign, readonly) MLNUILayoutMeasurementType mergedHeightType;
@property (nonatomic, assign, getter=isEnable) BOOL enable;
@property (nonatomic, assign, getter=isRoot) BOOL root;
@property (nonatomic, assign) CGFloat priority;
@property (nonatomic, assign) BOOL isVerticalMaxMode;
@property (nonatomic, assign) BOOL isHorizontalMaxMode;
@property (nonatomic, assign, getter=isGone) BOOL gone;
- (BOOL)isDirty;
- (BOOL)hasNewLayout;
- (void)changeLayoutStrategyTo:(MLNUILayoutStrategy)layoutStrategy;
//*******
//******                weight
//*****
@property (nonatomic, assign) int weight;
@property (nonatomic, assign) CGFloat widthProportion;
@property (nonatomic, assign) CGFloat heightProportion;
@property (nonatomic, assign) BOOL isWidthExcatly;
@property (nonatomic, assign) BOOL isHeightExcatly;
- (CGFloat)calculateWidthBaseOnWeightWithMaxWidth:(CGFloat)maxWidth;
- (CGFloat)calculateHeightBaseOnWeightWithMaxHeight:(CGFloat)maxHeight;
//*******
//******                Node
//*****
@property (nonatomic, weak) MLNUILayoutNode *supernode;
@property (nonatomic, strong, nullable) MLNUILayoutNode *overlayNode;
//*******
//******                Root Node
//*****
@property (nonatomic, weak) MLNUILayoutNode *rootnode;
//*******
//******                View
//*****
@property (nonatomic, weak, readonly) UIView *targetView;
//*******
//******                Initialization
//*****
- (instancetype)initWithTargetView:(nullable UIView *)targetView NS_DESIGNATED_INITIALIZER;
//*******
//******                Node Tree
//*****
@property (nonatomic, assign) NSUInteger idx;
- (BOOL)isContainer;
- (void)removeFromSupernode;
//*******
//******                Measure Size
//*****
- (void)mergeMeasurementTypes;
- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
- (CGFloat)myMaxWidthWithMaxWidth:(CGFloat)maxWidth;
- (CGFloat)myMaxHeightWithMaxHeight:(CGFloat)maxHeight;
- (void)measureSizeLightMatchParentWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
- (CGFloat)measurePriority;
- (void)forceUseMatchParentForWidthMeasureType;
- (void)forceUseMatchParentForHeightMeasureType;
//*******
//******                Layout
//*****
- (void)changeX:(CGFloat)x;
- (void)changeY:(CGFloat)y;
- (void)changeWidth:(CGFloat)width;
- (void)changeHeight:(CGFloat)height;
- (void)changeAnchorPoint:(CGPoint)point;
- (void)updateTargetViewFrameIfNeed;
- (void)needLayout;
- (void)needLayoutAndSpread;
- (void)needUpdateLayout;
- (void)updatedLayout;
- (void)requestLayout;
- (void)layoutOverlayNode;

//*******
//******                bind and unbind
//*****
- (void)bindSuper:(MLNUILayoutNode *)supernode;
- (void)unbind;
@end

NS_ASSUME_NONNULL_END
