//
//  MLNUIStack.h
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIView.h"
#import "MLNUIStackConst.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNUILayoutNode;

@interface MLNUIStack : MLNUIView

// subclass should override
- (MLNUILayoutNode *)createStackNodeWithTargetView:(UIView *)targetView;

@end

@interface MLNUIPlaneStack : MLNUIStack

// subclass should override
- (void)invalidateMatchParentMeasureTypeForMainAxis:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
