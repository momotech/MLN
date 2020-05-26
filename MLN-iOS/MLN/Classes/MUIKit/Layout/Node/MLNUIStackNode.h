//
//  MLNUIStackNode.h
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUILayoutContainerNode.h"
#import "MLNUIStackConst.h"

#define MLNUI_IS_WRAP_MODE (self.wrapType == MLNUIStackWrapTypeWrap)

#define MLNUI_NODE_HEIGHT_SHOULD_FORCE_USE_MATCHPARENT(node) \
        (node.heightType == MLNUILayoutMeasurementTypeMatchParent && node.mergedHeightType == MLNUILayoutMeasurementTypeWrapContent)
#define MLNUI_NODE_WIDTH_SHOULD_FORCE_USE_MATCHPARENT(node) \
        (node.widthType == MLNUILayoutMeasurementTypeMatchParent && node.mergedWidthType == MLNUILayoutMeasurementTypeWrapContent)

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIStackNode : MLNUILayoutContainerNode

- (CGSize)measureSubNodes:(NSArray<MLNUILayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;

@end

@interface MLNUIPlaneStackNode : MLNUIStackNode

@property (nonatomic, assign) MLNUIStackMainAlignment mainAxisAlignment;
@property (nonatomic, assign) MLNUIStackCrossAlignment crossAxisAlignment;
@property (nonatomic, assign) MLNUIStackWrapType wrapType;

// subclass should override
- (void)invalidateMainAxisMatchParentMeasureType;

@end

NS_ASSUME_NONNULL_END
