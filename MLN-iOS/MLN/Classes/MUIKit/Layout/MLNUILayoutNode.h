//
//  MLNUILayoutNode.h
//  MLN
//
//  Created by MOMO on 2020/5/29.
//

#import <Foundation/Foundation.h>
#import "YGEnums.h"
#import "Yoga.h"
#import "YGMacros.h"
#import "MLNUILayoutMacro.h"

NS_ASSUME_NONNULL_BEGIN

YG_EXTERN_C_BEGIN
extern MLNUIValue MLNUIPointValue(CGFloat value)
    NS_SWIFT_UNAVAILABLE("Use the swift Int and FloatingPoint extensions instead");
extern MLNUIValue MLNUIPercentValue(CGFloat value)
    NS_SWIFT_UNAVAILABLE("Use the swift Int and FloatingPoint extensions instead");
YG_EXTERN_C_END

typedef NS_OPTIONS(NSInteger, YGDimensionFlexibility) {
  YGDimensionFlexibilityFlexibleWidth = 1 << 0,
  YGDimensionFlexibilityFlexibleHeight = 1 << 1,
};

@interface MLNUILayoutNode : NSObject

- (instancetype)init __attribute__((unavailable("you are not meant to initialise MLNUILayout")));
+ (instancetype)new  __attribute__((unavailable("you are not meant to initialise MLNUILayout")));

- (instancetype)initWithView:(UIView *)view isRootView:(BOOL)isRootView;

@property (nonatomic, readwrite, assign) MLNUIDirection direction;
@property (nonatomic, readwrite, assign) MLNUIFlexDirection flexDirection;
@property (nonatomic, readwrite, assign) MLNUIJustify justifyContent; // deafault is START
@property (nonatomic, readwrite, assign) MLNUICrossAlign alignContent; // deafault is START
@property (nonatomic, readwrite, assign) MLNUICrossAlign alignItems; // deafault is START
@property (nonatomic, readwrite, assign) MLNUICrossAlign alignSelf;
@property (nonatomic, readwrite, assign) MLNUIPositionType position;
@property (nonatomic, readwrite, assign) MLNUIWrap flexWrap;
@property (nonatomic, readwrite, assign) YGOverflow overflow;
@property (nonatomic, readwrite, assign) MLNUIDisplay display;

@property (nonatomic, readwrite, assign) CGFloat flex;
@property (nonatomic, readwrite, assign) CGFloat flexGrow;
@property (nonatomic, readwrite, assign) CGFloat flexShrink;
@property (nonatomic, readwrite, assign) MLNUIValue flexBasis;

@property (nonatomic, readwrite, assign) MLNUIValue left;
@property (nonatomic, readwrite, assign) MLNUIValue top;
@property (nonatomic, readwrite, assign) MLNUIValue right;
@property (nonatomic, readwrite, assign) MLNUIValue bottom;
@property (nonatomic, readwrite, assign) MLNUIValue start;
@property (nonatomic, readwrite, assign) MLNUIValue end;

@property (nonatomic, readwrite, assign) MLNUIValue marginLeft;
@property (nonatomic, readwrite, assign) MLNUIValue marginTop;
@property (nonatomic, readwrite, assign) MLNUIValue marginRight;
@property (nonatomic, readwrite, assign) MLNUIValue marginBottom;
@property (nonatomic, readwrite, assign) MLNUIValue marginStart;
@property (nonatomic, readwrite, assign) MLNUIValue marginEnd;
@property (nonatomic, readwrite, assign) MLNUIValue marginHorizontal;
@property (nonatomic, readwrite, assign) MLNUIValue marginVertical;
@property (nonatomic, readwrite, assign) MLNUIValue margin;

@property (nonatomic, readwrite, assign) MLNUIValue paddingLeft;
@property (nonatomic, readwrite, assign) MLNUIValue paddingTop;
@property (nonatomic, readwrite, assign) MLNUIValue paddingRight;
@property (nonatomic, readwrite, assign) MLNUIValue paddingBottom;
@property (nonatomic, readwrite, assign) MLNUIValue paddingStart;
@property (nonatomic, readwrite, assign) MLNUIValue paddingEnd;
@property (nonatomic, readwrite, assign) MLNUIValue paddingHorizontal;
@property (nonatomic, readwrite, assign) MLNUIValue paddingVertical;
@property (nonatomic, readwrite, assign) MLNUIValue padding;

