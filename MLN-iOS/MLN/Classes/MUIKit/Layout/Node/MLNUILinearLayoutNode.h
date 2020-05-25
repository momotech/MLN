//
//  MLNUILinearLayoutNode.h
//
//
//  Created by MoMo on 2018/10/26.
//

#import "MLNUILayoutContainerNode.h"
#import "MLNUILinearLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUILinearLayoutNode : MLNUILayoutContainerNode

@property (nonatomic, assign) MLNUILayoutDirection direction;
@property (nonatomic, assign) BOOL reverse;

@end

NS_ASSUME_NONNULL_END
