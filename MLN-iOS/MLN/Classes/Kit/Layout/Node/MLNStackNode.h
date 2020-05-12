//
//  MLNStackNode.h
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNLayoutContainerNode.h"
#import "MLNStackConst.h"

#define MLN_IS_EXPANDED_SPACER_NODE_IN_HSTACK(node) \
        (node.isSpacerNode && ((MLNSpacerNode *)node).changedWidth == NO && self.wrapType != MLNStackWrapTypeWrap)
#define MLN_IS_EXPANDED_SPACER_NODE_IN_VSTACK(node) \
        (node.isSpacerNode && ((MLNSpacerNode *)node).changedHeight == NO)

#define MLN_NODE_HEIGHT_SHOULD_FORCE_USE_MATCHPARENT(node) \
        (node.heightType == MLNLayoutMeasurementTypeMatchParent && node.mergedHeightType == MLNLayoutMeasurementTypeWrapContent)
#define MLN_NODE_WIDTH_SHOULD_FORCE_USE_MATCHPARENT(node) \
        (node.widthType == MLNLayoutMeasurementTypeMatchParent && node.mergedWidthType == MLNLayoutMeasurementTypeWrapContent)

NS_ASSUME_NONNULL_BEGIN

@interface MLNStackNode : MLNLayoutContainerNode

- (CGSize)measureSubNodes:(NSArray<MLNLayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;

@end

@interface MLNPlaneStackNode : MLNStackNode

@property (nonatomic, assign) MLNStackMainAlignment mainAxisAlignment;
@property (nonatomic, assign) MLNStackCrossAlignment crossAxisAlignment;
@property (nonatomic, assign) MLNStackWrapType wrapType;

@end

NS_ASSUME_NONNULL_END
