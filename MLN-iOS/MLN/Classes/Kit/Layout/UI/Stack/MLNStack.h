//
//  MLNStack.h
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNView.h"
#import "MLNStackConst.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNLayoutNode;

@interface MLNStack : MLNView

// subclass should override
- (MLNLayoutNode *)createStackNodeWithTargetView:(UIView *)targetView;

@end

NS_ASSUME_NONNULL_END