@property (nonatomic, readwrite, assign) CGFloat borderLeftWidth;
@property (nonatomic, readwrite, assign) CGFloat borderTopWidth;
@property (nonatomic, readwrite, assign) CGFloat borderRightWidth;
@property (nonatomic, readwrite, assign) CGFloat borderBottomWidth;
@property (nonatomic, readwrite, assign) CGFloat borderStartWidth;
@property (nonatomic, readwrite, assign) CGFloat borderEndWidth;
@property (nonatomic, readwrite, assign) CGFloat borderWidth;

@property (nonatomic, readwrite, assign) MLNUIValue width;
@property (nonatomic, readwrite, assign) MLNUIValue height;
@property (nonatomic, readwrite, assign) MLNUIValue minWidth;
@property (nonatomic, readwrite, assign) MLNUIValue minHeight;
@property (nonatomic, readwrite, assign) MLNUIValue maxWidth;
@property (nonatomic, readwrite, assign) MLNUIValue maxHeight;
@property (nonatomic, assign, readonly) CGFloat layoutWidth;
@property (nonatomic, assign, readonly) CGFloat layoutHeight;

// Yoga specific properties, not compatible with flexbox specification
@property (nonatomic, readwrite, assign) CGFloat aspectRatio;

/// Get the resolved direction of this node. This won't be YGDirectionInherit
@property (nonatomic, readonly, assign) MLNUIDirection resolvedDirection;

/// Perform a layout calculation and update the frames of the views in the hierarchy with the results. If the origin is not preserved, the root view's layout results will applied from {0,0}.
- (CGSize)applyLayout NS_SWIFT_NAME(applyLayout());

/// @param size the constraint size. Pass `MLNUIUndefined` indicate an unconstrained size.
- (CGSize)applyLayoutWithSize:(CGSize)size NS_SWIFT_NAME(applyLayout(size:));

/// Perform a layout calculation and update the frames of the views in the hierarchy with the results.
- (void)applyLayoutWithDimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility NS_SWIFT_NAME(applyLayout(WithDimensionFlexibility:));

/// Returns the size of the view if no constraints were given. This could equivalent to calling [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
@property (nonatomic, readonly, assign) CGSize intrinsicSize;

/// Returns the size of the view based on provided constraints. Pass NaN for an unconstrained dimension.
- (CGSize)calculateLayoutWithSize:(CGSize)size NS_SWIFT_NAME(calculateLayout(with:));

/// Returns the number of children that are using Flexbox.
@property (nonatomic, readonly, assign) NSUInteger numberOfChildren;

/// Return a BOOL indiciating whether or not we this node contains any subviews that are included in Yoga's layout.
@property (nonatomic, readonly, assign) BOOL isLeaf;

/// Return's a BOOL indicating if a view is dirty. When a node is dirty it usually indicates that it will be remeasured on the next layout pass.
@property (nonatomic, readonly, assign) BOOL isDirty;

/// If YES, the view's origin will be changed when layout. default is YES.
@property (nonatomic, assign, readonly) BOOL resetOriginAfterLayout;

@property (nonatomic, assign, readonly) BOOL isRootNode;
@property (nonatomic, assign, readonly) BOOL isWrapContent;
@property (nonatomic, weak,   readonly) UIView *view;
@property (nonatomic, strong, readonly) NSArray<MLNUILayoutNode *> *subNodes;
@property (nonatomic, strong, readonly) MLNUILayoutNode *superNode;

/// Mark that a view's layout needs to be recalculated. Only works for leaf views.
- (void)markDirty;

- (void)addSubNode:(MLNUILayoutNode *)node;
- (void)insertSubNode:(MLNUILayoutNode *)node atIndex:(NSInteger)index;
- (void)removeSubNode:(MLNUILayoutNode *)node;

@end

NS_ASSUME_NONNULL_END
