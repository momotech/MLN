//
//  MLNStack.h
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNView.h"
#import "MLNStackConst.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNLayoutNode, MLNStackNode;

@interface MLNStack : MLNView

// subclass should override
- (MLNLayoutNode *)createStackNodeWithTargetView:(UIView *)targetView;

// subclass should override
- (void)lua_children:(NSArray *)subviews;

@end

NS_ASSUME_NONNULL_END
