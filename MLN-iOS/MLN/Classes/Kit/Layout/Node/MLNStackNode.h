//
//  MLNStackNode.h
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNLayoutContainerNode.h"
#import "MLNStackConst.h"

#define MLN_IS_EXPANDED_SPACER_NODE_IN_HSTACK(node) \
        (node.isSpacerNode && ((MLNSpacerNode *)node).changedWidth == NO)
#define MLN_IS_EXPANDED_SPACER_NODE_IN_VSTACK(node) \
        (node.isSpacerNode && ((MLNSpacerNode *)node).changedHeight == NO)

NS_ASSUME_NONNULL_BEGIN

@interface MLNStackNode : MLNLayoutContainerNode

@property (nonatomic, assign) MLNStackMainAlignment mainAxisAlignment;
@property (nonatomic, assign) MLNStackCrossAlignment crossAxisAlignment;

- (CGSize)measureSubNodes:(NSArray<MLNLayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;

@end

NS_ASSUME_NONNULL_END
